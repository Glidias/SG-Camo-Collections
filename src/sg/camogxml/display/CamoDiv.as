package sg.camogxml.display 
{
	import camo.core.display.CamoDisplay;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import sg.camo.events.OverflowEvent;
	import sg.camo.interfaces.IDiv;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.notifications.GDisplayNotifications;
	/**
	 * A standard CamoDisplay container that is layoutable under DivLayoutBehaviour.
	 * 
	 * @see sg.camo.behaviour.DivLayoutBehaviour
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDiv extends CamoDisplay implements IDiv, IListItem, IReflectClass
	{
		// -- IDiv boiler plate
		protected var _displayFlow:String = "block";
		protected var _position:String = "static";
		protected var _left:Number = 0;
		protected var _top:Number = 0;
		protected var _bottom:Number = Number.NaN;
		protected var _right:Number = Number.NaN;
		
		protected var _lineHeight:Number = 0;
		protected var _overflowVisible:Boolean = false;
		
		public function CamoDiv() 
		{
			_zIndex = 0;
		}
		
		public function get reflectClass():Class {
			return CamoDiv;
		}
		
		override public function set zIndex(val:Number):void {
			if (val == _zIndex) return;
			super.zIndex  = int(val);
			dispatchEvent( new Event(GDisplayNotifications.Z_INDEX_CHANGE, true) );
		}
		
		/**
		 * Stage instance setter to set initial width/height of DIV 
		 * through Flash IDE by matching with the staged spacer's dimensions. 
		 * <br/><br/>
		 * Take note that padding/border settings has
		 * to be declared elsewhere if required. The current 
		 * width/height, can also get overwritten elsewhere as well by
		 * code/CSS.
		 */
		public function set spacer(val:DisplayObject):void {
			_width = val.width;
			_height = val.height;
			val.visible = false;
		}
		
		/**
		 * Stage instance or generic setter to set up a different Sprite reference
		 * from the default native Sprite class being used. The staged position of the sprite
		 * is resetted to zero always. To position the sprite, you need to do it
		 * manually by adjusting the border/padding settings through code/CSS.
		 */
		public function set displaySprite(spr:Sprite):void {
			display = spr;
			spr.x = 0;
			spr.y = 0;
			if (spr.parent !== this) {
				$addChild(spr);
			}
		}
		
		/** @private */
		protected function set $overflow(str:String):void {
			super.overflow = str;
		}
		
		/**
		 * Also considers additional "visible" setting to allow contents to bleed
		 * out of container if contents exceed container's dimensions.
		 */
		override public function set overflow(str:String):void {
			_overflowVisible = str === "visible";
			super.overflow = str;
		}
		
		/*
		override public function get width():Number {
			return _overflowVisible ? _width : super.width;
		}
		override public function get height():Number {
			return _overflowVisible ? _height : super.height;
		}
		*/
		
		/** @private */
		protected function $calculatePadding():void {
			super.calculatePadding();
		}
		
		/** @private */
		override protected function calculatePadding():void
		{
			// Take content w,h + padding to calculate padding size, considering overflow visibility
			var dW:Number = _overflowVisible ? _width : displayWidth;
			var dH:Number = _overflowVisible ? _height : displayHeight;
			_paddingRectangle.width = _paddingLeft + dW + _paddingRight;
			_paddingRectangle.height = _paddingTop + dH + _paddingBottom;
			_paddingRectangle.x = _borderLeft;
			_paddingRectangle.y = _borderTop;
		}
		
		/** @private */
		override protected function clearOverflow():void {
			super.clearOverflow();
			dispatchEvent( new OverflowEvent(OverflowEvent.NONE) );
			_bubblingDraw = true;
			invalidate();
		}
		
		/** @private */
		override protected function activateOverflowHidden():void {
			super.activateOverflowHidden();
			dispatchEvent( new OverflowEvent(OverflowEvent.HIDDEN) );
			_bubblingDraw = true;
			invalidate();
		}

		/** @private */
		override protected function activateOverflowScroll():void
		{
			dispatchEvent( new OverflowEvent(OverflowEvent.SCROLL) );
		}
		
		/** @private */
		override protected function activateOverflowAuto():void
		{
			super.activateOverflowHidden();
			dispatchEvent( new OverflowEvent(OverflowEvent.AUTO) );
			_bubblingDraw = true;
			invalidate();
		}
		
		
		// -- IDiv boiler-plate
		
		public function set displayFlow(str:String):void {
			_displayFlow = str;
			_bubblingDraw = true;
			invalidate();
		}
		public function get displayFlow():String {
			return _displayFlow;
		}
		
		public function set position(str:String):void {
			_position = str;
			_bubblingDraw = true;
			invalidate();
		}
		public function get position():String {
			return _position;
		}
		
		public function set left(num:Number):void {
			_left = num;
			_bubblingDraw = true;
			invalidate();
		}
		public function get left():Number {
			return _left;
		}
		
		public function set top(num:Number):void {
			_top = num;
			_bubblingDraw = true;
			invalidate();
		}
		public function get top():Number {
			return _top;
		}
		
		public function set right(num:Number):void {
			_right = num;
			_bubblingDraw = true;
			invalidate();
		}
		public function get right():Number {
			return _right;
		}
		
		public function set bottom(num:Number):void {
			_bottom = num;
			_bubblingDraw = true;
			invalidate();
		}
		public function get bottom():Number {
			return _bottom;
		}




		
		
	}

}