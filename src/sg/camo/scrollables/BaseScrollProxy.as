package sg.camo.scrollables 
{
	import sg.camo.interfaces.IScrollable;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import sg.camo.interfaces.IScrollProxy;
	
	/**
	* Base class for all IScrollProxy implementations.
	* 
	* @see sg.camo.interfaces.IScrollProxy
	* 
	* @author Glenn Ko
	*/
	public class BaseScrollProxy implements IScrollProxy
	{
		/**  @private  */
		protected var _target:IScrollable;
		
		// initial starting x and y values
	
		/**
		 * The recorded initial starting x value of the scrollContent
		 */
		protected var _x:Number = 0;
		/**
		 * The recorded initial starting y value of the scrollContent
		 */
		protected var _y:Number = 0;
		
		/**
		 * Gets recorded initial starting x value of the scrollContent
		 */
		public function get x():Number {
			return x;
		}
		/**
		 * Gets recorded initial starting y value of the scrollContent
		 */
		public function get y():Number {
			return y;
		}
		
		/**
		 * Constructor.
		 * @param	targ	A valid IScrollable instance. Treats it's initial scrollContent x and y values as the starting scroll content positions.
		 */
		public function BaseScrollProxy(targ:IScrollable) 
		{
			if (targ!=null) target = targ;
		}
		
		
		/**
		 * Re-sets target for scrolling, updating it's initial x and y scroll content positions
		 * as the new starting positions.
		 */
		public function set target (iScroll:IScrollable):void {
			_target = iScroll;
			_x = iScroll.scrollContent.x;
			_y = iScroll.scrollContent.y;
		}
		public function get target ():IScrollable {
			return _target;
		}
		
		public function set scrollH(ratio:Number):void {
			// to implement in extended classes
		}
		public function set scrollV(ratio:Number):void {
			// to implement in extended classes
		}
		
		public function resetScroll():void {
			scrollContent.x = _x;
			scrollContent.y = _y;
		}

		public function get scrollContainer ():Sprite {
			return _target.scrollContainer;
		}
		public function get scrollMask ():* {
			return _target.scrollMask;
		}
		public function get scrollContent ():DisplayObject {
			return _target.scrollContent;
		}
		public function get itemLength ():Number {
			return _target.itemLength;
		}
		public function set itemLength (val:Number):void {
			 _target.itemLength = val;
		}
		
		public function destroy():void {
			_target = null;
		}
		
			
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_target.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_target.removeEventListener(type, listener, useCapture);
		}
		
	}
	
}