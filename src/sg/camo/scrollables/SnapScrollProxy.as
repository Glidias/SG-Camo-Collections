package sg.camo.scrollables {
	import sg.camo.interfaces.IScrollable;
	
	/**
	* Instant "snap to item-length" scrolling implementation without any tweening.
	* 
	* @see sg.camo.scrollables.gs.SnapTweenScrollProxy
	* 
	* @author Glenn Ko
	*/
	public class SnapScrollProxy extends SnapGuide {
		
		public function SnapScrollProxy(targ:IScrollable) {
			super(targ);
		}
		
		override public function set scrollH (ratio:Number):void {
			scrollContent.x = _x + getDestScrollH(ratio);
		}
		override public function set scrollV (ratio:Number):void {
			scrollContent.y = _y + getDestScrollV(ratio);
		}
		

		
	}
	
}