package sg.camo.greensock.scrollables
{
	import sg.camo.interfaces.IScrollable;
	import sg.camo.scrollables.OpenCloseScrollGuide;
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	/**
	* Basic open/close tween-scrolling using GS-TweenLite. 
	* Also includes adjustable public properties to adjust tweening.
	* 
	* @author Glenn Ko
	*/
	public class OpenCloseTweenScrollProxy extends OpenCloseScrollGuide 
	{
		/**
		 * Duration for opening/closing sequence.
		 */
		public var openDuration:Number = .4;  
		public var closeDuration:Number = .4;  
		
		
		/** Defaulted to <code>Strong.easeOut</code>. */
		public var ease:Function = Strong.easeOut;
		
		public function OpenCloseTweenScrollProxy(targ:IScrollable) 
		{
			super(targ);
		}
		

		override public function set scrollH(ratio:Number):void {
			var duration:Number = ratio != 0 ? openDuration : closeDuration;
			TweenLite.to( scrollContent, duration, { x:getDestScrollH(ratio), ease:ease } );
		}
		override public function set scrollV(ratio:Number):void {
			var duration:Number = ratio != 0 ? openDuration : closeDuration;
			TweenLite.to( scrollContent, duration, { y:getDestScrollV(ratio), ease:ease } );
		}
		
		override public function resetScroll():void {
			super.resetScroll();
			TweenLite.killTweensOf(scrollContent);
		}
		override public function destroy():void {
			TweenLite.killTweensOf(scrollContent);
			super.destroy();
		}
		
	}
	
}