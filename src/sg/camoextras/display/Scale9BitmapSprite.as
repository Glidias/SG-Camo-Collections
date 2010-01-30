/*
 Copyright (c) 2009 Paulius Uza  <paulius@uza.lt>
 http://www.uza.lt
 All rights reserved.
  
 Permission is hereby granted, free of charge, to any person obtaining a copy 
 of this software and associated documentation files (the "Software"), to deal 
 in the Software without restriction, including without limitation the rights 
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished 
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all 
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@ignore
*/

/**
 * Original class: lt.uza.ui.Scale9BitmapSprite<br/>
 * http://www.uza.lt
 * 
 * Repackaged under SG-Camo.
 * @author Glenn
 */

package sg.camoextras.display
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IResizable;

	
	/**
	 * Scale9Bitmap in Sprite container format.<br/><br/>
	 * Repackaged under SG-Camo to allow seamless integration with <code>SkinBehaviour</code>
	 * and <code>Scale9SimpleStateBehaviour</code>.
	 * <br/><br/>
	 * Original class: lt.uza.ui.Scale9BitmapSprite<br/>
	 * http://www.uza.lt
	 * 
	 * @see sg.camo.behaviour.SkinBehaviour
	 * @see sg.camoextras.behaviour.Scale9SimpleStateBehaviour
	 * 
	 * @author Paulius Uza
	 * @author Glenn Ko
	 * 
	 */
	public class Scale9BitmapSprite extends Sprite implements IResizable, IDestroyable
	{
		/**
		 * CONTAINERS FOR SCALE 9
		 */
		 
		private var topLeftCorner:Sprite
		private var topRightCorner:Sprite;
		private var bottomLeftCorner:Sprite;
		private var bottomRightCorner:Sprite;
		private var topRectangle:Sprite;
		private var leftRectangle:Sprite;
		private var rightRectangle:Sprite;
		private var bottomRectangle:Sprite;
		private var mainRectangle:Sprite;

		/**
		 * PROPERTIES
		 */
		 
		private var verticalMarginSum:Number;
		private var horizontalMarginSum:Number;
		private var innerWidth:Number;
		private var innerHeight:Number;
		private var bd:BitmapData;
		private var sc:Rectangle;
		
		/**
		 * RECTANGLES FOR COORDINATES
		 */
		 
		private var _TL:Rectangle;
		private var _TR:Rectangle;
		private var _BR:Rectangle;
		private var _BL:Rectangle;
		private var _T:Rectangle;
		private var _R:Rectangle;
		private var _B:Rectangle;
		private var _L:Rectangle;
		
		
		/**
		 * CACHED
		 */
		private var _move:Matrix = new Matrix();
		private var _constructed:Boolean = false;
		/** Flag to determine whether to clone bitmapData source states for current class.
		*/
		protected var cloneSource:Boolean = true;
		/**
		 * Default setting to whether to clone sources for this class.
		 */
		public static var CLONE_SOURCE:Boolean = true;
	 
	 /**
	  * Constructor
	  * @param	bitmapData
	  * @param	grid		The scale9grid
	  * @param	cloneSource	(Optional. Will use default static variable setting) 
	  * 	Set to 0 to NOT clone sources, anything higher than 0 (ie. 1) to enable cloning of source bmpData.<br/>
	  */
		public function Scale9BitmapSprite(bitmapData:BitmapData=null, scale9Grid:Rectangle=null, cloneSource:int=-1 )
		{
			this.cloneSource = cloneSource > -1 ? cloneSource > 0 : CLONE_SOURCE;
			this.bd = bitmapData != null ? cloneSource ? bitmapData.clone() : bitmapData : null;
			this.scale9Grid = scale9Grid;
			if (bitmapData != null && scale9Grid != null) {
				construct();
			}
			
		}
		
		override public function set scale9Grid(rect:Rectangle):void {
			 sc = rect;
		}
		
		override public function get scale9Grid():Rectangle {
			return sc;
		}
		
		
		
		
		
		/** @private */
		private function construct():void {
			if (_constructed) return;
			_constructed = true;
			var lx:Number = 0;					// LEFT
			var mx:Number = sc.x;				// MIDDLE
			var rx:Number = sc.x+sc.width;		// RIGHT
			
			var ty:Number = 0;					// TOP
			var my:Number = sc.y;				// MIDDLE
			var by:Number = sc.y+sc.height; 	// BOTTOM
			
			var m_bottom:Number = bd.height - by
			var m_right:Number = bd.width - rx;
			
			horizontalMarginSum = bd.width - sc.width;
			verticalMarginSum = bd.height - sc.height;
			
			// CORNERS
			_TL = new Rectangle(0,0,mx,sc.y);	
			_TR = new Rectangle(rx,0,m_right,sc.y);
			_BR = new Rectangle(rx,by,m_right,m_bottom);
			_BL = new Rectangle(0,by,mx,m_bottom);
			
			topLeftCorner = createRectangle(_TL);
			topRightCorner = createRectangle(_TR);
			bottomRightCorner = createRectangle(_BR);
			bottomLeftCorner = createRectangle(_BL);
			
			// RESIZABLE
			_T = new Rectangle(sc.x,0,sc.width,sc.y);
			_R = new Rectangle(rx,sc.y,m_right,sc.height);
			_B = new Rectangle(sc.x,by,sc.width,m_bottom);
			_L = new Rectangle(0,sc.y,mx,sc.height);
			
			topRectangle = createRectangle(_T);
			rightRectangle = createRectangle(_R);
			bottomRectangle = createRectangle(_B);
			leftRectangle = createRectangle(_L);
			
			// MAIN RECTANGLE
			mainRectangle = createRectangle(sc);
		}
		

		public function set bitmapData(bmpData:BitmapData):void {
			if (!_constructed) {
				this.bd = cloneSource ? bmpData.clone() : bmpData;
				construct();
				return;
			}
			updateState(bmpData);
		}
		
		public function set grid (rect:Rectangle):void {
			sc = rect; 
			if (bd == null || rect==null) return;
			construct();
		}
		
		public function resize(w:Number, h:Number):void {
			width = w;
			height  = h;
			//updateRects();
		}
		public function destroy():void {
			if (cloneSource) {
				bd.dispose();
			}
		}
		
		
		
		
		 /**
		  * Main state update function to change bitmapData. Consider also using bitmapData setter.
		  * @param	bitmapData new BitmapData object that will replace the current one, all elements are redrawn automatically.
		  * <br/>NOTE: STATE DIMENSIONS MUST MATCH!
		  */
		public function updateState(bitmapData:BitmapData):void {
			if (!_constructed) {
				throw(new Error("Scale9BitmapSprite updateState() halt! scale 9 bitmap is not constructed!"));
				return;
			}
			if (bitmapData.width != bd.width || bitmapData.height != bd.height) {
				throw(new Error("New and old bitmapData dimensions must be equal"));
				return;
			}
			bd = bitmapData;// bitmapData.clone(); 	// NOTE: took out clone
			updateRects();
		}
		
		
		
		/**
		 * @private
		 */
		protected function updateRects():void {
			updateRectangle(topRectangle,_T);
			updateRectangle(rightRectangle,_R);
			updateRectangle(bottomRectangle,_B);
			updateRectangle(leftRectangle,_L);
			updateRectangle(topLeftCorner,_TL);
			updateRectangle(topRightCorner,_TR);
			updateRectangle(bottomRightCorner,_BR);
			updateRectangle(bottomLeftCorner,_BL);
			updateRectangle(mainRectangle,sc);
		}
		
		/**
		 * Width Variable Override
		 * Re-positions and re-scales elements on the screen according to new size of the container
		 */
		 
		override public function set width(width : Number) : void {
			innerWidth = width - horizontalMarginSum;
			topRectangle.width = mainRectangle.width = bottomRectangle.width = innerWidth;
			var newLeft : Number = mainRectangle.x + mainRectangle.width;
			topRightCorner.x = newLeft;
			bottomRightCorner.x = newLeft;
			rightRectangle.x = newLeft;
		}
		
		/**
		 * Height Variable Override
		 * Re-positions and re-scales elements on the screen according to new size of the container
		 */

		override public function set height(height : Number) : void {
			innerHeight = height - verticalMarginSum;
			leftRectangle.height = mainRectangle.height = rightRectangle.height = innerHeight;
			var newTop : Number = mainRectangle.y + mainRectangle.height;
			bottomLeftCorner.y = newTop;
			bottomRightCorner.y = newTop;
			bottomRectangle.y = newTop;
		} 
		
		/**
		 * scaleX Variable Override
		 * Re-positions and re-scales elements on the screen according to new size of the container
		 */
		
		override public function set scaleX(scale:Number):void {
			this.topRectangle.scaleX = this.mainRectangle.scaleX = this.bottomRectangle.scaleX = scale;
			var newLeft:Number = this.mainRectangle.x + this.mainRectangle.width;
			this.topRightCorner.x = newLeft;
			this.bottomRightCorner.x = newLeft;
			this.rightRectangle.x = newLeft;
		}
		
		/**
		 * ScaleX Variable Override
		 * Returns current scaleX value of the central rectangle
		 */
		
		override public function get scaleX():Number {
			return this.mainRectangle.scaleX;
		}
		
		/**
		 * scaleY Variable Override
		 * Re-positions and re-scales elements on the screen according to new size of the container
		 */
		
		override public function set scaleY(scale:Number):void {
			this.leftRectangle.scaleY = this.mainRectangle.scaleY = this.rightRectangle.scaleY = scale;
			var newTop:Number = this.mainRectangle.y + this.mainRectangle.height;
			this.bottomLeftCorner.y = newTop;
			this.bottomRightCorner.y = newTop;
			this.bottomRectangle.y = newTop;
			
		}
		
		
		/**
		 * ScaleY Variable Override
		 * Returns current scaleY value of the central rectangle
		 */
		
		override public function get scaleY():Number {
			return this.mainRectangle.scaleY;
		}
		
		/**
		 * @private
		 * Updates a scale9 sprite with the new bitmap data
		 */
		 
		protected function updateRectangle(sprite:Sprite, rect:Rectangle):void {
			var xPos:Number = rect.x;
			var yPos:Number = rect.y;
			var w:Number = rect.width;
			var h:Number = rect.height;
			var move:Matrix = _move;
			move.identity();
			move.translate(-xPos,-yPos);
			with(sprite.graphics) {
				clear();
				beginBitmapFill(bd,move,false);
				drawRect(0,0,w,h);
				endFill();
			}
		}
		
		/**
		 * @private
		 * Creates a scale9 sprite from initial bitmap data
		 */
		
		protected function createRectangle(rect:Rectangle):Sprite	{
			var xPos:Number = rect.x;
			var yPos:Number = rect.y;
			var w:Number = rect.width;
			var h:Number = rect.height;	
			var sprite:Sprite = new Sprite();
			var move:Matrix = new Matrix();
				move.translate(-xPos,-yPos);
			sprite.graphics.beginBitmapFill(bd,move,false);
			sprite.graphics.drawRect(0,0,w,h);
			sprite.graphics.endFill();
			sprite.x = xPos;
			sprite.y = yPos;
			addChild(sprite);
			return sprite;
		}
	}
}