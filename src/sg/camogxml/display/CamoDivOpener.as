package sg.camogxml.display 
{
	import camo.core.events.CamoDisplayEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IOpenScrollProxy;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.scrollables.OpenCloseScrollProxy;
	
	/**
	 * Composite openable display that serves as a customisable, skinnable base for 
	 * creating your own menus/dropdowns/accordians, etc. To trigger a open/close/toggle-open-close
	 * action on this component, simply dispatch a "open", "close" or "toggle" event to this container.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivOpener extends CamoDiv implements IScrollable
	{
		
		// Negative values imply lower case vector (left/up) while positive values imply upper case vector. (right/down)
		public static const OPEN_LEFT:int = -1;
		public static const OPEN_NONE:int = 0;
		public static const OPEN_RIGHT:int = 1;
		public static const OPEN_UP:int = -2;
		public static const OPEN_DOWN:int = 2;
		
		// CamoDivOpener listens to the following events to trigger the appropiate actions
		public static const OPEN:String = Event.OPEN;
		public static const CLOSE:String = Event.CLOSE;
		public static const TOGGLE:String = "toggle";
		
		/** @private */ protected var _openDirection:int = OPEN_DOWN;
		public function set openDirection(val:int):void {
			_openDirection = val;
			if (stage) {
				alignDisplay();
				updateMaskShape();
				showDefaultOpenState();
			}
		}
		public function set direction(str:String):void {
			switch (str) {
				case "left": _openDirection = OPEN_LEFT;  return;
				case "right": _openDirection = OPEN_RIGHT;   return;
				case "up": _openDirection = OPEN_UP;   return;
				case "down": _openDirection = OPEN_DOWN;  return;
				default:return;
			}
		}

		/** @private */ protected var _iScroll:IOpenScrollProxy;
		
		/** @private */ protected var _isOpen:Boolean = false;
		
		/** @private */ protected var _defaultScrollProxy:IOpenScrollProxy;
		
		/** @private */ protected var _scrollH:Number; // last saved scrollH value
		/** @private */ protected var _scrollV:Number; // last saved scrollV value
		
		
		/** @private */ protected var _emptyDisplay:Sprite = new Sprite();
		/** @private */ protected var unionRect:Rectangle = new Rectangle();
		/** @private */ protected var _ancestorDisplay:DisplayObject;
		
		
		/** @private */ protected var maskRect:Rectangle = new Rectangle();
		/** @private */ protected var _maskPaddingLeft:Number = 0;
		/** @private */ protected var _maskPaddingRight:Number = 0;
		/** @private */ protected var _maskPaddingBottom:Number = 0;
		/** @private */ protected var _maskPaddingTop:Number = 0;
		
		public function set maskPaddingLeft(val:Number):void {
			_maskPaddingLeft = val;
			invalidate();
		}
		public function get maskPaddingLeft():Number {
			return _maskPaddingLeft;
		}
		public function set maskPaddingRight(val:Number):void {
			_maskPaddingRight = val;
			invalidate();
		}
		public function get maskPaddingRight():Number {
			return _maskPaddingRight;
		}
		public function set maskPaddingTop(val:Number):void {
			_maskPaddingTop = val;
			invalidate();
		}
		public function get maskPaddingTop():Number {
			return _maskPaddingTop;
		}
		public function set maskPaddingBottom(val:Number):void {
			_maskPaddingBottom = val;
			invalidate();
		}
		public function get maskPaddingBottom():Number {
			return _maskPaddingBottom;
		}
		
		
		public function CamoDivOpener() 
		{
			maskShape = new Shape();
			display = _emptyDisplay;
			super();
			_defaultScrollProxy = new OpenCloseScrollProxy(this);
			_iScroll = _defaultScrollProxy;
			
			maskShape.graphics.beginFill(0, .4);
			maskShape.graphics.drawRect(0, 0, 32, 32);
			$addChild(maskShape);
			
			$addEventListener(OPEN, openHandler, false , 0, true);
			$addEventListener(CLOSE, closeHandler, false , 0, true);
			$addEventListener(TOGGLE, toggleOpenCloseHandler, false , 0, true);
		}
		
		
		override public function get reflectClass():Class {
			return CamoDivOpener;
		}
		
		/** @private */
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			showDefaultOpenState();
		}	
		
		/** @private */
		protected function showDefaultOpenState():void {
			_iScroll.resetScroll();
			var saveScrollProxy:IOpenScrollProxy = _iScroll;
			if (_isOpen) {
				_iScroll = _defaultScrollProxy;
				showOpen();
			}
			else {
				_iScroll = _defaultScrollProxy;
				showClose();
			}	
			_iScroll = saveScrollProxy;
		}
		
		public function set iScroll(scrollProxy:IOpenScrollProxy):void {
			_iScroll = scrollProxy;
			_iScroll.target = this;
		}
		
		public function get iScroll():IOpenScrollProxy {
			return _iScroll;
		}
		
		override public function set overflow(str:String):void {
			$overflow = str;
			_bubblingDraw = true;
			invalidate();
		}
		
		/**
		 * Sets open/close state. 
		 */
		
		 /** @private */
		 protected function get isHorizontal():Boolean {
			var abs:int = _openDirection < 0 ? -_openDirection : _openDirection;
			return abs < 2;
		}
		
		/** @private */
		protected function set open(boo:Boolean):void {
			if (boo == _isOpen) return;
			_isOpen = boo;
			if (boo) doOpen()
			else doClose();
		}
		/** @private */
		protected function get open():Boolean {
			return _isOpen;
		}
		/** @private */
		protected function doOpen():void {
			_isOpen = true;  // default reasserts
			showOpen();
		}
		/** @private */
		protected function showOpen():void {
			var isLeft:Boolean = _openDirection < 0;
			_iScroll.openReverseDirection = isLeft;
			var abs:int = isLeft ? -_openDirection : _openDirection;
			if ( abs < 2 ) scrollH = isLeft ? -1 : 1;
			else scrollV = isLeft ? -1 : 1;
			if (_measureMode > UNION_ALL) {
				_bubblingDraw = true;
				invalidate();
			}
		}
		/** @private */
		protected function doClose():void {
			_isOpen = false; // default reasserts
			showClose();
		}
		/** @private */
		protected function showClose():void {
			var isLeft:Boolean = _openDirection < 0;
			_iScroll.openReverseDirection = isLeft;
			var abs:int = _openDirection < 0 ? -_openDirection : _openDirection;
			if (abs < 2) scrollH = 0;
			else scrollV = 0;
			if (_measureMode > UNION_ALL) {
				_bubblingDraw = true;
				//calculateUnionRect();
				invalidate();
			}
		}
		
		public function set isOpen(boo:Boolean):void {
			
			if (stage) open = boo
			else _isOpen = boo;
		}
		public function get isOpen():Boolean {
			return _isOpen;
		}
		
		
		// -- Handlers
		
		/** @private */
		protected function toggleOpenCloseHandler(e:Event):void {
			open = !open;
		}
		
		/** @private */
		protected function openHandler(e:Event):void {
			open = true;
		}
		
		/** @private */
		protected function closeHandler(e:Event):void {
			open = false;
		}
					
		/** @private */
		protected function onScroll(e:Event):void {
			_bubblingDraw = true;
			refresh();
		}
		
		// -- Construct
		
		[PostConstruct(name="CamoDivOpener.ancestorDisplay",name="CamoDivOpener.displaySprite")]
		public function init(ancestorDisplay:DisplayObject, displaySprite:Sprite):void {
			addChild(ancestorDisplay);
			addChild(displaySprite);
		}
		
		/**
		 * Stage instance setter to set principal display object on ancestor level.
		 */
		public function set ancestorDisplay(target:DisplayObject):void {
			setAncestorDisplay(target);
		}
		
		/**
		 * @private Sets up principal display object on ancestor level.
		 * @param	target
		 * @return	Whether target is valid for setting up
		 */
		protected function setAncestorDisplay(target:DisplayObject):Boolean {
			if (_ancestorDisplay) {
				trace( new Error("CamoDivOpener :: ancestorDisplay already set!") );
				return false;
			}
			_ancestorDisplay = target;
			_ancestorDisplay.x = 0;
			_ancestorDisplay.y = 0;
			return true;
		}
		
		/**
		 * Stage instance or generic setter to set display sprite holder that holds all other children.
		 * Only allowed to set once.
		 */
		override public function set displaySprite(target:Sprite):void {
			setDisplaySprite(target);
			super.displaySprite = target;
		}
		
		/**
		 * @private Sets up display sprite holder that holds all other children
		 * @param	target
		 * @return	Whether target is valid for setting up
		 */
		protected function setDisplaySprite(target:Sprite):Boolean {
			if (display != _emptyDisplay && display) {
				trace( new Error("CamoDivOpener :: displaySprite already set!") );
				return false;
			}
			display = target;
			display.mask = maskShape;
			return true;
		}
	
		
		/**
		 * To setup CamoDivOpener, you could call addChild() two times to add the 1st
		 * item, (which is the ancestor display), and the 2nd item which is the display sprite
		 * container which holds all other children. If this is already done through Stage
		 * Instance setters or the PostConstruct init() method, than everything is settle already.
		 * @param	child
		 * @return
		 */
		override public function addChild(child:DisplayObject):DisplayObject {
			if (!_ancestorDisplay) {
				
				$addChild(child);
				ancestorDisplay = child;
				
				_bubblingDraw = true;
				
				invalidate();
				return child;
			}	
			if (display === _emptyDisplay) {
				if (child is Sprite) {
					$addChildAt(child,0);
					displaySprite = child as Sprite;
					
					invalidate();
				}
				else throw new Error('CamoDivOpener addChild(). Invalid 2nd child! Child must be a sprite!');
				return child;
				
			}
			
			return super.addChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject {
			if (display === _emptyDisplay) return child;
			return super.removeChild(child);
		}
		
		// --Layout settings/handlers
		
		/** @private */ protected var _directionalOffset:Number = 0;
		/** @private */ protected var _alignRatio:Number = 0;
		/** @private */ protected var _alignOffset:Number = 0;
		/** @private */ protected var _considerOwnPadding:Boolean = true;
		
		public function set directionalOffset(val:Number):void {
			_directionalOffset = val;
			_bubblingDraw = _measureMode != ANCESTOR_ONLY;
			invalidate();
		}
		public function get directionalOffset():Number {
			return _directionalOffset;
		}
		
		public function set alignRatio(val:Number):void {   
			_alignRatio = val;
			_bubblingDraw = _measureMode != ANCESTOR_ONLY;
			invalidate();
		}
		public function get alignRatio():Number {
			return _alignRatio;
		}
		public function set alignOffset(val:Number):void {
			_alignOffset = val;
		}
		public function get alignOffset():Number {
			return _alignOffset;
		}
		public function set considerOwnPadding(val:Boolean):void {  
			_considerOwnPadding = val;
			_bubblingDraw = _measureMode != ANCESTOR_ONLY;
			invalidate();
		}
		public function get considerOwnPadding():Boolean {
			return _considerOwnPadding;
		}
		
		/** @private */
		override protected function alignDisplay():void {
		
			if (!_ancestorDisplay) return;
			
			_ancestorDisplay.x = paddingLeft + borderLeft;
			_ancestorDisplay.y = paddingTop + borderTop;
			var result:Number;
			var result2:Number;
		
			var dir:int = _openDirection;
			switch( dir) {
				case OPEN_DOWN:
					result = _considerOwnPadding ? _ancestorDisplay.width + addWidth : _ancestorDisplay.width;
					result2 = _considerOwnPadding ? 0 : _ancestorDisplay.x;
					result = result2 + _alignRatio * (_ancestorDisplay.width - display.width) + _alignOffset;// align ratio
					display.x = result;
					maskShape.x = result;
					maskShape.y = _ancestorDisplay.y + _ancestorDisplay.height + _directionalOffset;					
				break;
				
				case OPEN_LEFT:
					result = _considerOwnPadding ? _ancestorDisplay.height + addHeight : _ancestorDisplay.height;
					result2 = _considerOwnPadding ? 0 : _ancestorDisplay.y;
					result = result2 + _alignRatio * (result - display.height) + _alignOffset;// align ratio
					result -= _considerOwnPadding ? _paddingTop : 0;
					display.y = result;
					maskShape.y = result;
					maskShape.x = _ancestorDisplay.x -_ancestorDisplay.width - (display.width-_ancestorDisplay.width) + _directionalOffset;
				break;
				
				case OPEN_UP:
					result = _considerOwnPadding ? _ancestorDisplay.width + addWidth : _ancestorDisplay.width;
					result2 = _considerOwnPadding ? 0 : _ancestorDisplay.x;
					result = result2 + _alignRatio * (result - display.width) + _alignOffset;// align ratio
					display.x = result;
					maskShape.x = result;
					maskShape.y = _ancestorDisplay.y -_ancestorDisplay.height - (display.height-_ancestorDisplay.height) + _directionalOffset;
				break;
				
				case OPEN_RIGHT:
					result = _considerOwnPadding ? _ancestorDisplay.height + addHeight : _ancestorDisplay.height;
					result2 = _considerOwnPadding ? 0 : _ancestorDisplay.y;
					result = result2 + _alignRatio * (result - display.height) + _alignOffset;// align ratio
					display.y = result;
					maskShape.y = result;
					maskShape.x = _ancestorDisplay.x + _ancestorDisplay.width + _directionalOffset;
				break;
				
				
				default:break;
			}

		}
		
		/** @private */
		protected function updateMaskShape():void {
			maskRect.x = maskShape.x;
			maskRect.y = maskShape.y;
			maskRect.width = display.width;
			maskRect.height = display.height;
			maskShape.graphics.clear();
			maskShape.graphics.beginFill(0, .5);
			maskShape.graphics.drawRect(-_maskPaddingLeft, -_maskPaddingTop, _maskPaddingLeft + _maskPaddingRight + maskRect.width, _maskPaddingTop + _maskPaddingBottom + maskRect.height );
		}
		

		
		private var rect1:Rectangle = new Rectangle();
		private var rect2:Rectangle = new Rectangle();
	
		/** @private */
		protected function calculateUnionRect():void {

			if (!_ancestorDisplay || _measureMode == ANCESTOR_ONLY) return;

			rect1.x = _ancestorDisplay.x;
			rect1.y = _ancestorDisplay.y;
			rect1.width = _ancestorDisplay.width;
			rect1.height = _ancestorDisplay.height;

			switch (_measureMode) {
				case UNION_ALL:
					unionRect = rect1.union(maskRect);
				return;
				case UNION_DYNAMIC_AUTO:
					if (!_isOpen) unionRect = rect1;
					else unionRect = rect1.union(maskRect);
			
				return;
				case UNION_DYNAMIC_SCROLL:
					rect2.x = display.x;
					rect2.y = display.y;
					rect2.width = display.width;
					rect2.height = display.height;
					unionRect = rect1.union( rect2 );
					var prop:String = isHorizontal ? 'y' : 'x';
					unionRect[prop] = 0;
				return;
				
				default:return;
			}
			
		}
		
		override public function refresh():void {
			_bubblingDraw = true;
		
			super.refresh();
		}
	
		
		/** @private */ protected var _measureMode:int = ANCESTOR_ONLY;
		
		public static const ANCESTOR_ONLY:int = 0; 
		public static const UNION_ALL:int = 1;
		public static const UNION_DYNAMIC_SCROLL:int = 2;
		public static const UNION_DYNAMIC_AUTO:int = 3;

		override protected function activateOverflowHidden():void {
			_measureMode = ANCESTOR_ONLY;
			if (hasEventListener(Event.SCROLL)) $removeEventListener(Event.SCROLL, onScroll);
		}
		override protected function clearOverflow():void {
			_measureMode = UNION_ALL;
			if (hasEventListener(Event.SCROLL)) $removeEventListener(Event.SCROLL, onScroll);
		}
		override protected function activateOverflowScroll():void {
			_measureMode = UNION_DYNAMIC_SCROLL;
			$removeEventListener(Event.SCROLL, onScroll);
			$addEventListener(Event.SCROLL, onScroll, false , 0, true);
		}
		override protected function activateOverflowAuto():void {
			_measureMode = UNION_DYNAMIC_AUTO;
			if (hasEventListener(Event.SCROLL)) $removeEventListener(Event.SCROLL, onScroll);
		}

		
	
		override public function get displayWidth():Number {
			return _ancestorDisplay != null ?  _measureMode == ANCESTOR_ONLY ? _ancestorDisplay.width : unionRect.width+ unionRect.x : 0;
		}
		override public function get displayHeight():Number {
			return _ancestorDisplay != null ?  _measureMode == ANCESTOR_ONLY ? _ancestorDisplay.height : unionRect.height + unionRect.y : 0;
		}
		
		// DisplayObject overrides
		
		
		override public function set width(val:Number):void {
			if (_ancestorDisplay) _ancestorDisplay.width = val;  // consider disabling
		}
		
		
		override public function set height(val:Number):void {
			if (_ancestorDisplay) _ancestorDisplay.height = val;  // consider disabling
		}

		override public function get width():Number {
			return displayWidth + addWidth;
		}
		

		
		override public function get height():Number {
			return displayHeight + addHeight;
		}
		
		
		/**
		 * A poor example of Camo's poor design of over-inheritance. Because the order
		 * needs to be different in this extended class, I need to re-write the whole order again
		 * manually.
		 */
		override protected function draw():void {
		
						
			// Align Content first
			alignDisplay( );
			updateMaskShape();
			
			calculateUnionRect();
			
			// Do the rest...
			calculatePadding( );
			calculateBorder( );

			
			// Start drawing
			graphics.clear( );
			
			// Create Border
			if(hasBorder)
			{
				drawBorder( );
			}
			
			if(! isNaN( _backgroundColor ))
			{
				drawBackgroundColor( );
			}
			
			drawBackgroundImage( );
						
			graphics.endFill( );
			
			// Dispatch event (duplicated from AbstractDisplay)
			dispatchEvent( new CamoDisplayEvent( CamoDisplayEvent.DRAW, _bubblingDraw ) );

		}
		
		override protected function calculatePadding():void
		{
			// Take content w,h + padding to calculate padding size, considering overflow visibility
			if (display === _emptyDisplay) return;
			$calculatePadding();	
		}

		
		protected function get addWidth():Number {
			return _paddingLeft + _borderLeft + _borderRight + _paddingRight;
		}
		protected function get addHeight():Number {
			return _paddingTop + _borderTop + _borderBottom + _paddingBottom;
		}
		
		// ISCroll
		
		public function set scrollH (ratio:Number):void {
			_iScroll.scrollH = ratio;
			_scrollH = ratio;
		}
		
		public function set scrollV (ratio:Number):void {
			_iScroll.scrollV = ratio;
			_scrollV = ratio;
		}
		
		// IScrollable
		/**  A sprite container that can be used to provide scroll-wheeling support or receive focus.  */
		public function get scrollContainer ():Sprite {
			return this;
		}
		
		/** A displayObject or rectangle of the screen mask containing the content  */
		public function get scrollMask ():* {
			return maskRect;
		}

		/** The actual content to scroll  */
		public function get scrollContent ():DisplayObject {
			return display;
		}
		
		/** Resets scroll back to default values, and normally cancels any current movement */
		public function resetScroll():void {
			_isOpen = false;
			_iScroll.resetScroll();
		}
		
		
		/** Gets on-screen item length (which is useful for snap-scrolling to unit lengths) */
		public function get itemLength ():Number {
			return 0;
		}
		
		/** Re-sets on-screen item length to something else */
		public function set itemLength(val:Number):void {
			// N/A
		}

		// Destructor
		
		override public function destroy():void {
			super.destroy();
			if (hasEventListener(Event.SCROLL)) $removeEventListener(Event.SCROLL, onScroll);
			$removeEventListener(OPEN, openHandler);
			$removeEventListener(CLOSE, closeHandler);
			$removeEventListener(TOGGLE, toggleOpenCloseHandler);
		}
		
	}

}