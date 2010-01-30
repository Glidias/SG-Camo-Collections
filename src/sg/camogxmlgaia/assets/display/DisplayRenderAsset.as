package sg.camogxmlgaia.assets.display 
{
	import com.gaiaframework.assets.DisplayObjectAsset;
	import com.gaiaframework.assets.SpriteAsset;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camogxmlgaia.api.IDisplayRenderAsset;
	import sg.camogxml.dummy.DisplayObjectRenderProxy;
	import sg.camogxml.dummy.SpriteRenderProxy;
	/**
	 * A DisplayObjectAsset whose content is assumed to implement the IDisplayRender interface, otherwise a dummy 
	 * SpriteRenderProxy/DisplayObjectRenderProxy is used over the sprite.
	 * 
	 * @see sg.camogxml.dummy.DisplayObjectRenderProxy
	 * 
	 * @author Glenn Ko
	 */
	public class DisplayRenderAsset extends SpriteAsset implements IDisplayRenderAsset
	{
		
		protected var _displayRender:IDisplayRender;
		
		public function DisplayRenderAsset() 
		{
			super();
		}
		
		public function get displayRender():IDisplayRender {
			return _displayRender;
		}
		
		override protected function onComplete(event:Event):void
		{
			super.onComplete(event);
			var tryDisp:DisplayObject = loader.content;
			_displayRender = tryDisp is IDisplayRender ? tryDisp as IDisplayRender : tryDisp is Sprite ? new SpriteRenderProxy(id, tryDisp as Sprite) : new DisplayObjectRenderProxy(id, tryDisp);
		}
		
		override public function toString():String
		{
			return "[DisplayRenderAsset] " + _id;
		}

		
	}

}