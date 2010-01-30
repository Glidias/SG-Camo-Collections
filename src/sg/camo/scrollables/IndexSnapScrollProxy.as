package sg.camo.scrollables
{
	import sg.camo.interfaces.IScrollable;
	/**
	 * Snaps immediately to IndexSnapScrollGuide without any tweening.
	 * 
	 * @see sg.camo.scrollables.gs.IndexTweenScrollProxy
	 * @see sg.camo.scrollables.IndexSnapScrollGuide
	 * 
	 * @author Glenn Ko
	 */
	public class IndexSnapScrollProxy extends IndexSnapScrollGuide
	{
		
		public function IndexSnapScrollProxy(targ:IScrollable) 
		{
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