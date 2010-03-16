﻿package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import flash.geom.ColorTransform;

	import camo.core.enum.CSSProperties;
	import camo.core.utils.TypeHelperUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IBehaviour;

	
	/**
	* Original BoxModel implementation of Camo's BoxModelDisplay factored out to a seperate behaviour.
	* Not fully tested as of yet.
	* 
	* @see camo.core.display.BoxModelDisplay
	* 
	* @author Glenn Ko
	*/
	public class BoxModelBehaviour implements IBehaviour
	{
		// needed?
		//public static const BACKGROUND_IMAGE_COMPLETE : String = "backgroundImageComplete";
		protected static const DELIMITER : String = " ";
		protected var _backgroundImageBitmap : Bitmap;
		protected var _paddingRectangle : Rectangle = new Rectangle( );
		protected var _borderRectangle : Rectangle = new Rectangle( );
		protected var _backgroundColor : Number;
		protected var _borderColor : Number;
		protected var _backgroundScale9Grid : Rectangle;
		protected var _backgroundRepeat : String;
		protected var _backgroundColorAlpha : Number;
		protected var _paddingTop : Number = 0;
		protected var _paddingRight : Number = 0;
		protected var _paddingBottom : Number = 0;
		protected var _paddingLeft : Number = 0;
		protected var _marginTop : Number = 0;
		protected var _marginRight : Number = 0;
		protected var _marginBottom : Number = 0;
		protected var _marginLeft : Number = 0;
		protected var _borderTop : Number = 0;
		protected var _borderRight : Number = 0;
		protected var _borderBottom : Number = 0;
		protected var _borderLeft : Number = 0;
		protected var _borderProperties : String;
		protected var _borderAlpha : Number = 1;
		protected var _backgroundPositionX : Number = 0;
		protected var _backgroundPositionY : Number = 0;
		protected var _backgroundImageAlpha : Number = 1;

		protected var _target:IDisplay;
		protected var display:DisplayObject;
		
		public static const NAME:String = "BoxModelBehaviour";
		
		
		/**
		 * Constructor.
		 * @param	targ	
		 */
		public function BoxModelBehaviour(targ:IDisplay=null)   
		{
			_target = targ;
		}
		
		public function activate(targ:*):void {
			_target = targ as IDisplay;
			_target.addEventListener( CamoDisplayEvent.DRAW, draw, false, 0, true);
			display = targ.getDisplay();
			_target.width = targ.width;
			_target.height = targ.height;
		}
		
		public function destroy():void {
			if (_target)  _target.removeEventListener( CamoDisplayEvent.DRAW, draw);

			display = null;
			_target = null;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		public function set backgroundColor(value : uint) : void
		{
			_backgroundColor = value;
			_target.invalidate( );	
		}
		
		public function get backgroundColor():uint
		{
			return _backgroundColor; 
		}
		
		public function set borderColor(value : uint) : void
		{
			_borderColor = value;
			_target.invalidate( );	
		}


		public function set backgroundPosition(value : String) : void
		{
			var split : Array = value.split( " ", 2 );
			backgroundPositionX = Number( split[0] );
			backgroundPositionY = Number( split[1] );
			_target.invalidate( );
			
		}


		public function set padding(values : Array) : void
		{
			values = validateOffset( values );
			paddingTop = values[0];
			paddingRight = values[1];
			paddingBottom = values[2];
			paddingLeft = values[3];
			_target.invalidate( );
		}


		public function get padding() : Array
		{
			return [ paddingTop, paddingRight, paddingBottom, paddingLeft ];	
		}


		public function set margin(values : Array) : void
		{
			values = validateOffset( values );
			marginTop = values[0];
			marginRight = values[1];
			marginBottom = values[2];
			marginLeft = values[3];
			_target.invalidate( );
		}


		public function get margin() : Array
		{
			return [ marginTop, marginRight, marginBottom, marginLeft ];	
		}
		
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		public function set width(val:Number) : void
		{
			_width = val;
		}

		public function set height(val:Number) : void
		{
			_height = val;
		}

		public function resize(w:Number, h:Number):void {
			_width = w;
			_height = h;
		}
		
		public function get width():Number {
			return _width > 0 ? _width + _paddingLeft + _paddingRight + _borderLeft + _borderRight : $width;
		}
		public function get height():Number {
			return _height > 0 ? _height + _paddingTop + _paddingBottom + _borderTop + _borderBottom : $height;
		}
		protected function get $width() : Number
		{
			var tempWidth : Number = (display.width > _target.width) ? display.width : _target.width;
			return borderLeft + paddingLeft + tempWidth + paddingRight + borderRight;
		}

		protected function get $height() : Number
		{
			var tempHeight : Number = (display.height > _target.height) ? display.height : _target.height;
			return borderTop + paddingTop + tempHeight + paddingBottom + borderBottom;
		}

	
		public function set border(value : String) : void
		{
			var values : Array = value.split( DELIMITER, 4 );
			
			borderTop = borderRight = borderBottom = borderLeft = values[0];
			borderProperties = values[1];
			_borderColor = TypeHelperUtil.stringToUint( values[2] );
			borderAlpha = Number( values[3] );
			_target.invalidate( );
		}

	
		public function get hasBorder() : Boolean
		{
			var value : Number = borderTop + borderRight + borderBottom + borderLeft;
			return Boolean( value );
		}



	
		protected function get displayHeight() : Number
		{
			return (display.height > _target.height) ? display.height : _target.height;
		}
		protected function get displayWidth():Number {
			return (display.width > width) ? display.width : _target.width;
		}
		public function get backgroundScale9Grid() : Rectangle
		{
			return _backgroundScale9Grid;
		}

		public function set backgroundScale9Grid(backgroundScale9Grid : Rectangle) : void
		{
			_backgroundScale9Grid = backgroundScale9Grid;
			_target.invalidate( );
		}

		public function get backgroundRepeat() : String
		{
			return _backgroundRepeat;
		}

		public function set backgroundRepeat(backgroundRepeat : String) : void
		{
			_backgroundRepeat = backgroundRepeat;
			_target.invalidate( );
		}

		public function get backgroundColorAlpha() : Number
		{
			return _backgroundColorAlpha;
		}

		public function set backgroundColorAlpha(backgroundColorAlpha : Number) : void
		{
			_backgroundColorAlpha = backgroundColorAlpha;
			_target.invalidate( );
		}

		public function get paddingTop() : Number
		{
			return _paddingTop;
		}

		public function set paddingTop(paddingTop : Number) : void
		{
			_paddingTop = paddingTop;
			_target.invalidate( );
		}

		public function get paddingRight() : Number
		{
			return _paddingRight;
		}

		public function set paddingRight(paddingRight : Number) : void
		{
			_paddingRight = paddingRight;
			_target.invalidate( );
		}

		public function get paddingBottom() : Number
		{
			return _paddingBottom;
		}

		public function set paddingBottom(paddingBottom : Number) : void
		{
			_paddingBottom = paddingBottom;
			_target.invalidate( );
		}

		public function get paddingLeft() : Number
		{
			return _paddingLeft;
		}

		public function set paddingLeft(paddingLeft : Number) : void
		{
			_paddingLeft = paddingLeft;
			_target.invalidate( );
		}

		public function get marginTop() : Number
		{
			return _marginTop;
		}

		public function set marginTop(marginTop : Number) : void
		{
			_marginTop = marginTop;
			_target.invalidate( );
		}

		public function get marginRight() : Number
		{
			return _marginRight;
		}

		public function set marginRight(marginRight : Number) : void
		{
			_marginRight = marginRight;
			_target.invalidate( );
		}

		public function get marginBottom() : Number
		{
			return _marginBottom;
		}

		public function set marginBottom(marginBottom : Number) : void
		{
			_marginBottom = marginBottom;
			_target.invalidate( );
		}

		public function get marginLeft() : Number
		{
			return _marginLeft;
		}

		public function set marginLeft(marginLeft : Number) : void
		{
			_marginLeft = marginLeft;
			_target.invalidate( );
		}

		public function get borderTop() : Number
		{
			return _borderTop;
		}

		public function set borderTop(borderTop : Number) : void
		{
			_borderTop = borderTop;
			_target.invalidate( );
		}

		public function get borderRight() : Number
		{
			return _borderRight;
		}

		public function set borderRight(borderRight : Number) : void
		{
			_borderRight = borderRight;
			_target.invalidate( );
		}

		public function get borderBottom() : Number
		{
			return _borderBottom;
		}

		public function set borderBottom(borderBottom : Number) : void
		{
			_borderBottom = borderBottom;
			_target.invalidate( );
		}

		public function get borderLeft() : Number
		{
			return _borderLeft;
		}

		public function set borderLeft(borderLeft : Number) : void
		{
			_borderLeft = borderLeft;
			_target.invalidate( );
		}

		public function get borderProperties() : String
		{
			return _borderProperties;
		}

		public function set borderProperties(borderProperties : String) : void
		{
			_borderProperties = borderProperties;
			_target.invalidate( );
		}

		public function get borderAlpha() : Number
		{
			return _borderAlpha;
		}

		public function set borderAlpha(borderAlpha : Number) : void
		{
			_borderAlpha = borderAlpha;
			_target.invalidate( );
		}

		public function get backgroundPositionX() : Number
		{
			return _backgroundPositionX;
		}

		public function set backgroundPositionX(backgroundPositionX : Number) : void
		{
			_backgroundPositionX = backgroundPositionX;
			_target.invalidate( );
		}

		public function get backgroundPositionY() : Number
		{
			return _backgroundPositionY;
		}

		public function set backgroundPositionY(backgroundPositionY : Number) : void
		{
			_backgroundPositionY = backgroundPositionY;
			_target.invalidate( );
		}

		/*
		public function get debugPadding() : Boolean
		{
			return _debugPadding;
		}

		public function set debugPadding(debugPadding : Boolean) : void
		{
			_debugPadding = debugPadding;
			_target.invalidate( );
		}

		public function get debugPaddingColor() : uint
		{
			return _debugPaddingColor;
		}

		public function set debugPaddingColor(debugPaddingColor : uint) : void
		{
			_debugPaddingColor = debugPaddingColor;
			_target.invalidate( );
		}*/

		public function get backgroundImageBitmap() : Bitmap
		{
			return _backgroundImageBitmap;
		}

		public function set backgroundImageBitmap(backgroundImageBitmap : Bitmap) : void
		{
			_backgroundImageBitmap = backgroundImageBitmap;
			_target.invalidate ( );
		}

		public function get backgroundImageAlpha() : Number
		{
			return _backgroundImageAlpha;
		}

		public function set backgroundImageAlpha(backgroundImageAlpha : Number) : void
		{
			_backgroundImageAlpha = backgroundImageAlpha;
			_target.invalidate( );
		}

	
		 public function getBounds(targetCoordinateSpace : DisplayObject) : Rectangle
		{
			var bounds : Rectangle = (_target as DisplayObject).getBounds( targetCoordinateSpace ).clone( );
			bounds.width = width;
			bounds.height = height;
			return bounds;
		}

	
		 public function getRect(targetCoordinateSpace : DisplayObject) : Rectangle
		{
			var rect : Rectangle = (_target as DisplayObject).getRect( targetCoordinateSpace ).clone( );
			rect.width = width;
			rect.height = height;
			return rect;
		}

	
		protected function sampleBackground(tempBitmap : Bitmap) : void
		{
			var srcW : Number = tempBitmap.width;
			var srcH : Number = tempBitmap.height;
			
			var bmd : BitmapData = new BitmapData( srcW, srcH, true, 0x00FFFFFF );
			bmd.draw( tempBitmap );
			
			_backgroundImageBitmap = createBackgroundBitmap( bmd );
			
			if(backgroundScale9Grid) 
			{
				_backgroundImageBitmap.scale9Grid = backgroundScale9Grid;
			}
			
			//dispatchEvent( new Event( BACKGROUND_IMAGE_COMPLETE, true, true ) );
			_target.invalidate( );
		}


		protected function createBackgroundBitmap(bitmapData : BitmapData) : Bitmap
		{
			return new Bitmap( bitmapData );
		}
		
		 public function get graphics():Graphics {
			return (_target as Sprite).graphics;
		}
		
		 public function get x():Number {
			return _target.x;
		}
		 public function get y():Number {
			return _target.y;
		}
		public function dispatchEvent(e:Event):void {
			(_target as IEventDispatcher).dispatchEvent(e);
		}


	
		protected function draw(e:Event) : void
		{
			//trace("Handling draw.."+e.target);
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
			
			// Align Content
			alignDisplay( );
			
				 
		}	

	
		protected function calculatePadding() : void
		{
			// Take content w,h + padding to calculate padding size
			_paddingRectangle.width = paddingLeft + displayWidth + paddingRight;
			_paddingRectangle.height = paddingTop + displayHeight + paddingBottom;
			_paddingRectangle.x = borderLeft;
			_paddingRectangle.y = borderTop;
		}

	
		protected function calculateBorder() : void
		{
			_borderRectangle.width = _paddingRectangle.width + borderLeft + borderRight;
			_borderRectangle.height = _paddingRectangle.height + borderTop + borderBottom;
		}

	
		protected function drawBorder() : void
		{
			graphics.beginFill( _borderColor, borderAlpha );
			graphics.drawRect( _borderRectangle.x, _borderRectangle.y, _borderRectangle.width, _borderRectangle.height );
			graphics.drawRect( borderLeft, borderTop, _paddingRectangle.width, _paddingRectangle.height );
		}

	
		protected function drawBackgroundImage() : void
		{
			//
			if(_backgroundImageBitmap)
			{
				var bgiFullW : Number = paddingLeft +  + paddingRight;
				var bgiFullH : Number = paddingTop + displayHeight + paddingBottom;
				
				var bgiW : Number = _backgroundImageBitmap.width;
				var bgiH : Number = _backgroundImageBitmap.height;
				
				var bgX : Number = _paddingRectangle.x;
				var bgY : Number = _paddingRectangle.y;
				
				var m : Matrix = new Matrix( );
				
				var bmd : BitmapData = new BitmapData( bgiW, bgiH, true, 0x00FFFFFF );

				switch (backgroundRepeat)
				{
					case CSSProperties.NO_REPEAT:
						bgX = backgroundPositionX+borderLeft;
						bgY = backgroundPositionY+borderTop;
						m.translate( bgX, bgY );
						break;
					case CSSProperties.REPEAT_X:
						bgiW = bgiFullW;
						m.translate( borderLeft, borderTop );
						break;
					case CSSProperties.REPEAT_Y:
						bgiH = bgiFullH;
						m.translate( borderLeft, borderTop );							
						break;
					default:
						bgiW = bgiFullW;
						bgiH = bgiFullH;
						m.translate( borderLeft, borderTop );
						break;
				}

				bmd.draw( _backgroundImageBitmap, null, new ColorTransform( 1, 1, 1, backgroundImageAlpha ) );
				graphics.beginBitmapFill( bmd, m, true, false );
				graphics.drawRect( bgX, bgY, bgiW, bgiH );
				graphics.endFill( );
			}
		}

	
		protected function drawBackgroundColor() : void
		{
			backgroundColorAlpha = isNaN( backgroundColorAlpha ) ? 1 : backgroundColorAlpha;
			
			var tempColor: uint = _backgroundColor; // _debugPadding ? _debugPaddingColor : 
			
			graphics.beginFill( tempColor, backgroundColorAlpha );
			graphics.drawRect( _paddingRectangle.x, _paddingRectangle.y, _paddingRectangle.width, _paddingRectangle.height );
			graphics.endFill( );
			
			/*
			if(_debugPadding)
			{
				graphics.beginFill( _backgroundColor, backgroundColorAlpha );
				graphics.drawRect( display.x, display.y, , displayHeight );
				graphics.endFill( );
			}*/
		}

	
		protected function alignDisplay() : void
		{
			display.x = paddingLeft + borderLeft;
			display.y = paddingTop + borderTop;
		}

	
		protected function resetBackgroundPosition() : void
		{
			backgroundPositionX = backgroundPositionY = 0;
		}

		
		public function clearProperties() : void
		{
			clearPadding( );
			clearMargin( );
			clearBorder( );
			clearBackground( );
		}

	
		public function clearPadding() : void
		{
			padding = [ 0,0,0,0 ];
		}

	
		public function clearMargin() : void
		{
			margin = [ 0, 0, 0, 0 ];
		}

	
		public function clearBorder() : void
		{
			borderAlpha = 1;
			borderLeft = borderRight = borderBottom = borderLeft = 0;
			_borderColor = NaN;			
		}

	
		public function clearBackground() : void
		{
			_backgroundImageBitmap = null;
			_backgroundColor = NaN;
			backgroundColorAlpha = NaN;
		}

		protected function validateOffset(values : Array) : Array 
		{
			
			var total : Number = values.length;
			var offset : Array;
			
			if(total == 1)
			{
				var baseValue : Number = values[0];
				offset = [ baseValue, baseValue, baseValue, baseValue ];
			}
			else if (total == 2)
			{
				var tbValue : Number = values[0];
				var lrValue : Number = values[1];
				offset = [ tbValue, lrValue, tbValue, lrValue ];
			}
			else
			{
				for (var i : Number = 0; i < 4 ; i ++)
				{
					if (! values[i]) values[i] = 0; 
				}
				offset = [ values[0], values[1], values[2], values[3] ];
			}
			
			return offset;
		}
		
		
		
	}
	
}