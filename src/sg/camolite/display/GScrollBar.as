package sg.camolite.display {
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IAncestorSprite;
	import sg.camo.interfaces.ICustomScroll;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IScroll;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.interfaces.IScrollBarUI;
	import sg.camo.interfaces.ITextField;
	import sg.camo.scrollables.DefaultScrollProxy;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import flash.events.FocusEvent;

	import sg.camo.events.OverflowEvent;
	import camo.core.events.CamoDisplayEvent;
	
	import sg.camo.SGCamoSettings;
	
	/**
	* Extended GScroller to support concrete scrollbar implementation.
	* @author Glenn Ko
	*/
	public class GScrollBar extends GScroller implements IScrollBarUI {
		
		
		/** @private */ protected var _scrollUp:InteractiveObject; 
		/** @private */ protected var _scrollDown:InteractiveObject; 
		
		/** @private */ protected var _pressDirection:Boolean = false;
		
		/** @private */ protected var _scrollableTarget:IScrollable;
		
		/** @private */ protected var _customScroll:ICustomScroll;
		/** @private */  protected var _customContentDispatcher:IEventDispatcher;
		
		// --Time Settings/trackers for buttons in ScrollBar (if found avaiable)
		/** @private */ protected var _holdTimer:Timer;
		/** @private */ protected var _holdCount:int = 1;
		/** @private */ protected var _holdInterval:Number=50; // in mileseconds
		/** @private */ protected var _moveTimer:Timer;  
		/** @private */ protected var _moveCount:int = 1;
		/** @private */ protected var _moveInterval:Number = 50; // in mileseconds
		
		// Scroll amount per press movement distance for scrubber
		public var scrollAmount:Number = 10;
		// Starting scroll content positions
		/** @private */ protected var _x:Number = 0;
		/** @private */ protected var _y:Number = 0;

		// -- 
		/** @private */ protected var _scrollContainer:DisplayObject;
		/** @private */ protected var _uStage:Stage; // stage reference marker for releaseOutside handler for scroll button 
		/** @private */ protected var _fStage:Stage; // stage reference marker for mouseWheel handler
		
		/** @private */ protected var _overflowAuto:Boolean = false;
		/** @private */ protected var _overflowDisabled:Boolean = false;
		/** @private */ protected var hideScrollbar:Boolean = false;

		/** @private */ protected var _autoFit:Boolean = false; // whether to fit scrollbar width/height to scroll contaner
		/** @private */ protected var _autoFitScrub:Boolean = false; // whether to fit scroll scrub to scroll track
		
		/** @private */ protected var _defaultScrollProxy:DefaultScrollProxy = new DefaultScrollProxy();
		
		public function GScrollBar() {
			super();
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GScrollBar;
		}
		
		override public function set rotation(val:Number):void {
			super.rotation = val;
			if (val == -90 || val == 90) {
				isHorizontal = true;
			}
		}
		
		override public function set visible(value:Boolean):void {
			super.visible = value;
			/*if (!value) {
				hideScrollbar = true;
			}*/
			
			hideScrollbar = !value;
			//contentUpdateHandler();
		}
		
		/** @private */
		protected function set $visible(value:Boolean):void {
			super.visible = value;
		}
		
		/** <b>[Staged instance]</b> to setup scroll-up button */
		public function set scrollUp(obj:InteractiveObject):void {
			if (_scrollUp != null) destroyScrollBtn(_scrollUp);
			_scrollUp = obj;
			setupScrollBtn (obj);

			setTimers ();
		}
		public function get scrollUp():InteractiveObject {
			return _scrollUp;
		}
		
		/** <b>[Staged instance]</b> to setup scroll-down button */
		public function set scrollDown(obj:InteractiveObject):void {
			//trace("Setting scroll down..");
			if (_scrollDown != null) destroyScrollBtn(_scrollDown);
			_scrollDown = obj;
			setupScrollBtn (obj);
			setTimers ();
		}
		public function get scrollDown():InteractiveObject {
			return _scrollDown;
		}
		
		/**
		 * @private
		 */
		override protected function destroyScrollTarget():void {
			if (_scrollableTarget!=null) {
				var func:Function = getValidRemoveListener(_scrollableTarget);
				func(CamoDisplayEvent.DRAW, contentUpdateHandler);
				func(OverflowEvent.NAME, changeOverflowHandler);
				_scrollableTarget = null;
			}
			super.destroyScrollTarget();
		}
		
		
		/**
		 * Sets up IScrollable target.
		 */
		override public function set scrollTarget (scr:IScroll):void {

			super.scrollTarget = scr;
		
			
			_scrollableTarget = _scrollTarget as IScrollable;
			if (_scrollableTarget == null) {
				trace("GScrollBar set scrollTarget() halt.  ScrollTarget as IScrollable is null!")
				if (_scrollTarget is ICustomScroll) {
					_customScroll = _scrollTarget as ICustomScroll;
					if ( (_scrollTarget as ICustomScroll).contentUpdateDispatcher != null) {
						_customContentDispatcher = (_scrollTarget as ICustomScroll).contentUpdateDispatcher;
						_customContentDispatcher.addEventListener(CamoDisplayEvent.DRAW, contentUpdateHandler, false, 0, true);
					}
				}
				_defaultScrollProxy.destroy();
				return;
			}
			
			
			_x = _scrollableTarget.scrollContent.x;
			_y = _scrollableTarget.scrollContent.y;
			_defaultScrollProxy.target = _scrollableTarget;
			
			var func:Function = getValidAddListener(_scrollableTarget);
			func(OverflowEvent.NAME, changeOverflowHandler, false, 0, true);
			func(CamoDisplayEvent.DRAW, contentUpdateHandler, false, 0, true);
			if (_scrollableTarget.scrollContainer != null) setupScrollContainer(_scrollableTarget.scrollContainer);
			//updateScrollbar(); // commented away LONg ago..
		}	
		
		/**
		 * When received an OverflowEvent from scrollable target, checks overflow value and handles it accordingly.
		 * @param	e	OverflowEvent with specific value
		 */
		protected function changeOverflowHandler(e:OverflowEvent):void {
			var value:int = e.value;
			_overflowAuto = true;
			switch (value) {
				case OverflowEvent.AUTO: handleOverflowAuto();    break;
				case OverflowEvent.HIDDEN: handleOverflowHidden(); break;
				case OverflowEvent.NONE: handleOverflowNone(); break;
				case OverflowEvent.SCROLL: handleOverflowScroll();  break;
			}
		}
		
		// IScrollBarUI
		
		/**
		 * Call a content update on the scrollbar directly
		 */
		public function updateScrollbar():void {
			if (!contentHigherThanMask) return;
			var property:String = !isHorizontal ? "height" : "width";
			var scrollContent:DisplayObject = _scrollableTarget.scrollContent;
			
			var h:Number;
			var ratio:Number
			
			if (!isHorizontal) {
				h = Math.round(scrollContent.height - _scrollableTarget.scrollMask.height);
				ratio = -( (scrollContent.y - _y) / h ) ;
				ratio = ratio > 1 ? 1 : ratio;
				ratio = ratio < 0 ? 0 :ratio;
				_scrollScrub.y = _scrubStartY + ratio * (_scrollableHeight );	
			}
			else {
				h = Math.round(scrollContent.width - _scrollableTarget.scrollMask.width);
				ratio = -( (scrollContent.x - _x) / h ) ;
				ratio = ratio > 1 ? 1 : ratio;
				ratio = ratio < 0 ? 0 :ratio;
				_scrollScrub.y = _scrubStartY + ratio * (_scrollableHeight);
			}
			
			_scrollScrub.y = _scrollScrub.y < _scrollBounds.y ?  _scrollBounds.y : _scrollScrub.y;
			
			
		}
		

		/**
		 * Flag to determine whether to auto-size scroll track with scroll mask's dimensions
		 */
		public function set autoFit(fit:Boolean):void {
			_autoFit = fit;
		}
		/**
		 * 
		 */
		public function get autoFit():Boolean {
			return _autoFit;
		}
		
		/**
		 * Flag to determine whether whether scroll scrubber resizes to match content size with mask.
		 */
		public function set autoFitScrub(fit:Boolean):void {
			_autoFitScrub = fit;
		}
		/**
		 * 
		 */
		public function get autoFitScrub():Boolean {
			return _autoFitScrub;
		}

		/**
		 * Resets scrollbar scrub position and scroll target's values
		 */
		public function resetScrollbar():void {
			scrollScrub.y = _scrubStartY;
			scrubMove();
			var chkTarget:IScrollable = _defaultScrollProxy.target; //|| _scrollableTarget;
			if (chkTarget != null) {
				if (isHorizontal) chkTarget.scrollH = 0
				else chkTarget.scrollV = 0;
			}
			else if (_customScroll != null) {
				if (isHorizontal) _customScroll.scrollH = 0
				else _customScroll.scrollV = 0;
			}
		}
		
		/**
		 * Hides and resets scroll bar if content length doesn't exceed mask.
		 * @return  Whether scroll is enabled or not
		 */
		protected function handleOverflowAuto():Boolean {
			_overflowAuto = true;
			_overflowDisabled = false;
		
			
			var gotScroll:Boolean = contentHigherThanMask;
			
			alpha = gotScroll  ? 1 : .5;
			
			$visible = hideScrollbar ? false : gotScroll;
			mouseEnabled = !visible ? false : gotScroll;
			mouseChildren = !visible ? false : gotScroll;
			if (!gotScroll) {
				if (_prevGotScroll!=gotScroll) resetScrollbar();
			}
			_prevGotScroll = gotScroll;
			checkItemLength();
			return gotScroll;
		}
		
		/** @private */
		protected var _prevGotScroll:Boolean = false;

		/**
		 * Always show scrollbar but resets and fade-disable it if content length doesn't exceed mask.
		 * @return  Whether scroll is enabled or not
		 */
		protected function handleOverflowScroll():Boolean {
			_overflowAuto = false;
			_overflowDisabled = false;
			
			var gotScroll:Boolean = contentHigherThanMask;
			alpha = gotScroll  ? 1 : .5;
			
			$visible = hideScrollbar ? false : true;
			mouseEnabled = !visible ? false : gotScroll;
			mouseChildren = !visible ? false : gotScroll;
			if (!gotScroll) {
				if (_prevGotScroll!=gotScroll) resetScrollbar();
			}
			_prevGotScroll = gotScroll;
			checkItemLength();
			return gotScroll;
		}
		/**
		 * Hides scrollbar and resets it.
		 */
		protected function handleOverflowHidden():void {
			$visible = false;
			_overflowDisabled = true;
			_prevGotScroll = false;
			//resetScrollbar();		
		}
		/**
		 *  Hides scrollbar and resets it.
		 */
		protected function handleOverflowNone():void {
			$visible = false;
			_overflowDisabled = true;
			_prevGotScroll = false;
			//resetScrollbar();
		}
		

		/**
		 * Received during any CamoDisplayEvent.DRAW event received from IScrollable target
		 * @param	e
		 */
		protected function contentUpdateHandler(e:Event):void {
		
			var gotScroll:Boolean = _overflowDisabled ? false : _overflowAuto ? handleOverflowAuto() : handleOverflowScroll();

			if (_scrollableTarget == null) return;
	
			if (_autoFit && visible ) {
				var prop:String = isHorizontal ? "width" : "height";
				var propX:String = isHorizontal ? "x" : "y";
				var mH:Number = _scrollableTarget.scrollContent is ITextField ?  (_scrollableTarget.scrollContent as ITextField).textField[prop] :   _scrollableTarget.scrollMask[prop];
				
				var tarHeight:Number = mH; //mH - (this[propX] - _scrollableTarget.scrollMask[propX])*2;
				
				//if (_prevScrollMaskHeight != tarHeight) {
					height = tarHeight;
					//_prevScrollMaskHeight = tarHeight;
					setBounds();
				//}

			}
			else if (_autoFitScrub && visible) {
				setBounds();
			}
			/*
							
					height = tarHeight;
					setBounds();
				}
			*/
			
			updateScrollbar();  // commented off #2 13 Nov
			
			if (_scrollableTarget.scrollContent is ITextField) return;
			if (gotScroll) scrubMove(_defaultScrollProxy);
		}
		
		/** @private */
		protected function getValidRemoveListener(targ:IScrollable):Function {
			return	targ.removeEventListener;
		}
		
		/** @private */
		protected function getValidAddListener(targ:IScrollable):Function {
			return	 targ.addEventListener;
		}
	
		/** @private */
		protected function setupScrollContainer (targ:Sprite):Sprite {
			

			//func (FocusEvent.FOCUS_IN, focusInHandler, false, 0, true);
			//func (FocusEvent.FOCUS_OUT, focusOutHandler, false, 0, true);
			targ.addEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
			//addEventListener (FocusEvent.FOCUS_IN, focusInHandler, false, 0, true);
		//	addEventListener (FocusEvent.FOCUS_OUT, focusOutHandler, false, 0, true);
		//	addEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
			return targ;
			
		}
		/** @private */
		override protected function setupScrollTrack(targ:Sprite):Sprite {
			targ = super.setupScrollTrack(targ);
			//var func:Function = targ.addEventListener;
			targ.addEventListener(MouseEvent.MOUSE_DOWN, scrollTrackPressHandler, false, 0, true); 
			return targ;
		}
		/** @private */
		override protected function destroyScrollTrack(targ:Sprite):void {
			//var func:Function =  targ.removeEventListener;
			targ.removeEventListener(MouseEvent.MOUSE_DOWN, scrollTrackPressHandler); 
			super.destroyScrollTrack(targ);
		}
		/** @private */
		protected function destroyScrollContainer ():Sprite {
			var func:Function = _scrollContainer.removeEventListener;
		//	func (FocusEvent.FOCUS_IN, focusInHandler, false);
		//	func (FocusEvent.FOCUS_OUT, focusOutHandler, false);
			func (MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false);
			removeEventListener (FocusEvent.FOCUS_IN, focusInHandler, false);
			removeEventListener (FocusEvent.FOCUS_OUT, focusOutHandler, false);
			//removeEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false);
			_scrollContainer = null;
			return null;
		}


		// -- Destructor
		
		override public function destroy ():void {
			if (_holdTimer != null) {
				_holdTimer.stop ();
				_holdTimer.removeEventListener (TimerEvent.TIMER, holdTimerHandler);
				_moveTimer.removeEventListener (TimerEvent.TIMER, moveTimerHandler);
				_moveTimer.stop ();
			}
			if (_uStage != null) {
				_uStage.removeEventListener (MouseEvent.MOUSE_UP, scrollButtonReleaseOutsideHandler);
				_uStage = null;
			}
			if (_fStage != null) {
				_fStage.removeEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
				_fStage = null;
			}
			
			if (_scrollContainer != null) destroyScrollContainer ();
			
			//_scrollableTarget._removeEventListener(OverflowEvent.NAME, overflowHandler);
		
			if (_customContentDispatcher != null) {
				_customContentDispatcher.removeEventListener(CamoDisplayEvent.DRAW, contentUpdateHandler);
			}
			_customScroll = null;
			_customContentDispatcher = null;

			if (_scrollUp != null) destroyScrollBtn (_scrollUp);
			if (_scrollDown != null) destroyScrollBtn (_scrollDown);
			_scrollUp = null;
			_scrollDown = null;
			
			_defaultScrollProxy.destroy();
			
			super.destroy();
			
			
		}
		
		/**
		 * Sets scroll track height
		 */
		override public function set height(value:Number):void {
			if (_scrollTrack == null) return;
			
			if (_scrollTrack.height != value) {
			//	var diff:Number = value - _scrollTrack.height;
				_scrollTrack.height = value;
				setBounds();
			//	scrRect.bottom -=diff;
			//	_scrollBounds.bottom 	= scrRect.bottom - _scrubberHeight;
			//	_scrollableHeight = _scrollBounds.bottom - _scrollBounds.top;
			}
		}
		
		/**
		 * Sets how long it takes (in miliseconds) after pressing a scroll button to begin scrolling content.
		 */
		public function set holdInterval(val:Number):void {
			_holdInterval = val;
			if (_holdTimer!=null && val > 0) _holdTimer.delay = val;
		}
		public function get holdInterval():Number {
			return holdInterval;
		}
		
		/**
		 * Sets how long it takes (between miliseconds) to trigger each scroll move by holding a scroll button.
		 */
		public function set moveInterval(val:Number):void {
			 _moveInterval = val;
			if (_moveTimer != null && val > 0) _moveTimer.delay = val;
			
		}
		public function get moveInterval():Number {
			 return moveInterval;
		}
		
			
		// Hookup functions
		
		/** @private */
		protected function setTimers ():void {
			if (_holdTimer != null) return;
			_holdTimer = new Timer(_holdInterval);
			_moveTimer = new Timer (_moveInterval);
			_holdTimer.addEventListener (TimerEvent.TIMER, holdTimerHandler, false, 0, true);
			_moveTimer.addEventListener (TimerEvent.TIMER, moveTimerHandler, false ,0, true);
		}
		

		/** @private */
		override protected function setBounds():void {
			if (_autoFitScrub ) {
				var propHeight:String = isHorizontal ? "width" : "height";
			//	trace("Auto fitting scrub");
				_scrubberHeight = (_scrollableTarget.scrollMask[propHeight] / _scrollableTarget.scrollContent[propHeight]) * _scrollTrack.height;
				_scrubberHeight = _scrubberHeight > _scrollTrack.height ? _scrollTrack.height : _scrubberHeight; 
				_scrollScrub.height = _scrubberHeight
			}	
			super.setBounds();
			if (_scrollableTarget != null) checkItemLength();
		}

		/** @private */
		protected function setupScrollBtn (targ:InteractiveObject):InteractiveObject {
			var func:Function = targ.addEventListener; // targ is IAncestorSprite ? (targ as IAncestorSprite).addEventListener : targ.addEventListener;
			func(MouseEvent.MOUSE_DOWN, scrollButtonHandler, false, 0, true);
			func(MouseEvent.CLICK, scrollButtonReleaseHandler, false, 0, true); 
			if (targ is Sprite) (targ as Sprite).mouseChildren = false;
			return targ;
		}
		/** @private */
		protected function destroyScrollBtn (targ:InteractiveObject):void {
			var func:Function = targ.removeEventListener;
			func(MouseEvent.MOUSE_DOWN, scrollButtonHandler);
			func(MouseEvent.CLICK, scrollButtonReleaseHandler); 
		}
		
	
		
		// -- Protected helpers
		
		/** @private */
		protected function get contentLowerThanMask():Boolean {
			return isHorizontal ? _scrollableTarget.scrollContent.x < _x : _scrollableTarget.scrollContent.y < _y;
		}
		
		/** @private */
		protected function get contentHigherThanMask():Boolean {
		
			if (_scrollableTarget != null) {
				var property:String = !isHorizontal ? "height" : "width";
				var h:Number;
				var contentMask:Object = _scrollableTarget.scrollMask;
				h = contentMask[property];
				return (_scrollableTarget.scrollContent[property] > h);
			}
			else if (_scrollTarget is ICustomScroll) {
				property  = isHorizontal ? "hScrollable" : "vScrollable";
				return (_scrollTarget as ICustomScroll)[property];
			}
			else {
				return true;
			}
		}
		

		
		

		
		// -- Timer handlers
		
		
		private function holdTimerHandler(e:TimerEvent):void {
			if (_holdTimer.currentCount >= _holdCount) {
				_moveTimer.start();
			}
		}
		
		private function moveTimerHandler(e:TimerEvent=null):void {
			if (!contentHigherThanMask ) return;
			if (_scrollScrub.y > _scrollBounds.top || _scrollScrub.y < _scrollBounds.bottom) {
				_scrollScrub.y += _pressDirection ? -scrollAmount : scrollAmount;
				if (_scrollScrub.y < _scrollBounds.top)
					_scrollScrub.y = _scrollBounds.top;
				else if (_scrollScrub.y > _scrollBounds.bottom)
					_scrollScrub.y = _scrollBounds.bottom;
			}
			scrubMove();
		}
		

		
		// -- Mouse Handlers
		
		/** @private */
		protected function scrollButtonHandler (e:MouseEvent):void {
			e.stopPropagation ();
			
			_pressDirection = e.currentTarget === _scrollUp;
			stage.addEventListener (MouseEvent.MOUSE_UP, scrollButtonReleaseOutsideHandler, false , 0, true);
			_uStage = stage;
			if (_holdInterval > 0) _holdTimer.start ()
			else {
				moveTimerHandler();
				_moveTimer.start();	
			}
			

		}
		/** @private */
		protected function scrollButtonReleaseHandler (e:MouseEvent):void {
			e.stopImmediatePropagation ();
			stage.removeEventListener (MouseEvent.MOUSE_UP, scrollButtonReleaseOutsideHandler, false);
			_moveTimer.stop();
			_holdTimer.stop();
			_holdTimer.reset ();
			_uStage = null;
		}
		/** @private */
		protected function scrollButtonReleaseOutsideHandler (e:MouseEvent):void {
			stage.removeEventListener (MouseEvent.MOUSE_UP, scrollButtonReleaseOutsideHandler, false);
			_moveTimer.stop();
			_holdTimer.stop();
			_holdTimer.reset ();
			_uStage = null;
		}
		/** @private */
		protected function scrollTrackPressHandler (e:MouseEvent):Boolean {
		//	trace("PRessing");
			e.stopImmediatePropagation ();
			if ( !contentHigherThanMask ) return false;  // to do, skip check?
			var scrollFactor:Number =  (mouseY - _scrollBounds.top) / _scrollableHeight;
			scrollFactor = Math.floor(scrollFactor * 100) / 100;
				
			_scrollScrub.y = scrollFactor < 1 ?  (scrollFactor * _scrollableHeight) + _scrollBounds.top : _scrollBounds.top + _scrollableHeight;
			scrubMove();
			return true;
		}
	

		
		/** @private */
		protected function mouseWheelHandler (e:MouseEvent):void {
			e.stopImmediatePropagation ();
			if ( !contentHigherThanMask || !mouseEnabled ) return;

			if (_scrollScrub.y > _scrollBounds.top || _scrollScrub.y < _scrollBounds.bottom) {
				var deltaCap:Number = e.delta > 1 ? 1 : e.delta < -1 ? -1 : e.delta;
				_scrollScrub.y -= deltaCap * scrollAmount;
				//trace(deltaCap);
				if (_scrollScrub.y < _scrollBounds.top)
					_scrollScrub.y = _scrollBounds.top;
				else if (_scrollScrub.y > _scrollBounds.bottom)
					_scrollScrub.y = _scrollBounds.bottom;
					
				scrubMove();
			}
		}
		/** @private */
		protected function focusInHandler (e:MouseEvent):void {
			if (_fStage != null) return;
			//trace ("IN");
			_fStage = stage;
			stage.addEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false, 0, true);
			
		}
		/** @private */
		protected function focusOutHandler (e:MouseEvent):void {
			//trace ("OUT");
			_fStage.removeEventListener (MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			_fStage = null;
		}
		
		/**
		 * Re-checks and updates item length of scrollable target (this is also automatically called when the scrollbar
		 * handles overflow updates for OverflowEvent.AUTO and OverflowEvent.SCROLL.)
		 */
		public function checkItemLength():void {
			//if ( _scrollableTarget.itemLength < 1) return;
			
			var isp:Number = _scrollableTarget.itemLength;
			if ( !(isp > 0) ) {
				scrollAmount = 5;
				return;
			}
		
			var prop:String =  isHorizontal ? "width" : "height";
			//	trace(isp, _scrollableTarget.scrollContent[prop]);
			scrollAmount = (isp / _scrollableTarget.scrollContent[prop]) * (_scrollableHeight);
			
			if (isNaN(scrollAmount))
				scrollAmount = 5;
				

		}
		
	}
	
}