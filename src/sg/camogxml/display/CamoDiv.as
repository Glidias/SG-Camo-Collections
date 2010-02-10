package sg.camogxml.display 
{
	import camo.core.display.CamoDisplay;
	import sg.camo.events.OverflowEvent;
	import sg.camo.interfaces.IDiv;
	import sg.camo.interfaces.IListItem;
	/**
	 * A standard div container with additional overflow "visible" setting 
	 * and is layoutable under DivLayoutBehaviour.
	 * 
	 * @see sg.camo.behaviour.DivLayoutBehaviour
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDiv extends CamoDisplay implements IDiv, IListItem
	{
		protected var _displayFlow:String = "block";
		protected var _position:String = "static";
		protected var _left:Number = 0;
		protected var _top:Number = 0;
		protected var _bottom:Number = Number.NaN;
		protected var _right:Number = Number.NaN;
		
		protected var _overflowVisible:Boolean = false;
		
		public function CamoDiv() 
		{
			
		}
		
		override public function set overflow(str:String):void {
			_overflowVisible = str === "visible";
			super.overflow = str;
		}
		
		override protected function calculatePadding():void
		{
			// Take content w,h + padding to calculate padding size, considering overflow visibility
			var dW:Number = _overflowVisible ? _width : displayWidth;
			var dH:Number = _overflowVisible ? _height : displayHeight;
			_paddingRectangle.width = paddingLeft + dW + paddingRight;
			_paddingRectangle.height = paddingTop + dH + paddingBottom;
			_paddingRectangle.x = borderLeft;
			_paddingRectangle.y = borderTop;
		}
		
		
		override protected function clearOverflow():void {
			super.clearOverflow();
			dispatchEvent( new OverflowEvent(OverflowEvent.NONE) );
			_bubblingDraw = true;
			invalidate();
		}
		
		
		override protected function activateOverflowHidden():void {
			super.activateOverflowHidden();
			dispatchEvent( new OverflowEvent(OverflowEvent.HIDDEN) );
			_bubblingDraw = true;
			invalidate();
		}

		
		override protected function activateOverflowScroll():void
		{
			dispatchEvent( new OverflowEvent(OverflowEvent.SCROLL) );
		}
		

		override protected function activateOverflowAuto():void
		{
			super.activateOverflowHidden();
			dispatchEvent( new OverflowEvent(OverflowEvent.AUTO) );
			_bubblingDraw = true;
			invalidate();
		}
		
		
		public function set displayFlow(str:String):void {
			_displayFlow = str;
		}
		public function get displayFlow():String {
			return _displayFlow;
		}
		
		public function set position(str:String):void {
			_position = str;
		}
		public function get position():String {
			return _position;
		}
		
		public function set left(num:Number):void {
			_left = num;
		}
		public function get left():Number {
			return _left;
		}
		
		public function set top(num:Number):void {
			_top = num;
		}
		public function get top():Number {
			return _top;
		}
		
		public function set right(num:Number):void {
			_right = num;
		}
		public function get right():Number {
			return _right;
		}
		
		public function set bottom(num:Number):void {
			_bottom = num;
		}
		public function get bottom():Number {
			return _bottom;
		}
		



		
		
	}

}