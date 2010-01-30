package camo.core.decal
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;	import flash.events.Event;	
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
	 * <p>A Decal is class that extends Bitmap and contains a reference to the 
	 * DecalSheet it was cut out from. This connection allows the Decal to 
	 * receive updates from its parent DecalSheet.</p>
	 * 
	 * <p>Decals listen for CHANGE events from their parent DecalSheet and once 
	 * an event is received, the Decal resamples BitmapData from the DecalSheet 
	 * and updates it's own BitmapData.</p>
	 *  
	 * @author Jesse Freeman http://www.jessefreeman.com
	 * 
	 */	
	public class Decal extends Bitmap
	{
		protected var sheetSrc : IDecalSheet;
		
		override public function set bitmapData(value:BitmapData):void
		{
			var previousSmoothing:Boolean = smoothing;
			var previousPixelSnapping:String = pixelSnapping;
			
			super.bitmapData = value;
			
			smoothing = previousSmoothing;
			pixelSnapping = previousPixelSnapping;		}
		
		/**
		 * <p>This is the Decal Sheet Constructor.</p>
		 * 
		 * @param name Name of the Decal. This is used to update the Decal when
		 * the DecalSheet fires off a change event.
		 * 
		 * @param src This is the DecalSheet instance that this Decal is being
		 * cut out from. An EventListener is added to this src to notify the
		 * Decal when DecalSheet has been updated.
		 * 
		 * @param pixelSnapping
		 * @param smoothing
		 * 
		 */
		public function Decal(name : String, src : IDecalSheet, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{

			super( null, pixelSnapping, smoothing );

			// Save decal sheet source.
			sheetSrc = src;

			// Save name of decal so we can sample it from the DecalSheet.
			this.name = name;

			// Get bitmap data from the DecalSheet src.
			refresh( );
			
			addListeners( sheetSrc );
		}
		/**
		 * <p>Gets new bitmap data from the DecalSheet src based on its name.</p>
		 * 
		 */
		public function refresh() : void
		{
			bitmapData = sheetSrc.sample( name, smoothing );
		}
		/**
		 * 
		 * <p>This removes the reference to the DecalSheet this Decal was cut
		 * out from. After calling this method, the listeners are removed from
		 * the DecalSheet src and the reference of the src is nulled out.</p>
		 * 
		 * <p>Once a Decal is detached, it will no longer update or listen for
		 * change events from the DecalSheet src. It's important to note that
		 * this can not be undone.</p>
		 * 
		 */	
		public function detach() : void
		{
			removeListeners( sheetSrc );
			sheetSrc = null;
		}
		/**
		 * @private
		 * @param target
		 * 
		 */		
		protected function addListeners(target : IDecalSheet) : void
		{
			target.addEventListener( Event.CHANGE, onChange, false, 0, true );
			target.addEventListener( Event.DEACTIVATE, onDeactivate );
		}
		/**
		 * @private
		 * @param target
		 * 
		 */			
		protected function removeListeners(target : IDecalSheet) : void
		{
			target.removeEventListener( Event.CHANGE, onChange );
			target.removeEventListener( Event.DEACTIVATE, onDeactivate );
		}
		/**
		 * @private
		 * @param event
		 * 
		 */				
		protected function onChange(event : Event) : void
		{
			event.stopPropagation( );
			refresh( );
		}
		/**
		 * 
		 * @param event
		 * 
		 */		
		protected function onDeactivate(event : Event) : void
		{
			event.stopPropagation( );
			detach( );
		}
	}
}