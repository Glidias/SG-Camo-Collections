package sg.camo.scrollables.gs 
{
	import sg.camo.scrollables.ScrollGuide;
	import sg.camo.interfaces.IScrollable;
	import gs.TweenLite;
	import gs.easing.Strong;
	/**
	 * Basic tween scrolling based on ratio using GS TweenLite. 
	 * Also includes adjustable public properties to adjust tweening.
	 * 
	 * @author Glenn Ko
	 */
	public class TweenScrollProxy extends ScrollGuide
	{
		/** Total maximum duration allowed for tween */
		public var maxDuration:Number = 1.3;
		
		/**  Average duration per item length */
		public var itemLengthDuration:Number = .5;  
		
		/** Defaulted to <code>Strong.easeOut</code>. */
		public var ease:Function = Strong.easeOut;
		
		public function TweenScrollProxy(targ:IScrollable=null) 
		{
			super(targ);
		}
		
		override public function set scrollH (ratio:Number):void {
			var dest:Number = _x + getDestScrollH(ratio);
			var tarDuration:Number = (diffX(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			TweenLite.to(scrollContent, tarDuration, { x:dest, ease:ease } );
		}
		override public function set scrollV (ratio:Number):void {
			var dest:Number = _y + getDestScrollV(ratio);
			var tarDuration:Number = (diffY(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			TweenLite.to(scrollContent, tarDuration, { y:dest, ease:ease } );
		}
		
		override public function resetScroll():void {
			TweenLite.killTweensOf(scrollContent);
			super.resetScroll();
		}
		
		override public function destroy():void {
			TweenLite.killTweensOf(scrollContent);
			super.destroy();
		}
		
	}

}