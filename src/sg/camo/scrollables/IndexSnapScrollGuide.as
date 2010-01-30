package sg.camo.scrollables {
	
	import flash.events.Event;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IScrollable;
	/**
	* Base helper class and scrollGuide that moves scroll content by it's total length without considering mask.
	* <br/><br/>
	* This class is also <i>IIndexable</i> and allows extended classes to scroll content by index.
	* 
	* @author Glenn Ko
	*/
	public class IndexSnapScrollGuide extends BaseScrollProxy implements IIndexable {
		
		protected var _index:int = -1;
		
		/**
		 * Whether to snap scroll content within ending view bounds of scroll mask, 
		 * so that scroll content doesn't go all the way back by it's total length.
		 * <br/>
		 * If no scrollMask is found upon activation, this flag automatically is set to false.
		 */
		public var capView:Boolean = true;
		

		/**
		 * Gets current snap index
		 * @return
		 */
		public function getIndex():int {
			return _index;
		}
		
		/**
		 * Performs scrolling based on index value
		 * @param	id	The index value to supply
		 */
		public function setIndex(id:int):void {
			if (isVertical) {
				scrollV  = (itemLength * id) / scrollContent.height;
			}
			else {
				scrollH = (itemLength * id) / scrollContent.width;
			}
			
		}
		
		/**
		 * Determines current direction for index scrolling. This property is context-based by default and changes 
		 * based on the last retreieved direction unless <code>lockDirection</code> is set to <code>true</code>.
		 *  
		 * Set this to <code>false</code> to allow indexing to scroll horizontally and set this to 
		 * <code>true</code> to allow indexing to scroll vertically.
		 */
		public var isVertical:Boolean = true;
		/**
		 * Locks current direction for index scrolling, so it doesn't change even if other directions are retrieved
		 * from the scroll guide. This would restrict indexing to a single direction regardless of any situation.
		 */
		public var lockDirection:Boolean = false;


		public function IndexSnapScrollGuide(targ:IScrollable) {
			super(targ);
		}
		
		/**
		 * If scrollMask is detected to be null during activation of scroll target, than
			<code>capView</code> is automatically set to false to prevent errors during scrolling. 
			Otherwise the current <code>capView</code> setting is kept.
		 */
		override public function set target(targ:IScrollable):void {
			super.target = targ;
			if (targ.scrollMask == null) capView = false;
		}
		
		/**
		 * Retrieves horizontal destination scroll value based on ratio. Also sets snap index if allowed.
		 * @param	ratio
		 * @return
		 */
		protected function getDestScrollH (ratio:Number):Number {
			var toSnap:Number =  -(ratio * scrollContent.width);  //return toSnap;
			var magSnap:Number = toSnap < 0 ? -toSnap : toSnap;
			toSnap = !capView ? toSnap :   toSnap  < scrollMask.width - scrollContent.width ?   scrollMask.width - scrollContent.width : toSnap; 
			_index = lockDirection ? !isVertical ?   int(magSnap / itemLength) : _index : int(magSnap / itemLength);
			var rem:Number = magSnap  % itemLength;
			var floor:Boolean = ratio == 0 ? true : ratio == 1 ?  false : rem < itemLength * .5; 
			rem = floor  ? rem : itemLength - rem;
			var vec:int = floor ? -1 : 1;
			isVertical = lockDirection ? isVertical : false;
			return itemLength > 0 ?   toSnap - vec * rem : toSnap;
		}
		
		/**
		 * Retrieves vertical destination scroll value based on ratio. Also sets snap index if allowed.
		 * @param	ratio
		 * @return
		 */
		protected function getDestScrollV(ratio:Number):Number {
			var toSnap:Number =  -(ratio * scrollContent.height);  //return toSnap;
			toSnap = !capView ? toSnap :   toSnap  < scrollMask.height - scrollContent.height ?   scrollMask.height - scrollContent.height : toSnap; 
			var magSnap:Number = toSnap < 0 ? -toSnap : toSnap;
			_index = lockDirection ? isVertical ? int(magSnap / itemLength) : _index  : int(magSnap / itemLength);
			var rem:Number = magSnap  % itemLength;
			var floor:Boolean = ratio == 0 ? true : ratio == 1 ?  false : rem < itemLength * .5; 
			rem = floor  ? rem : itemLength - rem;
			var vec:int = floor ? -1 : 1;
			isVertical = lockDirection ? isVertical : true;
			return itemLength > 0 ?   toSnap - vec * rem : toSnap;
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