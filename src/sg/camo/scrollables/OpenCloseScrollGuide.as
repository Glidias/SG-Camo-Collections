package sg.camo.scrollables 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import sg.camo.interfaces.IOpenScrollProxy;
	import sg.camo.interfaces.IScrollable;
	
	
	/**
	* Helper base class for OpenCloseScrollProxies to retrieve targetted scroll destination distances
	* based on supplied scroll ratios. The helper methods are under protected namespace.
	* 
	* @see sg.camo.interfaces.OpenCloseScrollProxy
	* 
	 * @author Glenn Ko
	 */
	public class OpenCloseScrollGuide extends BaseScrollProxy implements IOpenScrollProxy
	{
		protected var _openReverseDirection:Boolean = false;
		
		
		public function OpenCloseScrollGuide(targ:IScrollable) 
		{
			super (targ);
		}
		
		
		public function get openReverseDirection():Boolean {
			return _openReverseDirection;
		}
		public function set openReverseDirection(boo:Boolean):void {
			 _openReverseDirection = boo;
		}
		
		// Ratio:  
		//  1 and -1 means fully opened (in upper & lower vector direction respectively)
		// and  0 means fully closed
		
		public function getDestScrollH(ratio:Number):Number {
			var w:Number = Math.round(scrollContent.width);
			var initial:Number = _openReverseDirection ? w : -w;
			return initial +  ratio * w + _x; 
		}
		public function getDestScrollV(ratio:Number):Number {
			var h:Number = Math.round(scrollContent.height); 
			var initial:Number = _openReverseDirection ? h : -h;
			return initial + ratio * h + _y;  //
		}
		
		override public function resetScroll():void {
			//scrollContent.x = getDestScrollH(0);
			//scrollContent.y = getDestScrollV(0);
		}
		
	}
	
}