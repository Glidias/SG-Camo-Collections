package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class InvalidateDisplay
	{
		/**
		 * Static method to performs standardised invalidation of display in behaviours package.
		 * @param	disp
		 */
		public static function invalidate(disp:DisplayObject):void {
			if (!disp.stage) return;
			if (disp is IDisplay) (disp as IDisplay).invalidateSize()
			else {
				disp.addEventListener(Event.ENTER_FRAME, onNextFrameInvalidate, false, 0, true);
			}
		}
		
		private static function onNextFrameInvalidate(e:Event):void {
			var dispatcher:IEventDispatcher = e.currentTarget as IEventDispatcher;
			dispatcher.removeEventListener(Event.ENTER_FRAME, onNextFrameInvalidate);
			if (e.currentTarget.stage) dispatcher.dispatchEvent( new Event("true", true) );
		}
		
		
		
	}

}