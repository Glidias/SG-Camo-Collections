package sg.camolite.display {
	
	import sg.camo.interfaces.IScrollContainer;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.interfaces.IScroller;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.scrollables.DefaultScrollProxy;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	
	import flash.events.Event;
	
	import sg.camo.events.OverflowEvent;
	
	
	/**
	* Standard scroll container 
	* @author Glenn Ko
	*/
	public class GScrollContainer extends GBaseDisplay implements IScrollContainer {
		
		
		// Scrolling

		/** @private */	protected var _scrollBarH:IScroller;
		/** @private */	protected var _scrollBarV:IScroller;
		/** @private */	protected var _iScroll:IScrollProxy;
		/** @private */	protected var _overflowAuto:Boolean = false;
		
		/** @private */	protected var _itemLength:Number = 0;
		
		/** @private */	protected var _scrollMask:DisplayObject;
		
		public function GScrollContainer(customDisp:Sprite = null) {
			super(customDisp);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GScrollContainer;
		}
		
		/**
		 * <b>[Stage instance]</b> to set up nested child <code>display</code> sprite, which functions as the scrolling content
		 */
		override public function set displaySprite(spr:Sprite):void {
			super.displaySprite = spr;
		}
		
		/**
		 * <b>[Stage instance]</b> to sets up horizontal scrollbar
		 */
		public function set scrollBarH(scr:IScroller):void {
			_scrollBarH = scr;
			_iScroll = _iScroll != null? _iScroll : new DefaultScrollProxy(this);
			if (display == null) {
				if (_scrollBarV ==null && _scrollBarH ==null)  addEventListener(Event.ADDED_TO_STAGE, addedToStageScrollBars, false , 0, true);
			}
			else {
				setupScrollbar(scr);
			}
		}
		public function get scrollBarH():IScroller {
			return _scrollBarH;
		}
		
		
		// --  to do, canceling and renewing of scroll proxy
		public function set iScroll(val:IScrollProxy):void {
			_iScroll = val;
		}
		public function get iScroll():IScrollProxy {
			return _iScroll;
		}
		
		/** @private */	
		protected function get overflowValue():int {
			return _overflowAuto ? OverflowEvent.AUTO : OverflowEvent.SCROLL;
		}
		/** @private */	
		protected function setupScrollbar(scr:IScroller):void {
			scr.scrollTarget = this; 	
			dispatchEvent( new OverflowEvent(overflowValue) );
		}
		
		public function set overflow(str:String):void {
			var value:int;
			switch (str) {
				case "none" :  value = OverflowEvent.NONE;  break;
				case "hidden" :  value = OverflowEvent.HIDDEN; break;
				case "visible" : value = OverflowEvent.NONE; break; 
				case "scroll" : value = OverflowEvent.SCROLL;  _overflowAuto = false;  break; 
				case "auto" : value = OverflowEvent.AUTO ; _overflowAuto = true;  break;
				default:  break;
			}
			dispatchEvent( new OverflowEvent(overflowValue) );
		}
		
		public function set overflowAuto(boo:Boolean):void {
			_overflowAuto = boo;
			dispatchEvent( new OverflowEvent(overflowValue) );
		}
		
		// validate width and height to get best possible value
		// Is this reeally necessary? consider phasing out
		
	/*	override public function get width():Number {
			return _width > 0 ? _width :  scrollMask != null ? scrollMask.width : 0;
		}
		override public function get height():Number {
			return _height > 0? _height : scrollMask != null ? scrollMask.height : 0;
		}
		*/

		/**
		 * <b>[Stage instance]</b> to sets up vertical scrollbar
		 */
		public function set scrollBarV(scr:IScroller):void {
			_scrollBarV = scr;
			_iScroll = _iScroll != null? _iScroll : new DefaultScrollProxy(this);
			if (display == null) {
				if (_scrollBarV ==null && _scrollBarH ==null)  addEventListener(Event.ADDED_TO_STAGE, addedToStageScrollBars, false , 0, true);
			}
			else {
				scr.scrollTarget = this;
			}
		}
		public function get scrollBarV():IScroller {
			return _scrollBarV;
		}
		
		
		/**
		 * Alternative <b>[Stage instance]</b> name to sets up vertical scrollbar
		 */
		public function set scrollbar(scr:IScroller):void {
			scrollBarV = scr;
		}

		
		public function get scrollbar():IScroller {
			return scrollBarV;
		}
		
		/** @private */	
		protected function addedToStageScrollBars(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageScrollBars);
			
			if (_scrollBarV != null) setupScrollbar(_scrollBarV);
			if (_scrollBarH != null) setupScrollbar(_scrollBarH);
		}
		
		
		override public function destroy():void {
			super.destroy();
			if (_iScroll != null) {
				removeEventListener(Event.ADDED_TO_STAGE, addedToStageScrollBars);
				_iScroll.destroy();
			}
			if (scrollBarV != null) {
				scrollBarV.destroy();
			}
			if (scrollBarH != null) {
				scrollBarH.destroy();
			}
		}
		
		public function set itemLength(val:Number):void {
			_itemLength = val;
			invalidate();
		}
		/**
		 * [required] <b>[Stage instance]</b> to set up scroll mask
		 */
		public function set scrollMask (targ:DisplayObject):void {  
			display = getDisplaySprite();
			display.mask = targ;  
			_scrollMask  = targ;
		}

		
		// -- Default IScrollable/IScrollContainer implementation

		public function set scrollH (ratio:Number):void {
			_iScroll.scrollH = ratio;
		}
		public function resetScroll():void {
			_iScroll.resetScroll();
		}	
	
		public function set scrollV (ratio:Number):void {

			_iScroll.scrollV = ratio;
		}
		
		public function get scrollContainer ():Sprite { 
			return this;
		}


		public function get scrollMask ():* {  
			return _scrollMask;
		}
		

		public function get scrollContent ():DisplayObject {
			return display;
		}
		
		public function get itemLength():Number {
			return _itemLength;
		}
		
	
		
	}
	
}