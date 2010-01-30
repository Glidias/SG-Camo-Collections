package sg.camolite.display 
{
	import flash.display.InteractiveObject;
	/**
	 * Still in development...
	 * <br/>Typically allows for 2 additional scroll buttons on each side of the
	 * scrollbar to allow for scrolling by a larger amount.
	 * 
	 * @author Glenn Ko
	 */
	public class GScrollBar2 extends GScrollBar
	{
		protected var _doubleScrollUp:InteractiveObject;
		protected var _doubleScrollDown:InteractiveObject;
		
		public function GScrollBar2() 
		{
			super();
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GScrollBar2;
		}
		
		/**
		 * <b>[Stage instance]</b> 
		 */
		public function set doubleScrollUp(intObj:InteractiveObject):void {
			_doubleScrollUp = setupScrollBtn(intObj);
		}
		/**
		 * <b>[Stage instance]</b>
		 */
		public function set doubleScrollDown(intObj:InteractiveObject):void {
			_doubleScrollDown = setupScrollBtn(intObj);
		}
		
		override public function destroy():void {
			super.destroy();
			if (_doubleScrollUp != null) {
				destroyScrollBtn(_doubleScrollUp);
				_doubleScrollUp = null;
			}
			if (_doubleScrollDown != null) {
				destroyScrollBtn(_doubleScrollDown);
				_doubleScrollDown = null;
			}
		}
		
	}

}