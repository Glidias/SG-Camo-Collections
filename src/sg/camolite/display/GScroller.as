package sg.camolite.display 
{
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.interfaces.IScroller;
	import sg.camo.interfaces.IScroll;
	import sg.camo.interfaces.IDestroyable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	
	/**
	* Base class for any scrollers (eg. slider bars, sliders, etc.), including scrollbars. 
	* Supports both directions (horizontal or vertical).
	* 
	* @author Glenn Ko
	*/
	public class GScroller extends Sprite implements IScroller, IDestroyable, IReflectClass
	{
		/**  @private */
		protected var _scrollTrack:Sprite;
		/**  @private */
		protected var _scrollScrub:Sprite;
		
		/**  @private */
		protected var _scrollTarget	:IScroll; 
		
		// Scrollable heights, bounds and starting y position/height for scrubber
		/**  @private */ protected var _scrollBounds	:Rectangle = new Rectangle();
		/**  @private */ protected var _scrollableHeight	:Number;
		/**  @private */ protected var _scrubStartY:Number = 0;
		/**  @private */ protected var _scrubberHeight:Number = 0;
		
		/**
		 * Marker property flag to determine if scroller is a horizontal or vertical scrollbar
		 */
		public var isHorizontal:Boolean = false;
		
		/**
		 * Constructor. Determines scroller direction (vertical or horizontal) by checking initial rotation.
		 */
		public function GScroller() 
		{
			super();
			isHorizontal = this.name === "scrollBarH" || rotation == 90;  // assumption hook-ups
		}
		
				
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GScroller;
		}
		
		
		/**
		 * @private
		 */
		protected function setBounds():void{
			var scrRect:Rectangle = _scrollTrack.getBounds(this);
			_scrollBounds.left 	= _scrollBounds.right = _scrollScrub.x;
			_scrollBounds.top 	= scrRect.top;
			_scrollBounds.bottom 	= scrRect.bottom - _scrubberHeight;
			_scrollableHeight = _scrollBounds.bottom - _scrollBounds.top;
			//	_scrollScrub.y 	= _scrollBounds.top; // reset scrollscrub position
		}
		
		// -- UI
		
		/**
		 * <b>[Stage instance]</b> to set up scroll track.
		 */
		public function set scrollTrack(spr:Sprite):void {
			if (_scrollTrack != null) destroyScrollTrack(_scrollTrack);
			_scrollTrack = spr;
			//_scrollTrack.buttonMode = true;
			setupScrollTrack (spr);
			
			if (_scrollScrub != null) setBounds ();
		}
		public function get scrollTrack():Sprite {
			return _scrollTrack;
		}
		/**
		 * <b>[Stage instance]</b> to set up scroll scrubber.
		 */
		public function set scrollScrub(spr:Sprite):void {
			//trace("Setting scroll scrub..");
			if (_scrollScrub != null) destroyScrollScrub(_scrollScrub);
			_scrollScrub = spr;
			setupScrollScrub (spr);
		
			if (_scrollTrack != null) setBounds ();
		}
		public function get scrollScrub():Sprite {
			return _scrollScrub;
		}
		
		// -- Scrub move handler
		
		/**
		 * @private
		 */
		protected function scrubMove(customTarget:IScroll=null):void {
			
			var scrollFactor:Number =  (_scrollScrub.y - _scrubStartY ) / _scrollableHeight;
			scrollFactor = Math.floor(scrollFactor * 100) / 100;
			
			// optional cap (just in case factor goes below zero or higher than 1 fpr some strange reason)
			scrollFactor = scrollFactor < 0  ? 0 : scrollFactor;
			scrollFactor = scrollFactor > 1  ? 1 : scrollFactor;
			//trace("scrollFactor:"+scrollFactor);
			
			// optional buffers
			//scrollFactor = (scrollFactor < 1) ? scrollFactor : 1.001;
			//scrollFactor = (scrollFactor > 0) ? scrollFactor : 0.001;
			
			var prop:String = isHorizontal ? "scrollH" : "scrollV";
			
			customTarget = customTarget ? customTarget : _scrollTarget;
			if (customTarget != null) customTarget[prop]  = scrollFactor;
			this.scrollFactor = scrollFactor;
		}
		
		[Bindable(event="change")]
		public var scrollFactor:Number = 0;
		
		
		// Setups 
		
		/**
		 * @private
		 * @param	targ
		 * @return
		 */
		protected function setupScrollScrub (targ:Sprite):Sprite {
			var func:Function =  targ.addEventListener;
			func(MouseEvent.MOUSE_DOWN, scrubPressHandler, false, 0, true);
			func(MouseEvent.CLICK, scrubReleaseHandler, false, 0, true); 
			_scrollScrub = targ;
			_scrollScrub.mouseEnabled = true;
			_scrollScrub.mouseChildren = false;
			
			_scrubStartY = _scrollScrub.y;
			_scrubberHeight = _scrollScrub.height;
			return targ;
		}
		/**
		 * @private
		 * @param	targ
		 */
		protected function destroyScrollScrub (targ:Sprite):void  {
			var func:Function = targ.removeEventListener;
			func(MouseEvent.MOUSE_DOWN, scrubPressHandler);
			func (MouseEvent.CLICK, scrubReleaseHandler); 
			_scrollScrub = null;
		}
		
		/**
		 * @private
		 * @param	targ
		 * @return
		 */
		protected function setupScrollTrack (targ:Sprite):Sprite {
			_scrollTrack = targ;
			_scrollTrack.mouseChildren = false;
			return targ;
		}
		/**
		 * @private
		 * @param	targ
		 */
		protected function destroyScrollTrack (targ:Sprite):void {
			_scrollTrack = null;
		}
		
		/**
		 * @private
		 */
		protected function destroyScrollTarget():void {
			_scrollTarget = null;
		}
		
		
		public function destroy():void {
			if (_scrollTrack != null) destroyScrollTrack (_scrollTrack);
			if (_scrollScrub != null) destroyScrollScrub (_scrollScrub);
			scrollTarget = null;
		}
		
		// -- Handlers
		
		/**
		 * @private
		 * @param	e
		 */
		protected function scrubPressHandler (e:MouseEvent):void {
			e.stopImmediatePropagation ();
			stage.addEventListener (MouseEvent.MOUSE_UP, stageReleaseHandler, false, 0, true);
			stage.addEventListener (MouseEvent.MOUSE_MOVE, scrubMoveHandler, false, 0, true);
			_scrollScrub.startDrag(false, _scrollBounds);
		}
		/**
		 * @private
		 * @param	e
		 */
		protected function scrubMoveHandler (e:MouseEvent):void {
			scrubMove ();
		}
		/**
		 * @private
		 * @param	e
		 */
		protected function scrubReleaseHandler (e:MouseEvent):void {
			e.stopImmediatePropagation ();
			stage.removeEventListener (MouseEvent.MOUSE_MOVE, scrubMoveHandler);
			stage.removeEventListener (MouseEvent.MOUSE_UP, stageReleaseHandler);
			_scrollScrub.stopDrag ();
		}	
		
		/**
		 * @private
		 * @param	e
		 */
		protected function stageReleaseHandler (e:MouseEvent):void {
			var validStage:IEventDispatcher = e.currentTarget as IEventDispatcher;
			validStage.removeEventListener (MouseEvent.MOUSE_MOVE, scrubMoveHandler);
			validStage.removeEventListener (MouseEvent.MOUSE_UP, stageReleaseHandler);
			_scrollScrub.stopDrag ();
		}
		
		// -- IScroller 
		
		/**
		 * Sets IScroll target  (or resets scroll target to new one)
		 */
		public function set scrollTarget (scr:IScroll):void {
			if (scr === _scrollTarget) return;
			//trace("Setting new scroll target..");
			
			if (_scrollTarget != null) {  // clear off previous scroll target if any
				destroyScrollTarget();
			}
			
			if (scr == null) return;
	
			_scrollTarget = scr; 
			
		
			//updateScrollbar();
		}	
		
	}
	
}