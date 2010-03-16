package sg.camogxml.seo 
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camogxml.api.IFunctionDef;
	import sg.camogxml.utils.FunctionDefCreator;
	import sg.camo.interfaces.INodeClassSpawner;
	
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IDestroyable;
	import sg.camogxml.utils.FunctionDefInvoker;
	import sg.camogxml.utils.ConstructorInvoker;

	
	/**
	 * Extended SEOPageRender meant for allowing dynamically added reusable modules 
	 * or list items to be cleared  manually from the main root/list containers once done. 
	 * <br/><br/>
	 * If you intend to reuse your modules/containers rather than requiring them to be disposed
	 * immediately once done with each page, this class is recomended.
	 * <br/><br/>
	 * Also supports attribute bindings per display node, which allow you to define attribute values
	 * that link to custom functions to be invoked for each successfully referenced display item.
	 * This allows other operations from other classes (such as registering of transitions) to be 
	 * executed for each display node.
	 * 
	 * @author Glenn Ko
	 */
	public class SEOPageRenderer extends SEOPageRender
	{
		// Trackers
		/** @private */	protected var _destroyables:Dictionary = new Dictionary();
		/** @private */	protected var _listItems:Dictionary = new Dictionary(); 
		/** @private */	protected var _nestedDivs:Dictionary = new Dictionary(); 
		
		/** @private */	protected var _defGetter:IDefinitionGetter;
		/** @private */	protected var _nodeSpawner:INodeClassSpawner;
		
		// Attribute bindings
		/** @private */	protected var _attribBindings:Dictionary = new Dictionary();
		// Available bindings for myBinding()
		/** @private */	protected var _curRenderTarget:Object;
		/** @private */	protected var _curRenderNode:XML;
		
		public function SEOPageRenderer(renderSrc:IDisplayRenderSource, xml:XML=null, iDefGetter:IDefinitionGetter=null, nodeClassSpawner:INodeClassSpawner=null) 
		{
			super(renderSrc,xml);
			_defGetter  = iDefGetter;
			_nodeSpawner = nodeClassSpawner;
		}
		
		public function addAttributeBindingFrom(target:*, attrib:String, funcName:String):void {
			addAttributeBinding( attrib, FunctionDefCreator.create(target, funcName, false, "|") );
		}
		public function addAttributeBinding(attrib:String, funcDef:IFunctionDef):void {
			if (funcDef == null) return;
			_attribBindings[attrib] = funcDef;
		}	
		public function clearAttributeBinding(attrib:String):void {
			delete _attribBindings[attrib];
		}

		/** @private 
		 * @see sg.camogxml.seo.SEOPageRender superclass */
		
		override protected function	getRenderedBy(id:String, render:IDisplayRender, node:XML=null):DisplayObject {
			var ret:DisplayObject = super.getRenderedBy(id, render, node);
			if ( node!=null && ret!=null) {
				_curRenderTarget = ret;
				_curRenderNode = node;
				considerNodeBindings(node);
			}
			return ret;
		}
		
		/** @private 
		 * @see sg.camogxml.seo.SEOPageRender superclass */
		
		override protected function validateRendered(render:IDisplayRender, node:XML=null):DisplayObject {
			var ret:DisplayObject = super.validateRendered(render, node);
			if (node!=null && ret!=null) {
				_curRenderTarget = ret;
				_curRenderNode = node;
				considerNodeBindings(node);
			}
			return ret;
		}
		
		/** @private */
		protected function considerNodeBindings(node:XML):void {
			var hash:Dictionary = _attribBindings;
			
			for (var i:* in hash) {
				var attrib:String = i;
				if (node['@' + attrib] != undefined) {
			
					var funcDef:IFunctionDef = hash[i];
					var arr:Array = node['@' + attrib].toString().split(funcDef.delimiter);
					
					for (var u:String in arr) {
						var val:* = myBinding(arr[u]) || arr[u];
						arr[u] = val;
					}
					FunctionDefInvoker.invoke(funcDef, arr); 
				}
			}
		}
		
		private static function splitTypeFromSource(value : String) : Object 
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
		
		/** @private */
		protected function myBinding(str:String):* {

			if ( str.charAt(0) != "{") return null;
			str = str.slice(1, str.length -1);
			switch (str) {
				case "target":	return _curRenderTarget;
				case "node": return _curRenderNode;
				default:  if (str.charAt(0) === "[") {
					
							str = str.slice(1, str.length -1);
							var typeSource:Object = str.indexOf("(") > -1 ? splitTypeFromSource(str) : null;
							var defName:String = typeSource!= null ? typeSource.type : str;
							var chkDef:Object = _defGetter.hasDefinition(defName) ? _defGetter.getDefinition(defName) : null;
							
							if (chkDef == null) return null;
							var passParams:Array;
							if (chkDef is Class) {
								passParams = typeSource != null ? typeSource.source.length == 0 ? [] : typeSource.source.split("|") : null;
								return typeSource != null ? ConstructorInvoker.invoke(chkDef as Class, passParams ) : _nodeSpawner.spawnClassWithNode(chkDef as Class, _curRenderNode, null, myBinding);
							}
							else if (chkDef is IFunctionDef) {
								var funcDef:IFunctionDef = chkDef as IFunctionDef;
								passParams = typeSource != null ? typeSource.source.length == 0 ? [] : typeSource.source.split(funcDef.delimiter) : [];
								return FunctionDefInvoker.invoke( funcDef, passParams );
							}
	
							else return chkDef;
						}
						return null;
			}
			return null;
		}
		
		/** @private */
		override protected function addAnchorToDisplay(disp:DisplayObject, node:XML, text:String = null):void {
			super.addAnchorToDisplay(disp, node, text);
			
			if (node["@class"] == "button") {
			
				var spr:Sprite = disp as Sprite;
				if (spr) {
					node.@restoreButtonMode = spr.buttonMode ? "true" : "false";
					spr.buttonMode = true;
				}	
			}
		}
		private var _uniqueCount:int = 0;
		/** @private Also performs auto-indexing of ids if ids are undefined*/
		override protected function addToList(list:IList, node:XML, id:String):DisplayObject {
			if (!Boolean(id)) {
				id =   String( "seo"+String(_uniqueCount++) );  // for some strange reason, node.childIndex() doesnt work.
				node.@id = id;
			}
			var retDisp:DisplayObject =  super.addToList(list, node, id);
			if (retDisp) _listItems[retDisp] = new ListItemDefinition(list, id);
			return retDisp;
		}
		
		/** @private */
		override protected function addNestedChild(parentContext:DisplayObjectContainer, child:DisplayObject, render:IDisplayRender=null):void {
			super.addNestedChild(parentContext, child, render);
			_nestedDivs[child] = parentContext;
			var des:IDestroyable = render as IDestroyable;
			if (des == null) return;
			_destroyables[des] = true;
		}
		
		
		/**
		 * Cleans up all list item containers, nested divs and other assosiated destroyables.
		 */
		override public function destroy():void {
			super.destroy();
			
			var i:*;
			var hash:Dictionary;
			
			// Unparent nested divs
			hash = _nestedDivs;  	
			for (i in hash) {
				var dispCont:DisplayObjectContainer = hash[i];
				var disp:DisplayObject = i;
				if (dispCont.contains(disp)) dispCont.removeChild(disp);
				delete hash[i];
			}
			
			// Clean up all list containers
			hash = _listItems;	
			for (i in hash) {
				var def:ListItemDefinition = hash[i];
				var tryDisp:DisplayObject = def.list.removeListItem( def.id );
				if (tryDisp == null) { // assume unsuccessful list item removal, call manual destroy through DisplayObjectContainer...
					 // NOTE: This should not happen if all list ids are unique and the IList removal method returns a valid 
					 // display object reference of the item being removed.
					trace("Warning! IList item removal returns null display object. Attempting manual destroy and removal"); 
					dispCont  = def.list as DisplayObjectContainer;
					tryDisp = i as DisplayObject;
					if (i is IDestroyable) (i as IDestroyable).destroy();
					if (dispCont != null) {
						if ( dispCont.contains(tryDisp) ) {
							dispCont.removeChild(tryDisp);
						}
					}
				}
				delete hash[i];
			}
			
			// Any other destroyable references		
			hash = _destroyables;
			for (i in hash) {
				i.destroy();
				delete hash[i];
			}
			
			// Clear attribute bindings
			hash = _attribBindings;
			for (i in hash) {
				delete _attribBindings[i];
			}
			
		}
		
	}

}

import sg.camo.interfaces.IList;

internal class ListItemDefinition {
	public var list:IList;
	public var id:String;
	
	public function ListItemDefinition(list:IList, listItemId:String):void {
		this.list = list;
		this.id = listItemId;
	}
	
}