package sg.camoextras.display.shape 
{
	import camo.core.display.IDisplay;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import sg.camo.interfaces.IRefreshable;
	import sg.camo.interfaces.IResizable;

	/**
	 * A rectangular shape with feathered edges
	 * @author Glenn Ko
	 */
	public class FeatherRectangle extends Shape implements IResizable, IRefreshable
	{
		
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		
		protected var _borderTop:Number = 0;
		protected var _borderLeft:Number = 0;
		protected var _borderRight:Number = 0;
		protected var _borderBottom:Number = 0;
		
		protected var _myScale9Grid:Rectangle = new Rectangle();
		
		
		protected var _calculateWithBorder:Boolean = true;
		public function set calculateWithBorder(val:Boolean):void {
			_calculateWithBorder = val;
		}
		public function get calculateWithBorder():Boolean {
			return _calculateWithBorder;
		}
		
		protected var _rectColor:uint = 0;
		public function set rectColor(val:uint):void {
			_rectColor = val;
		}
		public function get rectColor():uint {
			return _rectColor;
		}
		protected var _rectAlpha:Number = 1;
		
		private static const FIXED_SIZE:Number = 32;
		private static const degToRad:Number = Math.PI / 180;
		private static const MIN_VALUE:Number = .1;
		
		public function FeatherRectangle() 
		{
			borderThickness = .1;
			refresh();
		}
		
		public function refresh():void {
			
			var dW:Number =  _calculateWithBorder ? _width -_borderLeft - _borderRight : _width;
			var dH:Number =  _calculateWithBorder ? _height -_borderTop - _borderBottom : _height;

			
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, _width, _height);

			
			graphics.beginFill(0xFF0000, 1 );
			graphics.drawRect(_borderLeft, _borderTop, dW  , dH );
		
			
			var matrix:Matrix = new Matrix();
			

			
			if (_borderLeft > 0 ) {
				matrix.identity();
				matrix.createGradientBox(_borderLeft, dW+_borderTop, 0, 0, 0);
				graphics.beginGradientFill(GradientType.LINEAR, [_rectColor, _rectColor], [0, 100], [0, 255], matrix); 
				graphics.drawRect(0, _borderTop, _borderLeft, dH);
			}
			if (_borderRight > 0) {
				matrix.identity();
				matrix.createGradientBox(_borderRight, dW, -180*degToRad,  _borderLeft + dW, _borderTop);
				
				graphics.beginGradientFill(GradientType.LINEAR, [_rectColor, _rectColor], [0, 100], [0, 255], matrix); 
				
				graphics.drawRect(_borderLeft + dW, _borderTop, _borderRight, dH);
			}
			if (_borderTop > 0 ) {
				matrix.identity();
				matrix.createGradientBox(dW, _borderTop, 90*degToRad, 0, 0);
				graphics.beginGradientFill(GradientType.LINEAR, [_rectColor, _rectColor], [0, 100], [0, 255], matrix); 
				graphics.drawRect(_borderLeft, 0, dW, _borderTop);
			}
			if (_borderBottom > 0) {
				matrix.identity();
				matrix.createGradientBox(dW, _borderBottom, -90*degToRad, _borderLeft, _borderTop + dH);
				graphics.beginGradientFill(GradientType.LINEAR, [_rectColor, _rectColor], [0, 100], [0, 255], matrix); 
				graphics.drawRect(_borderLeft, _borderTop + dH, dW, _borderBottom);
			}
			
			x = _x;
			y = _y;
			
		}
		
		public function  resize(w:Number, h:Number):void {
			width = w;
			height = h;
			refresh();
		}
		
		public function set borderThickness(val:Number):void {
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_borderTop = val;
			_borderBottom = val;
			_borderLeft = val;
			_borderRight = val;
		}

		public function get borderTop() : Number
		{
			return _borderTop;
		}

		public function set borderTop(val : Number) : void
		{
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_borderTop = val;
			//invalidate( );
		}

		public function get borderRight() : Number
		{
			return _borderRight;
		}

		public function set borderRight(val : Number) : void
		{
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_borderRight = val;
			//invalidate( );
		}

		public function get borderBottom() : Number
		{
			return _borderBottom;
		}

		public function set borderBottom(val : Number) : void
		{
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_borderBottom = val;
			//invalidate( );
		}

		public function get borderLeft() : Number
		{
			return _borderLeft;
		}

		public function set borderLeft(val : Number) : void
		{
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_borderLeft = val;
			//invalidate( );
		}
		

		
		override public function set x(val:Number):void {
			_x = val;
			super.x = _calculateWithBorder ? val : val-_borderLeft;
		}
		override public function get x():Number {
			return _x;
		}
		
		override public function set y(val:Number):void {
			_y = val;
			super.y = _calculateWithBorder ? val : val-_borderTop;
		}
		override public function get y():Number {
			return _y;
		}
		
		
		override public function set width(val:Number):void {
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_width = val;
		}
		override public function get width():Number {
			return _width;
		}
		
		override public function set height(val:Number):void {
			val = val < MIN_VALUE ? MIN_VALUE : val;
			_height = val;
		}
		override public function get height():Number {
			return _height;
		}
		
		
		
		
		
		
	}

}