package sg.camolite.display {
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	* Extended page display to allow hooking up of "next" and "prev" buttons.
	* @author Glenn Ko
	*/
	public class GPageButtonerDisplay extends GPageDisplay {
		
		/**
		 * Next button reference (if any)
		 */	
		protected var _btnNext:InteractiveObject;
		/**
		 * Prev button reference (if any)
		 */
		protected var _btnPrev:InteractiveObject;
		
		public function GPageButtonerDisplay() {
			super();
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GPageButtonerDisplay;
		}
		
		
		/**
		 * Overwritten key  method for going to a particular page by index. 
		 * Also updates button states if page switching is successful.
		 * @param	index
		 * @return
		 */
		override public function gotoPage(index:int):Boolean {
			var success:Boolean =  super.gotoPage(index);
			if (success) updateBtnStates();
			return success;
		}
		
		override public function destroy():void {
			super.destroy();
			if (_btnNext != null) {
				_btnNext.removeEventListener(MouseEvent.CLICK, nextPageHandler);
				_btnNext = null;
			}
			if (_btnPrev != null) {
				_btnPrev.removeEventListener(MouseEvent.CLICK, prevPageHandler);
				_btnPrev = null;
			}
		}
		
		/**
		 * <b>Stage instance</b> to set up "next" button.
		 */
		public function set btn_next(spr:InteractiveObject):void {
			spr.visible = false;
			_btnNext = spr;
			spr.addEventListener(MouseEvent.CLICK, nextPageHandler, false, 0, true);
		}
		
		/**
		 * <b>Stage instance</b> to set up "prev" button.
		 */
		public function set btn_prev(spr:InteractiveObject):void {	
			spr.visible = false;
			_btnPrev = spr;
			spr.addEventListener(MouseEvent.CLICK, prevPageHandler, false, 0, true);
		}
		/**
		 * Goes to next page after "next" page button is clicked
		 * @param	e	In response to a MouseEvent.CLICK
		 */
		protected function nextPageHandler(e:Event):void {
			nextPage();
		}
		
		/**
		 * Goes to prev page after "prev" page button is clicked
		 * @param	e	In response to a MouseEvent.CLICK
		 */
		protected function prevPageHandler(e:Event):void {
			prevPage();
		}
		
		/**
		 * Automatically updates button states' visibility to to whether there's a
		 * previous/next page available in the page array list.
		 */
		protected function updateBtnStates():void {
			if (_btnNext != null) _btnNext.visible = _curPageIndex + 1 < _pageArr.length;
			if (_btnPrev!=null) _btnPrev.visible =  _curPageIndex - 1 >  -1;
		}

		
	}
	
}