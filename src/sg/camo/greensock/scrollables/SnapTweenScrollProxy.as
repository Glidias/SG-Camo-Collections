package sg.camo.greensock.scrollables {
	
	import flash.events.Event;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.scrollables.SnapGuide;
	import com.greensock.TweenLite;
	import com.greensock.easing.Strong;
	
	/**
	* Basic snap-to-item length tween-scrolling using GS TweenLite. 
	* Also includes adjustable public properties to adjust tweening.
	* 
	* @author Glenn Ko
	*/
	public class SnapTweenScrollProxy extends SnapGuide {
		
		/** Total maximum duration allowed for tween */
		public var maxDuration:Number = 1.3;
		
		/**  Average duration per item length */
		public var itemLengthDuration:Number = .5;  
		
		/** Defaulted to <code>Strong.easeOut</code>. */
		public var ease:Function = Strong.easeOut;
		private var scrollEvent:Event = new Event(Event.SCROLL);
		public var onUpdate:Function;
		public var onUpdateParams:Array;
		public var onComplete:Function;
		public var onCompleteParams:Array;
		
		public function SnapTweenScrollProxy(targ:IScrollable) {
			super(targ);
		}
		
		override public function set scrollH (ratio:Number):void {
			var dest:Number = _x + getDestScrollH(ratio);
			var tarDuration:Number = (diffX(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			var $onUpdate:Function = onUpdate!=null ? onUpdate:  scrollContainer.dispatchEvent;
			var $onUpdateParams:Array = onUpdate!=null ? onUpdateParams : [scrollEvent];
			var $onComplete:Function = onComplete!=null ? onComplete : scrollContainer.dispatchEvent;
			var $onCompleteParams:Array = onComplete!=null ? onCompleteParams : [scrollEvent];
			TweenLite.to(scrollContent, tarDuration, { x:dest, ease:ease, onUpdate:$onUpdate, onUpdateParams:$onUpdateParams, onComplete:$onComplete, onCompleteParams:$onCompleteParams } );
		}
		override public function set scrollV (ratio:Number):void {
			var dest:Number = _y + getDestScrollV(ratio);
			var tarDuration:Number = (diffY(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			var $onUpdate:Function = onUpdate!=null ? onUpdate:  scrollContainer.dispatchEvent;
			var $onUpdateParams:Array = onUpdate!=null ? onUpdateParams : [scrollEvent];
			var $onComplete:Function = onComplete!=null ? onComplete : scrollContainer.dispatchEvent;
			var $onCompleteParams:Array = onComplete!=null ? onCompleteParams : [scrollEvent];
			TweenLite.to(scrollContent, tarDuration, { y:dest, ease:ease, onUpdate:$onUpdate, onUpdateParams:$onUpdateParams, onComplete:$onComplete, onCompleteParams:$onCompleteParams } );
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