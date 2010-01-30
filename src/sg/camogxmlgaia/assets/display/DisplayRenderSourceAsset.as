package sg.camogxmlgaia.assets.display 
{
	import com.gaiaframework.assets.DisplayObjectAsset;
	import com.gaiaframework.assets.SpriteAsset;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camogxmlgaia.api.IDisplayRenderAsset;
	import sg.camogxml.dummy.DisplayObjectRenderProxy;
	import sg.camogxml.dummy.SpriteRenderProxy;
	import sg.camogxmlgaia.api.ISourceAsset;
	/**
	 * A DisplayObjectAsset whose content is assumed to implement the IDisplayRender interface, otherwise a dummy 
	 * SpriteRenderProxy/DisplayObjectRenderProxy is used over the sprite.
	 * 
	 * @see sg.camogxml.dummy.DisplayObjectRenderProxy
	 * 
	 * @author Glenn Ko
	 */
	public class DisplayRenderSourceAsset extends DisplayRenderAsset implements IDisplayRenderSource, ISourceAsset
	{
		protected var _dispRenders:Array = [];

		public function DisplayRenderSourceAsset() 
		{
			super();
		}
		
		public function get sourceType():String {
			return "render";
		}
		
		public function get source():* {
			return this;
		}
		

		public function getRenderById(id:String):IDisplayRender {
			return _dispRenders[id];
		}
		
		/**
		 * The payload of display renders that could be registered externally
		 * @return
		 */
		public function getDisplayRenders():Array {
			var i:int = _dispRenders.length;
			var retArr:Array = new Array(i);
			while (--i > -1) {
				retArr[i] = _dispRenders[i];
			}
			return retArr;
		}
		
		
		
		override protected function onComplete(event:Event):void
		{
			super.onComplete(event);
		
			var cont:DisplayObjectContainer  = (loader.content as DisplayObjectContainer);
			var i:int = cont.numChildren;
			var retArr:Array = new Array(i);
			while (--i > -1) {
				var child:DisplayObject = cont.getChildAt(i);
				retArr[i] =  child is DisplayObjectContainer ? new SpriteRenderProxy(child.name, child as DisplayObjectContainer) : new DisplayObjectRenderProxy(child.name, child);
				retArr[child.name] = retArr[i];
			}
			_dispRenders = retArr;
			
		}
		
		override public function toString():String
		{
			return "[DisplayRenderSourceAsset] " + _id;
		}

		
	}

}