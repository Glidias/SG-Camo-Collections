package sg.camogxml.services 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.INodeClassSpawner;
	import sg.camo.interfaces.INodeClassSpawnerManager;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ISelectorSource;
	import sg.camo.interfaces.ITransitionManager;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camo.interfaces.ITypeHelperUtil;
	import sg.camogxml.api.IPropertyBinder;
	import sg.camogxml.dummy.ApplicationDomainGetter;
	
	/**
	 * A portable service that provides a set of public methods to handle type conversions.
	 * @author Glenn Ko
	 */
	public class ResolveDataTypeService
	{
		
		
		public function ResolveDataTypeService(appDomain:ApplicationDomain=null) 
		{
			applicationDomain = appDomain || ApplicationDomain.currentDomain;
		}
		
		public var applicationDomain:ApplicationDomain;
		
		
		// -- Monolithic transition manager
		
		[Inject]
		public function setTransitionManager(transitionManager:ITransitionManager=null):void {
			this.transitionManager = transitionManager;
		}
		public function getTransitionManager(str:String=null):ITransitionManager {
			return transitionManager;
		}
		protected var transitionManager:ITransitionManager;
		

		
		// -- Property Map Cache, TypeHelper, and auto-wiring TypeHelperUtil methods
		
		[Inject]
		public function setPropertyMapCacheAndTypeHelper(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper, typeHelperUtil:ITypeHelperUtil=null, autoMapTypes:Boolean=true):void {
			this.propMapCache = propMapCache;
			this.typeHelper = typeHelper;
			if (typeHelperUtil) {
				this.typeHelperUtil = typeHelperUtil;
				typeHelperUtil.registerFunction("XML", getXML);
				if (autoMapTypes) {
		
					typeHelperUtil.registerFunction( "Class", getDefinitionAsClass);
					//typeHelperUtil.registerFunction( "sg.camogxml::ValueMap", resolveValueMapHandler);
					typeHelperUtil.registerFunction( "flash.events::Event", getNativeEvent);
					
					typeHelperUtil.registerFunction( "flash.display::DisplayObject", getDisplayObject);
					typeHelperUtil.registerFunction( "flash.display::Sprite", getDisplayObject);
					
					typeHelperUtil.registerFunction( "flash.display::Bitmap", getBitmap);
					typeHelperUtil.registerFunction( "flash.display::BitmapData", getBitmapData);
					
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IDisplayRender",getRenderFromSource);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IPropertyApplier", getPropertyApplier);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::INodeClassSpawner", getNodeClassSpawner);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::INodeClassSpawnerManager", getNodeClassSpawnerManager);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::ITransitionManager", getTransitionManager);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::ITypeHelper", getTypeHelper);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::ITypeHelperUtil", getTypeHelperUtil);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IPropertyMapCache", getPropertyMapCache);
					
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IDefinitionGetter", getGlobalDefinitionGetter);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::ISelectorSource", getGlobalStylesheet);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IBehaviouralBase", getGlobalBehaviourSrc);
					typeHelperUtil.registerFunction( "sg.camo.interfaces::IDisplayRenderSource", getGlobalRenderSrc);
					
					typeHelperUtil.registerFunction( "sg.camogxml.api::IPropertyBinder", getPropertyBinder);
					
					
				}
			}
		}
		protected var typeHelper:ITypeHelper;
		protected var propMapCache:IPropertyMapCache;
		protected var typeHelperUtil:ITypeHelperUtil;
		public function getTypeHelper():ITypeHelper {
			return typeHelper;
		}
		public function getTypeHelperUtil():ITypeHelperUtil {
			return typeHelperUtil;
		}
		public function getPropertyMapCache():IPropertyMapCache {
			return propMapCache;
		}
		
		// -- Node spawners
		
		[Inject]
		public function setNodeSpawners(nodeClassSpawner:INodeClassSpawner, manager:INodeClassSpawnerManager=null):void {
			this.nodeClassSpawner = nodeClassSpawner;
			this.nodeClassSpawnerManager = manager;
		}
		protected var nodeClassSpawner:INodeClassSpawner;
		protected var nodeClassSpawnerManager:INodeClassSpawnerManager;
		public function getNodeClassSpawner(type:String):INodeClassSpawner {
			return nodeClassSpawner;
		}
		public function getNodeClassSpawnerManager(type:String):INodeClassSpawnerManager {
			return nodeClassSpawnerManager;
		}
		
		// -- Property Appliers and binders
		
		protected var propApplier:IPropertyApplier;
		protected var behPropApplier:IPropertyApplier;
		protected var textPropApplier:IPropertyApplier;
		protected var attribPropApplier:IPropertyApplier;
		protected var compositePropApplier:IPropertyApplier;
		protected var tweenPropApplier:IPropertyApplier;
		
		[Inject(name='',name='textStyle',name='tweenStyle',name='composite',name='gxml.attribute',name='gxml.behaviour')]
		public function setPropertyAppliers(propApplier:IPropertyApplier, textPropApplier:IPropertyApplier, tweenPropApplier:IPropertyApplier=null, compositePropApplier:IPropertyApplier=null, attribPropApplier:IPropertyApplier=null, behPropApplier:IPropertyApplier=null):void {
			this.propApplier = propApplier;
			this.textPropApplier = textPropApplier;
			this.tweenPropApplier = tweenPropApplier;
			this.behPropApplier = behPropApplier || propApplier;
			this.compositePropApplier = compositePropApplier || propApplier;
			this.attribPropApplier = attribPropApplier || propApplier;
		}
		
		public function getPropertyApplier(type:String):IPropertyApplier {
			switch (type) {
				case "textStyle": return textPropApplier;
				case "tweenStyle": return  tweenPropApplier;
				case "gxml.behaviour": return behPropApplier;
				case "gxml.attribute": return attribPropApplier;
				case "composite": return  compositePropApplier;
				default: return propApplier;
			}
			return myPropApplier;
		}
		
		[Inject]
		public function setPropertyBinder(val:IPropertyBinder=null):void {
			propertyBinder = val;
		}
		protected var propertyBinder:IPropertyBinder;
		public function getPropertyBinder():IPropertyBinder {
			return propertyBinder;
		}
		
		// -- TypeHelperUtil Service call keys
		
		public function getXML(str:String):* {
			return XML(str);
		}
		
		
		public function getClass(val:String):Class  {
			if (val.charAt(0)==="["  ) return getClassDefinitionFromGetter( val.substr(1, val.length -1) );
			return getDefinitionAsClass(val);
		}
		
		public function getDisplayObject(val:String):DisplayObject {
			if (val.indexOf("(") < 0 ) return getDisplayObjectFromSource(val);
			
			var obj:Object = splitTypeFromSource(val);
			var classe:Class = getClassDefinitionFromGetter(obj.type);
			var instance:* = new classe();
			obj = stringToObject(obj.source);
			compositePropApplier.applyProperties(instance, obj);
			return instance;		
		}
		
		protected var _defGetter:IDefinitionGetter;
		protected var _styleGetter:ISelectorSource;
		protected var _behaviourSrc:IBehaviouralBase;
		protected var _renderSrc:IDisplayRenderSource;
		public function setGXMLSources(defGetter:IDefinitionGetter=null, styleGetter:ISelectorSource=null, behaviourSrc:IBehaviouralBase=null, renderSrc:IDisplayRenderSource = null):void {
			_defGetter = defGetter;
			_styleGetter = styleGetter;
			_behaviourSrc = behaviourSrc;
			_renderSrc = renderSrc;
		}
		public function getGlobalBehaviourSrc(val:String):IBehaviouralBase {
			return _behaviourSrc;
		}
		public function getGlobalDefinitionGetter(val:String):IDefinitionGetter {
			return _defGetter;
		}
		public function getGlobalStylesheet(val:String):ISelectorSource {
			return _styleGetter;
		}
		public function getGlobalRenderSrc(val:String):IDisplayRenderSource {
			return _renderSrc;
		}
		
		
		public function getNativeEvent(val:String):Event {
			return new Event(val, true);
		}
		
		public function getBitmap(val:String):Bitmap {
			var bmp:Bitmap;
			var bmpData:BitmapData;
			if ( val.indexOf("(") < 0 ) {
				 bmpData = getBitmapDataFromGetter(val);
				 if ( bmpData==null) throw new Error("Bitmapdata from source failed:"+val)
				 return new Bitmap(bmpData);
			}
			
			var obj:Object = splitTypeFromSource(val);
			var classe:Class = getClassDefinitionFromGetter(obj.type);
			bmp = new classe(0, 0) as Bitmap;
			obj = stringToObject(obj.source);
			compositePropApplier.applyProperties(bmp, obj);
			return bmp;		
		}
		
		public function getBitmapData(val:String):BitmapData {
			return getBitmapDataFromGetter(val);
		}

	
		// Service call helpers
		
		
		public function getDefinition(val:String):Object {
			return applicationDomain.getDefinition(val);
		}
		
		public function getDefinitionAsClass(val:String):Class {
			var classe:Class =  getDefinition(val) as Class;
			if (classe == null) throw new Error('No class cast avaialble for:'+val);
			return classe;
		}
		
		[Inject]
		public function setDefinitionGetter(defGetter:IDefinitionGetter=null):void {
			definitionGetter = defGetter;
		}
		protected var definitionGetter:IDefinitionGetter;
			
		public function getClassDefinitionFromGetter(val:String):Class {
			var def:Class =  definitionGetter.getDefinition(val) as Class;
			if (def) return def
			else throw new Error("getClassDefinitionFromGetter() failed! "+val)
		}	
		public function getBitmapDataFromGetter(val:String):BitmapData {
			var bmpDataClass:Class = definitionGetter.getDefinition(val) as Class;
			return new bmpDataClass(0, 0)	
		}
		
		[Inject]
		public function setDisplayRenderSrc(src:IDisplayRenderSource=null):void {
			displayRenderSrc = src;
		}
		protected var displayRenderSrc:IDisplayRenderSource;
		
		public function getRenderFromSource(val:String):IDisplayRender {
			var renderSrc:IDisplayRenderSource = displayRenderSrc;
			if (renderSrc == null) throw new Error("No render src found!")
			var render:IDisplayRender = renderSrc.getRenderById(val);
			if (render) return render;
			else throw new Error("getRenderFromSource() failed! " + val);
		}
		
		public function getDisplayObjectFromSource(val:String):DisplayObject {
			var rendered:DisplayObject = definitionGetter ? definitionGetter.hasDefinition(val) ? new (definitionGetter.getDefinition(val) as Class)() : getRenderFromSource(val).rendered : getRenderFromSource(val).rendered;
			if (rendered) return rendered
			else throw new Error("getDisplayObjectFromSource() failed! " + val);
		}
		
		


		
		// TypeHelperUtil duplicate
		
		protected static function stringToObject(data : String, dataDelimiter : String = "," ,propDelimiter : String = ":") : * 
		{
			var dataContainer : Object = {};

			var list : Array = data.split( dataDelimiter );

			var total : Number = list.length;

			for (var i : Number = 0; i < total ; i ++) 
			{
				var prop : Array = list[i].split( propDelimiter );
				
				dataContainer[prop[0]] = prop[1];
			}
			
			return dataContainer;
		}
		
		public static function splitTypeFromSource(value : String) : Object 
		{
			var obj : Object = new Object( );
			// Pattern to strip out ',", and ) from the string;
			var pattern : RegExp = RegExp( /[\'\)\"]/g );// this fixes a color highlight issue in FDT --> '
			// Fine type and source
			var split : Array = value.split( "(" );
			//
			obj.type = split[0];
			obj.source = split[1].replace( pattern, "" );
			
			return obj;
		}
		
	}

}