package sg.camogxml.dummy 
{
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	
	/**
	 * A base dummy IDisplayRender implementation to stand in for DisplayObjects
	 * @author Glenn Ko
	 */
	public class DisplayObjectRenderProxy implements IDisplayRender, IDestroyable
	{
		
		protected var _disp:DisplayObject;
		protected var _renderId:String;
		protected var _isActive:Boolean = false;
		
		public function DisplayObjectRenderProxy(renderId:String, disp:DisplayObject) 
		{
			_renderId = renderId;
			_disp = disp;
		}
		
		public function get renderId():String {
			return _renderId;
		}
		
		/**
		 * Returns the main display object reference
		 */
		public function get rendered():DisplayObject {
			return _disp;
		}
		

		/**
		 *  Returns no child reference.
		 */
		public function getRenderedById(id:String):DisplayObject {
			return null;
		}
		

		
		public function restore(changedHash:Object = null):void {
			
		}
		

		public function set isActive(boo:Boolean):void {
			_isActive = boo;
		}
		public function get isActive():Boolean {
			return _isActive;
		}
		
		public function destroy():void {
			if (_disp is IDestroyable) (_disp as IDestroyable).destroy();
		}
		
		
	}

}