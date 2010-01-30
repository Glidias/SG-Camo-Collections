package sg.camo.scrollables {
	
	import sg.camo.interfaces.IScrollable;
	/**
	* Helper base class for ScrollProxies to retrieve targetted scroll destination distances
	* based on supplied scroll ratios. The helper methods are under protected namespace.
	* 
	* @author Glenn Ko
	*/
	public class ScrollGuide extends BaseScrollProxy {
		
		public function ScrollGuide(targ:IScrollable) {
			super(targ);
		}
		
		/**
		 * Gets relative horizontal X distance travelled based on supplied ratio
		 * @param	ratio
		 * @return
		 */
		protected function getDestScrollH (ratio:Number):Number {
			var w:Number = scrollContent.width - scrollMask.width;
			return  -(ratio * w);
		}
		
		/**
		 * Gets relative vertical  Y distance travelled based on supplied ratio
		 * @param	ratio
		 * @return
		 */		
		protected function getDestScrollV(ratio:Number):Number {
			var h:Number = scrollContent.height - scrollMask.height;
			return  -(ratio * h);
		}
		/** @private */
		protected function  diffX(destX:Number):Number {
			return scrollContent.x > destX ? scrollContent.x - destX : destX - scrollContent.x;
		}
		/** @private */
		protected function  diffY(destY:Number):Number {
			return scrollContent.y > destY ? scrollContent.y - destY : destY - scrollContent.y;
		}
		
	}
	
}