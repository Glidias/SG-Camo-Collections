package sg.camo.scrollables 
{
	import sg.camo.interfaces.IScrollable;
	
	/**
	* Default IScrollProxy implementation  (ie. no tweening/snapping of scroll content).
	* 
	* @see sg.camo.scrollables.gs.TweenScrollProxy
	* 
	* @author Glenn Ko
	*/
	public class DefaultScrollProxy extends BaseScrollProxy
	{
		public function DefaultScrollProxy(targ:IScrollable=null) 
		{
			super(targ);
		}
		override public function set scrollH (ratio:Number):void {
			var w:Number = Math.round(scrollContent.width - scrollMask.width );  //
			scrollContent.x = _x + Math.round(- (ratio * w));
		}
		override public function set scrollV (ratio:Number):void {
			var h:Number = Math.round(scrollContent.height - scrollMask.height);  //
			scrollContent.y = _y + Math.round(- (ratio * h));
		}
		
	}
	
}