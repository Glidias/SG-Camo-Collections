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
	import sg.camo.interfaces.IAncestorSprite;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.display.IDisplay;
	import sg.camo.interfaces.IDisplayBase;
	import sg.camo.interfaces.IScrollBarUI;
	import sg.camo.interfaces.IScrollContainer;
	import sg.camo.interfaces.IScroller;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.interfaces.ITextField;
	import sg.camo.scrollables.DefaultScrollProxy;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.scrollables.ScrollMask2Rect;
	/**
	 * Attempts to make any generic DisplayObject scrollable through various "guess" determinations. Also provides
	 * setters to hook up a scroll proxy technique and setters to remotely add horizontal/vertical scrollbars 
	 * to the DisplayObject itself.
	 * <br/><br/>
	 * Note: Due to the cross-platform & guess-ey" nature of this class, encapsulation tends to be sacrificed a bit.
	 * This class considers various masking types. See <code>activate()</code> for more details.
	 * <br/><br/>
	 * 
	 * @version 0.6alpha 
	 * 
	 * For a concrete class-based implementation within a Flash-authoring-skinnable environment, see below:
	 * @see sg.camolite.display.GScrollContainer
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
		// interfaces
		/** @private */protected var _iDisplay:IDisplay;
		
		/** @private */	protected var _scrollBarH:IScroller;
		/** @private */	protected var _scrollBarV:IScroller;
		/** @private */	protected var _iScroll:IScrollProxy;
		

		/** @private */ protected var _overflowValue:int = OverflowEvent.SCROLL;
		/** @private */	protected var _itemLength:Number = 0;
		
		/** @private */
		protected var _disp:DisplayObject;
		
		// Constructor defaults
		public static var SCROLLBAR_INSIDE:Boolean = false;
		public static var RESIZE_DISPLAY:Boolean = true;
		
		public static const NEUTRAL:int = -1;
		public static const TRUE:int = 1;
		public static const FALSE:int = 0;
		public static const ALIGN_RATIO:int = -2;
		public static const ALIGN_LOWER:int = -3;  
		
		/** @private */
		protected var _scrollRectProxy:ScrollMask2Rect;
		

		
		// PUBLIC FLAGS
		
		// NOTE: Initialization variables to set  before activation of behaviour
		
		/** Flag to determine whether to provide a <code>scrollContainer</code> reference.
		 * This usually enables mouse wheeling to take effect on the entire display itself */
		public var enableScrollContainer:Boolean = true;
		
		/** Whether to flush scrollbar inside display */
		public var scrollBarInside:Boolean = SCROLLBAR_INSIDE;
		/**This determines whether to resize the display and accompanying scrollbars as a result of window size changes */
		public var resizeDisplay:Boolean = RESIZE_DISPLAY;
	
		/** Scroll bar X offset from current flushed position */
		public var scrollBarXOffset:Number = 0;
		/** Scroll bar Y offset from current flushed position */
		public var scrollBarYOffset:Number = 0;
		
		/** If scrollbar is a IScrollBarUI instance and value isn't NEUTRAL, attempts to overwrite setting
		 * for scrollbar's scrollTrack.
		 * @see sg.camo.interfaces.IScrollBarUI
		 * */
		public var autoFit:int = NEUTRAL;
		/** If scrollbar is a IScrollBarUI instance and value isn't NEUTRAL, attempts to overwrite setting
		 * for scrollbar's scrollScrub.
		 * @see sg.camo.interfaces.IScrollBarUI
		 * */
		public var autoFitScrub:int = NEUTRAL;
		
		public var hBarAlignRatio:Number = .5;
		public var vBarAlignRatio:Number = .5;
		/**
		 * Alignment ratios to use for scroll bars autoFit is set to ALIGN_RATIO.
		 */
		public function set alignBarRatios(val:Number):void {
			hBarAlignRatio = val;
			vBarAlignRatio = val;
		}

		
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
		 * 1) DisplayObjectContainer containing child name of "scrollContent"<br/>
		 * 2) IDisplay instance's "getDisplay()" reference.<br/>
		 * 3) ITextField instance's "textfield" reference.<br/>
		 * <br/>
		 * For scrollMask: Tries to find in the following order - <br/>
		 * 1) DisplayObjectContainer containing child name of "scrollMask".<br/>
		 * 2) scrollContent's <code>scrollRect</code> property.<br/>
		 * 3) scrollContent's <code>mask</code> property.<br/>
		 * <br/><br/>
		 * For unresolved dependencies:<br/>
		 * If no scrollContent is found, the activated displayObject is used as the scrollContent itself.<br/>
		 * If no scrollMask is found, an empty zero-dimension Rectangle is used.
		 * <br/><br/>
		 * Best practice: <i>Designer-supplied dependencies (ie. named stage instances) always overwrite
		 * Programmer-supplied settings.</i>
		 * 
		 * @see sg.camo.interfaces.IDisplay
		 * @see sg.camo.interfaces.ITextField
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
			_iDisplay = _disp as IDisplay;
			
			AncestorListener.addEventListenerOf(disp, CamoDisplayEvent.DRAW, drawHandler, -1);
		
			
			var dispCont:DisplayObjectContainer = targ as DisplayObjectContainer;
			_scrollContainer = targ as Sprite;
	
			var tryExplicit:DisplayObject;
		
			tryExplicit = dispCont != null ? AncestorChild.getChildByNameOf(dispCont, "scrollContent") : null;
			_scrollContent = tryExplicit ? tryExplicit :  disp is IDisplay ? (disp as IDisplay).getDisplay() : disp is ITextField ? (disp as ITextField).textField : _disp;
			
			tryExplicit = dispCont != null ? AncestorChild.getChildByNameOf(dispCont, "scrollMask") : null;
			
			var scrollRect:Rectangle = _scrollContent.scrollRect;
			_scrollMask = tryExplicit ? tryExplicit : scrollRect ? scrollRect : _scrollContent.mask ? _scrollContent.mask : new Rectangle();
			if (_scrollMask is DisplayObject && _overflowValue!=OverflowEvent.NONE) _scrollContent.mask = _scrollMask;
			
			
			if (_iScroll == null) _iScroll = new DefaultScrollProxy(this)
			else  _iScroll.target = this;
			
			
			if (_scrollMask === scrollRect) {
				_scrollRectProxy = new ScrollMask2Rect(_iScroll);  // set up scroll rect impl.
			}
			else {
				_scrollContent.scrollRect = null; // ensure no scroll rect impl is used.
			}

			
			
			
			
			if (_disp.stage ) {
				activateScrollBars();
			}
			else {
				AncestorListener.addEventListenerOf(_disp, Event.ADDED_TO_STAGE, addedToStageScrollBars);
			}
			
		}
		
		
		
		public function destroy():void {
			if (_iScroll != null) {
				AncestorListener.removeEventListenerOf(_disp, Event.ADDED_TO_STAGE, addedToStageScrollBars);
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
		
		
		// -- ScrollableBehaviour
		
		protected function addedToStageScrollBars(e:Event):void {
			AncestorListener.removeEventListenerOf(_disp, Event.ADDED_TO_STAGE, addedToStageScrollBars);
			
			activateScrollBars();
		}
		
		
		/**
		 * Attempts to setup IScroller scrollbars after activation. If no scrollBarH or scrollBarV values are found, 
		 * attempts to find IScroller from display list (if available) of currently activated DisplayObject target.
		 * - <code>...getChildByName("scrollBarV") as IScroller</code><br/>
		 * - <code>...getChildByName("scrollBarH")  as IScroller</code><br/>
		 * <br/><br/>
		 * Best practice: <i>Designer-supplied dependencies (ie. named stage instances) always overwrite
		 * Programmer-supplied settings.</i>
		 * 
		 * @see sg.camo.interfaces.IScroller
		 */
		protected function activateScrollBars():void {
			_scrollBarV = getTryScrollBar(_disp as DisplayObjectContainer, "scrollBarV") || _scrollBarV;
			_scrollBarH = getTryScrollBar(_disp as DisplayObjectContainer, "scrollBarH") || _scrollBarH;
			setupScrollbar(_scrollBarV);
			setupScrollbar(_scrollBarH);
		}
		

		
		/** @private */
		protected function getTryScrollBar(cont:DisplayObjectContainer, name:String):IScroller {
			if (cont == null) return null;
			var disp:DisplayObject = AncestorChild.getChildByNameOf(cont, name);
			if (disp == null) return null;
			
			var isHorizontal:Boolean = name === "scrollBarH";
			var bounds:Rectangle = disp.getBounds(cont);
			if (!isHorizontal) {
				scrollBarXOffset = bounds.left - (scrollMask.x + scrollMask.width);
				
				
			}
			else {
				
				scrollBarYOffset = bounds.top - (scrollMask.y + scrollMask.height) ;
			
			}
			
			//autoFit = 0;
			
			return disp as IScroller;
		}
		
		
		/** @private */	
		protected function getStringOverflowValue(val:int):String {
			switch (val) {
				case OverflowEvent.HIDDEN: return "hidden";
				case OverflowEvent.NONE: return "none";
				case OverflowEvent.SCROLL: return "scroll";
				case OverflowEvent.AUTO: return "auto";
				default: return "auto";
			}
		}

		

		
		/** @private */
		protected function drawHandler(e:Event=null):void {
			
			if (!resizeDisplay && e != null) return; 
			
			var toAutoFit:Boolean = (autoFit == TRUE);
			
			var disp:DisplayObject = (_scrollBarV as DisplayObject);
			if (disp ) {
				if (_disp is IDisplayBase)  
					scrollMask.width = disp.visible && scrollBarInside ? (_disp as IDisplayBase).__width - disp.width  : (_disp as IDisplayBase).__width;	
				//if (toAutoFit) {
					disp.x =  scrollMask.width  + scrollBarXOffset; 
					disp.y = toAutoFit ? 0 : disp.y//(scrollMask.height - disp.height) * vBarAlignRatio + scrollBarYOffset;
					disp.x += scrollMask.x;
					disp.y += scrollMask.y;
				
				//}
				//disp.height += toAutoFit ? scrollBarYOffset : 0;
			
				
			}
			else {
				scrollMask.width = (_disp as IDisplayBase).__width;
			}
			disp = (_scrollBarH as DisplayObject);
			if (disp ) {
				if (_disp is IDisplayBase) 
					scrollMask.height =  disp.visible  && scrollBarInside ? (_disp as IDisplayBase).__height  - disp.height : (_disp as IDisplayBase).__height
				//if (toAutoFit) {
					disp.x =  toAutoFit ? 0 : disp.x //(scrollMask.width - disp.width) * hBarAlignRatio  + scrollBarXOffset;
					disp.y =  scrollMask.height + disp.height  + scrollBarYOffset;
					disp.x += scrollMask.x;
					disp.y += scrollMask.y;
				//}
				//disp.width += toAutoFit ? 0 : 0;
				if (toAutoFit) disp.height = scrollMask.width;
			}
			else {
				if (_disp is IDisplayBase)  scrollMask.height = (_disp as IDisplayBase).__height;
			}
			
			disp = _scrollBarV as DisplayObject;
			if (disp) {
				if (toAutoFit) disp.height = scrollMask.height;
			}

			
			
			
			if (_scrollRectProxy) {	
				scrollContent.scrollRect = _scrollMask;
			}
		}

		
		/** Sets up scrollbar automatically. If scrollbar has no parent, an attempt is made to re-parent
		 * the scrollbar to the scroll container (if available) and repositioning is done by code calculation to match the container.
		 * If there's already a parent reference, it is assumed the "designer" has already positioned the asset on the stage
		 * and nothing else changes.
		 * */	
		protected function setupScrollbar(scr:IScroller):void {
			if (scr == null) return;
			scr.scrollTarget = this; 
			
			var disp:DisplayObject = scr as DisplayObject;
			if (disp == null) return;
			

			var ui:IScrollBarUI = scr as IScrollBarUI;
			var toAutoFit:Boolean = autoFit == NEUTRAL ? ui ? ui.autoFit : autoFit == TRUE : autoFit == TRUE;
			var toAutoFitScrub:Boolean = autoFit == NEUTRAL ? ui ? ui.autoFitScrub : autoFitScrub == TRUE : autoFitScrub == TRUE;
			ui.autoFit = toAutoFit;
			ui.autoFitScrub = toAutoFitScrub;

			
			_disp.dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) ); 
			_disp.dispatchEvent( new OverflowEvent(_overflowValue) );	
		
			if (disp.parent != null) {
				if (!resizeDisplay) drawHandler();
				return; // assumed scrollbar isn't isolated out of display list 
			}
		
			
			// Reparents scrollbar if scrollbar has no parent, and repositions it based on assosiated parent's dimensions..
			var isHorizontal:Boolean = scr === _scrollBarH;
			var isSprite:Boolean = _disp is Sprite;

			if (isHorizontal) {
				disp.rotation = -90;
				disp.x = toAutoFit ? 0 : (scrollMask.width - disp.width) * hBarAlignRatio;
				disp.y = scrollBarInside ? scrollMask.height  : scrollMask.height + disp.height;
				//scrollBarYOffset -= scrollBarInside ? disp.height : 0;
			}
			else {
				disp.x = scrollBarInside ? scrollMask.width - disp.width : scrollMask.width;
				disp.y = toAutoFit ? 0 : (scrollMask.height - disp.height) * vBarAlignRatio;
				//scrollBarXOffset -= scrollBarInside ? disp.width : 0;

			}
			disp.x += scrollMask.x;
			disp.y += scrollMask.y;
				
			disp.x += isSprite ? 0 : _disp.x;
			disp.y += isSprite ? 0 : _disp.y;
			disp.x += scrollBarXOffset;
			disp.y += scrollBarYOffset;
			
			if (isSprite) {
				var addChild:Function = _disp is IAncestorSprite ? (_disp as IAncestorSprite).$addChild : (_disp as Sprite).addChild;
				addChild(disp);
			}
			else {
				var chkParent:DisplayObjectContainer = _disp.parent;
				if (chkParent != null) chkParent.addChild(disp);
			}
			
			if (!resizeDisplay) drawHandler();
			
		
		}

		
		public function set overflow(str:String):void {
			var value:int;
			switch (str) {
				case "none" :  value = OverflowEvent.NONE;  break;
				case "hidden" :  value = OverflowEvent.HIDDEN; break;
				case "visible" : value = OverflowEvent.NONE; break; 
				case "scroll" : value = OverflowEvent.SCROLL;  break; 
				case "auto" : value = OverflowEvent.AUTO ;   break;
				default:  break;
			}
			_overflowValue = value;
			if (_disp == null) return;
			_disp.dispatchEvent( new OverflowEvent(_overflowValue) );
		}
		
		
		
		/**
		 * Sets up vertical scrollbar
		 */
		public function set scrollBarV(scr:IScroller):void {

			_scrollBarV = scr;

		}
		public function get scrollBarV():IScroller {
			return _scrollBarV;
		}
		
		/**
		 * Sets up horizontal scrollbar
		 */
		public function set scrollBarH(scr:IScroller):void {
			
			_scrollBarH = scr;

		}
		public function get scrollBarH():IScroller {
			return _scrollBarH;
		}
		
		
		// -- IScrollContainer
		
		public function set iScroll(val:IScrollProxy):void {
			_iScroll = val;
			if (val.target == null) {
				if (scrollContent != null) {
					val.target = this;
				}
			}
		}
		public function get iScroll():IScrollProxy {
			return _iScroll;
		}
		
		// -- IScrollable
		
		public function get scrollContainer ():Sprite {
			return enableScrollContainer ? _scrollContainer : null;
		}
		
		
		public function get scrollMask ():* {
			return _scrollMask;  //_scrollRectProxy ? _scrollRectProxy : 
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
			invalidate();
		}
		
		public function invalidate():void {
			if (_iDisplay != null) _iDisplay.invalidate();
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

		

		
		
	}

}