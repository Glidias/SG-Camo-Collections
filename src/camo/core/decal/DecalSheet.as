package camo.core.decal
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/** 
	 * <p>Original Author:  Jesse Freeman of FlashArtOfWar.com</p>
	 * <p>Class File: Decal.as</p>
	 * 
	 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
	 * of this software and associated documentation files (the "Software"), to deal
	 * in the Software without restriction, including without limitation the rights
	 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 * copies of the Software, and to permit persons to whom the Software is
	 * furnished to do so, subject to the following conditions:</p>
	 * 
	 * <p>The above copyright notice and this permission notice shall be included in
	 * all copies or substantial portions of the Software.</p>
	 * 
	 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	 * THE SOFTWARE.</p>
	 * 
	 * <p>Licensed under The MIT License</p>
	 * <p>Redistributions of files must retain the above copyright notice.</p>
	 *
	 * <p>Revisions<br/> 
	 * 	1.0  Initial version March 12, 2009</p>
	 *
	 *  
	 * @author Jesse Freeman http://www.jessefreeman.com
	 * 
	 */	
	public class DecalSheet extends Bitmap implements IDecalSheet
	{
		protected var decalRectangles : Dictionary = new Dictionary( true );
		public var decalNames : Array = new Array( );
		/**
		 * <p>Sheet constructor.</p>
		 * 
		 * @param bitmapData You must have BitmapData to set up a Sheet.
		 * This insures that when ever you request a Decal you get valid 
		 * BitmapData back.
		 * 
		 * @param pixelSnapping
		 * @param smoothing
		 * 
		 */	
		public function DecalSheet(bitmapData : BitmapData = null, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
			super( bitmapData, pixelSnapping, smoothing );
		}
		/**
		 * <p>This setter fires a "change" event to notify anything listening
		 * to this instance that the BitmapData has been changed.</p>
		 *  
		 * @param value
		 * 
		 */	
		override public function set bitmapData(value : BitmapData) : void
		{
			super.bitmapData = value;
			dispatchEvent( new Event( Event.CHANGE ) );	
		}
		/**
		 * 
		 * <p>You define a Decal's coordinates by supplying a name and rectangle.</p>
		 * 
		 * @param name The id used to look decals up.
		 * @param rectangle The x, y, width, and height of representing the Decal
		 * on the Sheet's BitmapData.
		 * 
		 */
		public function registerDecal(name : String, rectangle : Rectangle, scale9Rect : Rectangle = null) : void
		{
			decalRectangles[name] = rectangle;
			decalNames.push( name );
		}
		/**
		 * 
		 * <p>Removes the corresponding Decal Rectangle.</p>
		 * 
		 * @param name
		 * @return 
		 * 
		 */	
		public function deleteDecal(name : String) : Boolean
		{
			var index : Number = decalNames.indexOf( name );
			if(index != - 1)
				decalNames.splice( index, 1 );
				
			return delete decalRectangles[name];
		}
		/**
		 * 
		 * <p>Returns a new Decal Instance. Each Decal is given a reference to
		 * the Sheet it is cut out from. This allows the Decal to request
		 * its BitmapData on construction as well as update that BitmapData
		 * when the BitmapData of the Sheet is changed.</p>
		 * 
		 * @param name
		 * @return 
		 * 
		 */	
		public function getDecal(name : String, pixelSnapping : String = "auto", smoothing : Boolean = false) : Decal
		{
			return decalRectangles[name] ? new Decal( name, this, pixelSnapping, smoothing ) : null;
		}
		/**
		 * <p>This allows you to "sample" an area of the Decal based on the
		 * Rectangle you pass in. Use this to cut out a specific section of
		 * Bitmapdata.</p>
		 * 
		 * @param rect
		 * @return 
		 * 
		 */
		public function sample(name : String, smoothing : Boolean = false) : BitmapData
		{
			var rect : Rectangle = decalRectangles[name];
			
			// Applies the correct offset when sampling the data
			var m : Matrix = new Matrix( );
			m.translate( - rect.x, - rect.y );

			// Creates new BitmapData				
			var bmd : BitmapData = new BitmapData( rect.width, rect.height, true, 0xffffff );
			bmd.draw( bitmapData, m, null, null, null, true );
					
			return bmd;
		}
		/**
		 * <p>Clear will remove all reference to stored Decals as well as notify
		 * any children Decals to detach themselves from the Sheet.</p>
		 * 
		 */	
		public function clear() : Boolean
		{
			dispatchEvent( new Event( Event.DEACTIVATE, true, true ) );
			decalRectangles = new Dictionary( true );
			decalNames = new Array( );
			return true;
		}
	}
}