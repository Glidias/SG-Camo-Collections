package sg.camo.behaviour 
{
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import sg.camo.ancestor.AncestorChild;
	import sg.camo.events.OverflowEvent;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.display.IDisplay;
	import sg.camo.interfaces.IDisplayBase;
	import sg.camo.interfaces.IScrollBarUI;
	import sg.camo.interfaces.IScrollContainer;
	import sg.camo.interfaces.IScroller;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.interfaces.ITextField;
	import sg.camo.scrollables.DefaultScrollProxy;
	import sg.camo.scrollables.ScrollMask2Rect;
	/**
	 * Attempts to make any generic DisplayObject scrollable. Also provides
	 * setters to hook up a scroll proxy technique and setters to remotely add horizontal/vertical scrollbars 
	 * to the DisplayObject itself.
	 *  
	 * 
	 * @author Glenn Ko
	 */
	public class ScrollableBehaviour implements IBehaviour, IScrollContainer
	{
		public static const NAME:String = "ScrollableBehaviour";
		
	
		// targets
		/** @private */ protected var _scrollContainer:Sprite;
		
		/** @private */ protected var _scrollContent:DisplayObject;
		/** @private */protected var _scrollMask:*;
		
		/** @private */	protected var _scrollBarH:IScroller;
		/** @private */	protected var _scrollBarV:IScroller;
		/** @private */	protected var _iScroll:IScrollProxy;
		

		/** @private */ protected var _overflowValue:int = OverflowEvent.SCROLL;
		/** @private */	protected var _itemLength:Number = 0;
		
		protected var _activated:Boolean = false;
		
		/** @private */
		protected var _disp:DisplayObject;
		
		/** @private */
		protected var _scrollRectProxy:ScrollMask2Rect;
		

		
		// PUBLIC FLAGS
		
		// NOTE: Initialization variables to set  before activation of behaviour
		
		/** Flag to determine whether to provide a <code>scrollContainer</code> reference.
		 * This usually enables mouse wheeling to take effect on the entire display itself */
		public var enableScrollContainerWheel:Boolean = true;
	

		
		public function ScrollableBehaviour() 
		{
			super();
		}
	

		public function get behaviourName():String {
			return NAME;
		}
		


		/**
		 * Activates DisplayObject and attempts to make it scrollable through the following determinations:<br/>
		 * <br/>
		 * For scrollContainer: The activated displayObject itself if it's a valid Sprite, else null.
		 * <br/>
		 * For scrollContent: Tries to find in the following order -  <br/>
		 * 1) DisplayObjectContainer containing child name of "scrollContent"<br/>  (might be depreciated)
		 * 2) IDisplay instance's "getDisplay()" reference.<br/> (the typical use-case)
		 * 3) The display object iself.
		 * <br/>
		 * For scrollMask: Tries to find in the following order - <br/>
		 * 1) DisplayObjectContainer containing child name of "scrollMask".<br/>   (might be depreciated)
		 * 2) scrollContent's <code>scrollRect</code> property.<br/>   (might be depreciated)
		 * 3) scrollContent's <code>mask</code> property.<br/>  (the common use-case)
		 * 4) An empty dummy rectangle is used if no scrollMask can be found.
		 * 
		 * @see sg.camo.interfaces.IDisplay
		 * 
		 * @param	targ	A DisplayObject valid instance.
		 */
		public function activate(targ:*):void {
			
			_disp = targ as DisplayObject;
		
			if (_disp == null) {
				trace("ScrollableBehaviour activate() halt! Targ isn't DisplayObject or null")
				return;
			}
			
			var disp:DisplayObject = _disp;
			
			var dispCont:DisplayObjectContainer = targ as DisplayObjectContainer;
			_scrollContainer = targ as Sprite;

			var tryExplicit:DisplayObject;
			
			if (_scrollContent == null) {
				tryExplicit = dispCont != null ? AncestorChild.getChildByNameOf(dispCont, "scrollContent") : null;
				_scrollContent = tryExplicit ? tryExplicit :  disp is IDisplay ? (disp as IDisplay).getDisplay() : _disp;
			}
			
			tryExplicit = dispCont != null ? AncestorChild.getChildByNameOf(dispCont, "scrollMask") : null;
			var scrollRect:Rectangle = _scrollContent.scrollRect;
			_scrollMask = tryExplicit ? tryExplicit : scrollRect ? scrollRect : _scrollContent.mask ? _scrollContent.mask : new Rectangle();
			if (tryExplicit && _scrollMask is DisplayObject && _overflowValue!=OverflowEvent.NONE) _scrollContent.mask = _scrollMask;
			
			
			if (_iScroll == null) _iScroll = new DefaultScrollProxy(this)
			else  _iScroll.target = this;
			
			
			if (_scrollMask === scrollRect) {
				_scrollRectProxy = new ScrollMask2Rect(_iScroll);  // set up scroll rect impl fix
			}
		
		
			if (_disp.stage ) {
				onAddedToStage();
			}
			else {
				_disp.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			}	
			
			_activated = true;
		}
		
		
		public function destroy():void {
			if (_disp!=null) _disp.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if (_iScroll != null) {
				_iScroll.destroy();
			}
			if (scrollBarV != null) {
				scrollBarV.destroy();
			}
			if (scrollBarH != null) {
				scrollBarH.destroy();
			}
			if (_scrollRectProxy != null) {
				_scrollRectProxy.destroy();
				_scrollRectProxy = null;
			}
		}
		
		
		protected function onAddedToStage(e:Event=null):void {
			_disp.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if (_scrollBarH) _scrollBarH.scrollTarget = this;
			if (_scrollBarV) _scrollBarV.scrollTarget = this;
			if (_iScroll) _iScroll.target = this;
			_disp.dispatchEvent( new OverflowEvent(_overflowValue) );
		}

		
		public function set overflow(str:String):void {
			var value:int;
			switch (str) {
				case "none" :  value = OverflowEvent.NONE;  break;
				case "hidden" :  value = OverflowEvent.HIDDEN; break;
				case "visible" : value = OverflowEvent.NONE; break; 
				case "scroll" : value = OverflowEvent.SCROLL;  break; 
				case "auto" : value = OverflowEvent.AUTO ;   break;
				default:  trace("ScrollableBehaviour set overflow():: Supplied invalid overflow value of:"+str);  return;
			}
			_overflowValue = value;
			
			if (!_activated) return;
			_disp.dispatchEvent( new OverflowEvent(_overflowValue) );
		}
		
		
		
		/**
		 * Sets up vertical scrollbar
		 */
		public function set scrollBarV(scr:IScroller):void {

			_scrollBarV = scr;
			if (_activated) scr.scrollTarget = this; 	

		}
		public function get scrollBarV():IScroller {
			return _scrollBarV;
		}
		
		/**
		 * Sets up horizontal scrollbar
		 */
		public function set scrollBarH(scr:IScroller):void {
			
			_scrollBarH = scr;
			if (_activated) scr.scrollTarget = this;

		}
		public function get scrollBarH():IScroller {
			return _scrollBarH;
		}
		
		
		// -- IScrollContainer
		
		public function set iScroll(val:IScrollProxy):void {
			_iScroll = val;
			if (_activated) val.target = this;
		}
		public function get iScroll():IScrollProxy {
			return _iScroll;
		}
		
		// -- IScrollable
		
		public function get scrollContainer ():Sprite {
			return enableScrollContainerWheel ? _scrollContainer : null;
		}
		
		
		// can resolve display object mask from scrollcontent if wasn't found earlier
		public function get scrollMask ():* {
			return _scrollMask || (_scrollMask = _scrollContent.mask) || dummyRect;
			
		}
		
		private function get dummyRect():Rectangle {
			trace("ScrollableBehaviour ::scrollMask() Could not resolve scrollMask rectangle");
			return new Rectangle();
		}

	
		public function get scrollContent ():DisplayObject {
			return _scrollContent;
		}
		
		
		public function resetScroll():void {
			_iScroll.resetScroll();
		}
		
		
		public function get itemLength ():Number {
			return _itemLength;
		}
		
		
		public function set itemLength(val:Number):void {
			_itemLength = val;
		}
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_disp.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
	
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_disp.removeEventListener(type, listener, useCapture);
		}
		
		// -- IScroll

		public function set scrollH (ratio:Number):void {
			_iScroll.scrollH = ratio;
			
		}

		public function set scrollV (ratio:Number):void {
			_iScroll.scrollV = ratio;
		}
		
		
		// note:this is a hack to set scrollcontent directly
		public function set scrollContent(value:DisplayObject):void 
		{
			_scrollContent = value;
		}

		

		
		
	}

}