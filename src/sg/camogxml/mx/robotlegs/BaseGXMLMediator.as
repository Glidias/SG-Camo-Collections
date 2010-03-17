package sg.camogxml.mx.robotlegs 
{
	import org.robotlegs.core.IInjector;
	import org.robotlegs.mvcs.Mediator;
	import sg.camo.interfaces.IPropertyMapCache;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IPropertyBinder;
	import sg.camogxml.api.IBinder;
	import sg.camogxml.api.IGXMLRender;
	
	import sg.camogxml.mx.binding.GBindingUtils;
	import mx.utils.DescribeTypeCache;
	
	/**
	 * An base mediator that supports rendering GXML and binding it to a multiple models' data similar to MXML.
	 * 
	 * @author Glenn Ko
	 */
	public class BaseGXMLMediator extends Mediator implements IBinder
	{
		/**
		 * Markup must be supplied in order to render GXML
		 */
		public var markup:XML;

		/**
		 * Class to instantiate if no gxml render is found
		 */
		[Inject(name="gxml")]
		public function setGXMLRenderClass(classe:Class=null):void {
			_gxmlRenderClass = classe;
		}
		protected var _gxmlRenderClass:Class;
		
		/**
		 * A gxml render to set if needed be
		 */
		[Inject(name="gxml")]
		public function setGXMLRender(render:IGXMLRender = null):void {
			_gxmlRender = render;
		}
		protected var _gxmlRender:IGXMLRender;
		
		
		protected var _bindingUtils:GBindingUtils;
		
		
		[Inject]
		public function set __injector(inj:IInjector):void {
			$injector = inj;
		}
		private var $injector:IInjector;
		
		private var $models:Dictionary;
		
		
		[Inject]
		public var typeHelper:ITypeHelper;
		
		[Inject]
		public var propMapCache:IPropertyMapCache;
		
		[Inject]
		public var propBinder:IPropertyBinder;
		
		
		
		public function BaseGXMLMediator() 
		{
	
		}
		
		/**
		 * Remotely retrieves any models from xml configuration by id.
		 * @param	id
		 * @return	
		 */
		protected function getModel(id:String):* {
			return $models ? $models[id] : null;
		}
	
		
		// -- IBinder implementation (for GXML)
		
		private var $unresolvedGXMLBindings:Array = [];
		
		public function addBinding(target:Object, targetProperty:String, sourcePath:String ):void {
			
			$unresolvedGXMLBindings.push( [target,targetProperty,sourcePath]  );
		}
		
		private final function $doAddBinding(target:Object, targetProperty:String, sourcePath:String):void {
			var firstDotIndex:int = sourcePath.indexOf(".");
			
			var findHost:String = sourcePath.substr(0, firstDotIndex);
			
			var host:* = $models ? $models[findHost] || _gxmlRender.getRenderedById(findHost) : _gxmlRender.getRenderedById(findHost);
			if (host == null) {
				trace("Value binding failed...Could not find host:" + sourcePath);
				return;  
			}
		
			var bindableHostProperty:String = $models ? $models[host] : null;
			host = bindableHostProperty ? this : host;
			var chainStr:String = bindableHostProperty ? bindableHostProperty + "." + sourcePath.substr(firstDotIndex + 1): sourcePath.substr(firstDotIndex + 1);
		
			var chain:Object = _bindingUtils.stringToPropertyChain( chainStr );
			
			
			_bindingUtils.bindProperty( target, targetProperty, host, chain );
		}
	

		protected function getModelFromNode(node:XML):* {		
			var namer:String = node.name();
			var instance:*;
			switch (namer) {
				case "local": return node["@var"] != undefined ? hasOwnProperty(node["@var"].toString()) ? this[node["@var"].toString()] : null : node["@class"] != undefined ? getModelFromClassName(node["@class"], node.@name ) : null;
				case "xml":		
					$injector.mapValue(XML, node, "gxml");
					$injector.mapValue(IBinder, this, "gxml");
					instance = $injector.instantiate( getDefinitionByName(node["@class"]) as Class );
					$injector.unmap(XML, "gxml");
					$injector.unmap(IBinder);
				return instance;
					
				case "recurse":
				case "create":
					var classe:Class = getDefinitionByName(node["@class"]) as Class;
					instance = $injector.instantiate( classe );
					classe =  namer === "recurse" ? classe : null;
					
					applyXMLPropertiesTo(instance, node.children(), classe);
				return instance;
					
				
				default: return null;
			}
		}
		
		private var $unresolvedBindings:Array = [];
		
		private final function applyXMLPropertiesTo(target:Object, xmlList:XMLList, recurseClassCreate:Class=null):void {
			var len:int = xmlList.length();
			
			var propMap:Object = propMapCache.getPropertyMap(target);
	
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var prop:String = xml.name();

				var subList:XMLList = xml.children();
				
				if (subList.length() > 1) {
					if (recurseClassCreate) target[prop] = $injector.instantiate(recurseClassCreate);
					applyXMLPropertiesTo(target[prop], subList, recurseClassCreate);
				}
				else {
					var xmlValue:String = xml.toString();
					if (xmlValue.charAt(0) === "{") {
						$unresolvedBindings.push( [target,prop,xmlValue] );
					}
					else target[prop] = xml.@type != undefined ? typeHelper.getType(xmlValue, xml.@type.toString().toLowerCase()) : propMap[prop] ? typeHelper.getType(xmlValue, propMap[prop]) : xmlValue;
				}
			}
		}
		
		private final function getModelFromClassName(className:String, name:String):* {
			
			var desc:XML = DescribeTypeCache.describeType(this).typeDescription;
			var searchList:XMLList;
			var instance:*;
			
			searchList = desc.*.( (hasOwnProperty("@type")) && @type == className && ( !hasOwnProperty("@access") || (hasOwnProperty("@access") && @access!="writeonly") ) );
			instance = searchList[0] ? this[searchList[0].@name] : null;
			if (searchList.length() > 1) {
				var injectList:XMLList;
				if (name) {
					injectList = searchList.(hasOwnProperty("metadata") && metadata.(@name == "Inject") && metadata.arg.hasOwnProperty("@key") && metadata.arg.@key==name);
					if (injectList.length()) {
						instance =   this[injectList[0].@name]; 
						if (injectList[0].metadata.(@name == "Bindable").length() > 0 ) $models[instance] = injectList[0].@name.toString(); 
						return instance;
					}
				}
				injectList = searchList.(hasOwnProperty("metadata") && metadata.(@name == "Inject") );
				if (injectList.length()) {
					instance = this[injectList[0].@name];
					if (injectList[0].metadata.(@name == "Bindable").length() > 0 ) $models[instance] = injectList[0].@name.toString(); 
					return instance;
				}
				injectList  = searchList.(hasOwnProperty("metadata"));
				if (injectList.length()) {
					instance =  this[injectList[0].@name]; 
					if (injectList[0].metadata.(@name == "Bindable").length() > 0 ) $models[instance] = injectList[0].@name.toString(); 
					return instance;
				}
				
			}
			else {
				if (searchList[0].metadata.(@name == "Bindable").length() > 0 ) $models[instance] = searchList[0].@name.toString(); 
				return instance;
			}
			
		}
		
		override public function onRegister():void {
			_bindingUtils = $injector.instantiate(GBindingUtils);
			
			propBinder.binder = this;  // Enable GXML binding
			
			if (!_gxmlRender) {
				$injector.mapValue(IPropertyApplier, propBinder, "gxml.attribute");
				$injector.mapValue(IBinder, this, "gxml");
				_gxmlRender = $injector.instantiate(_gxmlRenderClass);
				$injector.unmap(IBinder, "gxml");
				$injector.unmap(IPropertyApplier, "gxml.attribute");
			}
			
			if (markup == null) throw new Error("No GXML markup defined for rendering!");
			
			// --Setup GXML-based models
			$models  = markup.Models != undefined ? new Dictionary() : null; 
			var modelList:XMLList =  markup.Models.*;
			for each (var node:XML in modelList) {
				var ider:String = node.@id;
				if (!ider) throw new Error("No 'id' attribute specified for model node!");
				var modelRef:* = getModelFromNode(node);
				if (modelRef) {
					$models[ider] = modelRef;
				}
				else trace("BaseGXMLMediator:: Can't find model for::"+node.toXMLString())
			}
			
			// --Render GXML view
			_gxmlRender.renderGXML(markup);
			
			var arrParams:Array;
			
			for (var i:String in $unresolvedGXMLBindings) {
				arrParams = $unresolvedGXMLBindings[i];
				$doAddBinding( arrParams[0], arrParams[1], arrParams[2]);
			}
			
			
			$unresolvedGXMLBindings = null;
			
			propBinder.binder = null;	// Disable GXML binding
			
			// --Bind any required model values to view (though binding from model to model is possible, it isn't reccomended.)
			for (i in $unresolvedBindings) {
				arrParams = $unresolvedBindings[i];
				var paramString:String = arrParams[2];
				paramString = paramString.substr(1, paramString.length - 2);
				var firstDotIndex:int = paramString.indexOf(".");
				var findHost:String = paramString.substr(0, firstDotIndex);
				var host:* =  $models ? _gxmlRender.getRenderedById(findHost) || $models[findHost] : _gxmlRender.getRenderedById(findHost);
				if (host) {
					var chainStr:String = paramString.substr(firstDotIndex + 1);
					
					_bindingUtils.bindProperty( arrParams[0], arrParams[1], host, _bindingUtils.stringToPropertyChain( chainStr ) );
				}
				else trace("BaseGXMLMediator::register model binding to view. Could not find view by id:" + findHost);
			}
			
			$unresolvedBindings = null;	// clean-up
			
			
			// -- Perform all other bindings in bindings list
			var bindingsList:XMLList = markup.Bindings.*;
			
			for each(node in bindingsList) {
		
				if (node.@destination == undefined || node.@source == undefined) {
					trace("Binding node does not have source/destination:" + node.toXMLString() );
					continue;
				}
				$addBinding(node.@source, node.@destination, node.@twoWay == "true")
			}
		}
		
		private final function $addBinding(source:String, destination:String, twoWay:Boolean=false):void {
			var paramString:String =source;
			
			var firstDotIndex:int = paramString.indexOf(".");
			
			
			var findHost:String = paramString.substr(0, firstDotIndex);
			
			var host:Object = $models ? $models[findHost] || _gxmlRender.getRenderedById(findHost) :  _gxmlRender.getRenderedById(findHost); 
			if (host) {
				var chainStr:String = paramString.substr(firstDotIndex + 1);
			
				paramString = destination;
				firstDotIndex = paramString.indexOf(".");
				
				findHost =  paramString.substr(0, firstDotIndex);
				var site:* = $models ? _gxmlRender.getRenderedById(findHost) || $models[findHost] :  _gxmlRender.getRenderedById(findHost);
				var destChainStr:String = paramString.substr(firstDotIndex + 1);
				var arrParams:Array = _bindingUtils.getNewSiteProperty(site, destChainStr);
				site = arrParams[0];
				var prop:String = arrParams[1];
				_bindingUtils.bindProperty( site, prop, host, _bindingUtils.stringToPropertyChain( chainStr ) );

			}
			else trace("Binding node failed. Can't find host. source/destination:", source, destination);
			if (twoWay) $addBinding(destination, source);
		}
		
		
		override public function onRemove():void {
			_bindingUtils.unbindAll();
		}
		

		
		
	}

}