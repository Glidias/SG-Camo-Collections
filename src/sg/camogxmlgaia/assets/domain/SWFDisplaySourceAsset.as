package sg.camogxmlgaia.assets.domain 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camogxmlgaia.api.ISourceAsset;
	import sg.camogxmlgaia.assets.SWFLibraryAsset;
	import sg.camogxml.dummy.SpriteRenderProxy;
	import sg.camogxml.dummy.DisplayObjectRenderProxy;
	
	
	/**
	 * 	A SWFLibraryAsset that allows you to retrieve IDisplayRender instances from Flash library linkages.
	 * 
	 * @author Glenn Ko
	 */
	public class SWFDisplaySourceAsset extends SWFLibraryAsset implements IDisplayRenderSource, ISourceAsset
	{
		/** @private */
		protected var _destroyList:Array = [];
		
		
		public function SWFDisplaySourceAsset() 
		{
			
		}
		
		public function getDisplayRenders():Array {
			return _destroyList.concat();
		}
		public function get source():* {
			return this;
		}
		public function get sourceType():String {
			return "render";
		}
		
		
		override protected function onComplete(event:Event):void
		{
			super.onComplete(event);

			for (var i:* in classesDictionary) {
				var renderDef:DisplayRenderDefinition = new DisplayRenderDefinition( i, classesDictionary[i]);
				_destroyList.push( renderDef );
			}
		}
		
		override public function destroy():void 
		{
			super.destroy();	

			for each (var iDes:IDestroyable in _destroyList) {
				iDes.destroy();
			}
			_destroyList = null;
			
		}
	
		
		
		// --IDisplayRenderSource
		/**
		 * Retrieves a fresh new valid IDisplayRender instance locally with a linkage id from the Flash Library of the SWF. <br/><br/>
		 * All retrieved linkage display objects are assumed to implement the IDisplayRender interface, otherwise a dummy 
		 * SpriteRenderProxy or DisplayObjectRenderProxy is used over the retrieved display object instance.
		 * 	@see sg.camogxml.dummy.SpriteRenderProxy
	     *  @see sg.camogxml.dummy.DisplayObjectRenderProxy
		 * 
		 * @param	id	Gets IDisplayRender instance through linkage id.
		 * @return	A valid IDisplayRender instance or null if all options fail.
		 */
		public function getRenderById(id:String):IDisplayRender {
			if (!hasDefinition(id)) return null;
			var targ:Object =   new (getDefinition(id))();
			return targ is IDisplayRender ? targ as IDisplayRender : targ is Sprite ? new SpriteRenderProxy(id, targ as Sprite) : targ is DisplayObject ? new DisplayObjectRenderProxy(id, targ as DisplayObject) : null;
		}
		
		
		override public function toString():String
		{
			return "[SWFDisplaySourceAsset] " + _id;
		}
		
		
	}

}

import flash.display.DisplayObject;
import flash.display.Sprite;
import sg.camo.interfaces.IDestroyable;
import sg.camo.interfaces.IDisplayRender;
import sg.camogxml.dummy.DisplayObjectRenderProxy;
import sg.camogxml.dummy.SpriteRenderProxy;


internal class DisplayRenderDefinition implements IDisplayRender, IDestroyable {
	
	protected var _renderId:String;
	protected var _isActive:Boolean = false;
	protected var _class:Class;
	protected var _displayRender:IDisplayRender;
		
	public function DisplayRenderDefinition(renderId:String, classe:Class) {
		_renderId = renderId;
		_class = classe;
	}
	
	/**  render ID for registering with asset managers. */
	public function get renderId():String {
		return _renderId;	
	}
		
	/** the current main display object instance */
	public function get rendered():DisplayObject {
		return _displayRender ? _displayRender.rendered : newRender.rendered;
	}
	
	private function get newRender():IDisplayRender {
		var tryDisp:DisplayObject = new _class() as DisplayObject;
		if (tryDisp == null) {
			trace("SWFDisplaySourceAsset :: DisplayRenderDefinition newRender() halt: Retrieved library class definition instance isn't DisplayObject");
			return null;
		}
		_displayRender = tryDisp is IDisplayRender ? tryDisp as IDisplayRender : tryDisp is Sprite ? new SpriteRenderProxy(_renderId, tryDisp as Sprite) : new DisplayObjectRenderProxy(_renderId, tryDisp);
		return _displayRender;
	}
		

	public function getRenderedById(id:String):DisplayObject {
		return _displayRender.getRenderedById(id);
	}
		
	/**  support for restoring back any default settings that were changed during the course of the application */
	public function restore(changedHash:Object = null):void {
		
	}
	
	public function destroy():void {
		if (_displayRender is IDestroyable) (_displayRender as IDestroyable).destroy();
	}
		

	public function set isActive(boo:Boolean):void {
		_isActive = boo;
	}
	public function get isActive():Boolean {
		return _isActive;
	}
	

}