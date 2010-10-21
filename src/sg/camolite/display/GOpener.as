package sg.camolite.display 
{
	import camo.core.events.CamoDisplayEvent;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IOpenScrollProxy;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.scrollables.OpenCloseScrollProxy;
	
	/**
	* Base class for openable/sliding-popup/dropdown displays. Uses a mask based on display size.
	* Not every feature (particular maskPadding) has been tested fully , but a working example is already found in
	* the ./Flash SG_CamoLite Display/ under the SVN respository. You should be able to try
	* out the different open directions as well. 
	*
	* 
	* @author Glenn Ko
	*/
	public class GOpener extends GBaseDisplay implements IScrollable
	{
		// Negative values imply lower case vector (left/up) while positive values imply upper case vector. (right/down)
		public static const OPEN_LEFT:int = -1;
		public static const OPEN_NONE:int = 0;
		public static const OPEN_RIGHT:int = 1;
		public static const OPEN_UP:int = -2;
		public static const OPEN_DOWN:int = 2;
		
		/** @private */ protected var _openDirection:int = OPEN_DOWN;
		
		/** @private */ protected var maskShape:Shape;
		/** @private */ protected var _maskPaddingLeft:Number=0; 
		/** @private */ protected var _maskPaddingRight:Number=0; 
		/** @private */ protected var _maskPaddingBottom:Number=0; 
		/** @private */ protected var _maskPaddingTop:Number = 0; 
		

		/** @private  */ protected var _inited:Boolean = false;
		/** @private */ protected var _maskBounds:Rectangle = new Rectangle();
		/** @private */ protected var _iScroll:IOpenScrollProxy;
		
		/** @private */ protected var _isOpen:Boolean = false;
		/** @private */ protected var _btnOpen:Sprite;
		
		/** @private */ protected var _defaultScrollProxy:IOpenScrollProxy;
		
		/** @private */ protected var _scrollH:Number; // last saved scrollH value
		/** @private */ protected var _scrollV:Number; // last saved scrollV value
		
		public function GOpener(customDisp:Sprite=null) 
		{
			maskShape = new Shape();
			super(customDisp);
			_defaultScrollProxy = new OpenCloseScrollProxy(this);
			_iScroll = _defaultScrollProxy;
			
			
			maskShape.graphics.beginFill(0, .4);
			maskShape.graphics.drawRect(0, 0, 32, 32);
			display.mask = maskShape;
			$addChild(maskShape);
		}
		
		public function set direction(str:String):void {
			switch (str) {
				case "left": openDirection = OPEN_LEFT;  return;
				case "right": openDirection = OPEN_RIGHT;   return;
				case "up": openDirection = OPEN_UP;   return;
				case "down": openDirection = OPEN_DOWN;  return;
				default:return;
			}
		}
		
		override protected function draw():void {
			updateMaskShape();
			super.draw();
		}
		
		public function updateMaskShape():void {
			_maskBounds.x = maskShape.x;
			_maskBounds.y = maskShape.y;
			_maskBounds.width = display.width;
			_maskBounds.height = display.height;
			
			maskShape.graphics.clear();
			maskShape.graphics.beginFill(0xFF0000, .5);
			maskShape.graphics.drawRect(-_maskPaddingLeft, -_maskPaddingTop, _maskPaddingLeft + _maskPaddingRight + _maskBounds.width, _maskPaddingTop + _maskPaddingBottom + _maskBounds.height  );
		}
		
		/**
		 * Stage instance setter. Aligns maskshape to display sprite.
		 */
		override public function set displaySprite(spr:Sprite):void {
			super.displaySprite = spr;
			maskShape.x = spr.x;
			maskShape.y = spr.y;
			spr.mask = maskShape;
		}
		
		
		
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GOpener;
		}	
		
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			showDefaultOpenState();
		}	
		
		protected function showDefaultOpenState():void {
			_iScroll.resetScroll();
			display.x = maskShape.x;
			display.y = maskShape.y;
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
		
		/**
		 * <b>[Stage instance]</b> to set up opener button.
		 */
		public function set btnOpen(spr:Sprite):void {
			_btnOpen = spr;
			spr.buttonMode = true;
			spr.addEventListener(MouseEvent.CLICK, openBtnClickHandler, false, 0, true);
		}
		
		/**
		 * Sets opening direction to one of the OPEN_{direction} constants .
		 */
		public function set openDirection(val:int):void {
			_openDirection = val;
			if (stage) {
				updateMaskShape();
				showDefaultOpenState();
			}
		}
		
		/** @private */
		protected function openBtnClickHandler(e:MouseEvent):void {
			open = !open;
		}
		
		
		/**
		 * Sets up new IOpenScrollProxy proxy variation
		 */
		public function set iScroll(scrollProxy:IOpenScrollProxy):void {
			_iScroll = scrollProxy;
			_iScroll.target = this;
		}
		public function get iScroll():IOpenScrollProxy {
			return _iScroll;
		}
		
		/**
		 * Sets open/close state. 
		 */
		public function set open(boo:Boolean):void {
			if (boo == _isOpen) return;
			_isOpen = boo;
			if (boo) doOpen()
			else doClose();
		}
		public function get open():Boolean {
			return _isOpen;
		}
		
		public function set isOpen(boo:Boolean):void {	
			if (stage) open = boo
			else _isOpen = boo;
		}
		public function get isOpen():Boolean {
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
		}
	

	// -- Default IScrollable implementation

		public function set scrollH (ratio:Number):void {
			_iScroll.scrollH = ratio;
			_scrollH = ratio;
		}
		public function resetScroll():void {
			_isOpen = false;
			_iScroll.resetScroll();
		}
		
		public function set scrollV (ratio:Number):void {
			_iScroll.scrollV = ratio;
			_scrollV = ratio;
		}
		
		// ......................
		
		public function get scrollContainer ():Sprite { 
			return this;
		}
		public function get scrollMask ():* {  
			return _maskBounds; 
		}
		public function get scrollContent ():DisplayObject {
			return display;
		}
		public function get itemLength():Number {
			return 0;
		}
		public function set itemLength(val:Number):void {
			return;
		}
		
		
		/// Destructor
		
		override public function destroy():void {
			
			if (_btnOpen != null) {
				_btnOpen.removeEventListener(MouseEvent.CLICK, openBtnClickHandler);
				_btnOpen = null;
			}
			if (iScroll != null) iScroll.destroy();

			super.destroy();
		}
		
		// - mask padding setters
		
		public function set maskPaddingLeft(num:Number):void {
			_maskPaddingLeft  = num;
			invalidate();
		}
		public function get maskPaddingLeft():Number {
			return _maskPaddingLeft;
		}
		public function set maskPaddingRight(num:Number):void {
			_maskPaddingRight  = num;
			invalidate();
		}
		public function get maskPaddingRight():Number {
			return _maskPaddingRight;
		}
		public function set maskPaddingBottom(num:Number):void {
			_maskPaddingBottom = num;
			invalidate();
		}
		public function get maskPaddingBottom():Number {
			return _maskPaddingBottom;
		}
		public function set maskPaddingTop(num:Number):void {
			_maskPaddingTop  = num;
			invalidate();
		}
		public function get maskPaddingTop():Number {
			return _maskPaddingTop;
		}
		
	}
	
}