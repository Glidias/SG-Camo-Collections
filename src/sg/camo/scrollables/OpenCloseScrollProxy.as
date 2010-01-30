package sg.camo.scrollables 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import sg.camo.interfaces.IOpenScrollProxy;
	import sg.camo.interfaces.IScrollable;
	
	/**
	 * Basic scroll proxy implementation for openable/closeable menus eg. such as dropdown menus,
	 * or any type of openable/closable object like doors. 
	 * <br/><br/>
	 * Because a ratio can be supplied via scrollV/scrollH numeric setters, the interface supports opening items in a "half-open"
	 * or "partially-open" state.
	 * 
	 * @see sg.camo.scrollables.gs.OpenCloseTweenScrollProxy
	 * 
	 * @author Glenn Ko
	 */
	public class OpenCloseScrollProxy extends BaseScrollProxy implements IOpenScrollProxy
	{
		/** @private */
		protected var _openReverseDirection:Boolean = false;
		
		/**
		 * Constructor
		 * @param	targ	A valid IScrollable instance. Treats it's initial scrollContent x and y values as the starting scroll content positions.
		 */
		public function OpenCloseScrollProxy(targ:IScrollable) 
		{
			super (targ);
		}
		

		/**
		 * If set to false, this normally denotes an opening movement in the opposite vector direction.
		 * <br/>
		 * (eg. For scrollH, it would mean moving leftwards(-1*x), and for scrollV, moving upwards (-1*y)
		 */
		public function set openReverseDirection(boo:Boolean):void {
			 _openReverseDirection = boo;
		}
		public function get openReverseDirection():Boolean {
			return _openReverseDirection;
		}
		
		

		/**
		 * A ratio of 1 or -1 means fully opened (in upper & lower vector direction respectively)
		 */
		override public function set scrollH (ratio:Number):void {
			var w:Number = Math.round(scrollContent.width);
			var initial:Number = _openReverseDirection ? w : -w;
			scrollContent.x =  initial +  ratio * w + _x;  //-w + 
		
			//scrollContent.x += ratio == 0 ? w;
			
		}
		
		/**
		 * A ratio of 1 or -1 means fully opened (in upper & lower vector direction respectively)
		 */
		override public function set scrollV (ratio:Number):void {
			var h:Number = Math.round(scrollContent.height); 
			var initial:Number = _openReverseDirection ? h : -h;
			scrollContent.y = initial + ratio * h + _y;  //
			
			//scrollContent.visible = !(scrollContent.y == -h)
		}
		
		
		override public function resetScroll():void {
			//scrollH = 0;
			//scrollV = 0;
		}
		
	}
	
}