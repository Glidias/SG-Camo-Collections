package sg.camo.scrollables.gs {
	
	import sg.camo.interfaces.IScrollable;
	import sg.camo.scrollables.IndexSnapScrollGuide;
	import gs.TweenLite;
	import gs.easing.Strong;
	
	/**
	* Snaps to IndexSnapScrollGuide with tweening.
	* 
	* @see sg.camo.scrollables.IndexSnapScrollGuide
	* 
	* @author Glenn Ko
	*/
	public class IndexTweenScrollProxy extends IndexSnapScrollGuide {
		
		public var maxDuration:Number = 1.3;
		public var itemLengthDuration:Number = .5;  // average duraiton per item
		public var ease:Function = Strong.easeOut;
		public var onUpdate:Function = null;
		
		public function IndexTweenScrollProxy(targ:IScrollable=null) {
			super(targ);
		}
		
		override public function set scrollH (ratio:Number):void {
			var dest:Number = _x + getDestScrollH(ratio);
			var tarDuration:Number = (diffX(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			TweenLite.to(scrollContent, tarDuration, { x:dest, ease:ease, onUpdate:onUpdate } );
		}
		override public function set scrollV (ratio:Number):void {
			var dest:Number = _y + getDestScrollV(ratio);
			var tarDuration:Number = (diffY(dest) / itemLength) * itemLengthDuration;
			tarDuration = tarDuration > maxDuration ? maxDuration : tarDuration;
			TweenLite.to(scrollContent, tarDuration, { y:dest, ease:ease, onUpdate:onUpdate } );
		}
		
		override public function resetScroll():void {
			TweenLite.killTweensOf(scrollContent);
			super.resetScroll();
		}
		
		override public function destroy():void {
			TweenLite.killTweensOf(scrollContent);
			onUpdate = null;
			super.destroy();
		}
		
	}
	
}