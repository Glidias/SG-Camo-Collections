package sg.camogxml.dummy 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.ancestor.AncestorChild;
	/**
	 * Uses a DisplayObjectContainer to act as an IDisplayRenderSource.
	 * @author Glenn Ko
	 */
	public class SpriteRenderSourceProxy implements IDisplayRenderSource
	{
		protected var _spr:DisplayObjectContainer;
		protected var idHash:Dictionary = new Dictionary();
		
		public function SpriteRenderSourceProxy(spr:DisplayObjectContainer) 
		{
			_spr = spr;
		}
		
		public function getDisplayRenders():Array  {
			var arr:Array = new Array();
			for (var i:* in idHash) {
				arr.push(idHash[i]);
			}
			return arr;
		}
		
		public function getRenderById(id:String):IDisplayRender {
			return idHash[id] ? idHash[id] : createNewRender(id);
		}
		
		private function createNewRender(id:String):IDisplayRender {
			var disp:DisplayObject = AncestorChild.getChildByNameOf(_spr, id);
			var newRender:IDisplayRender = disp is DisplayObjectContainer ? new SpriteRenderProxy(id, disp as DisplayObjectContainer) : new DisplayObjectRenderProxy( id, disp );
			idHash[id] = newRender;
			return newRender;
		}
		
		
		
	}

}