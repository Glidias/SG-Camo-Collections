/** 
 * <p>Original Author:  jessefreeman</p>
 * <p>Class File: IDisplay.as</p>
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
 * 	2.0  Initial version Jan 19, 2009</p>
 * 
 *  Changes made on Sept 05, 2009 - Glenn (commented)
 *
 */

package camo.core.display
{
	import flash.display.DisplayObject;	

	/**
	* An IDisplay instance normally refers to a DisplayObjectContainer (usually extending from Sprite/MovieClip),
	* that composes another nested display object (often another Sprite) that act as the "child display" from which elements are usually added to/from that nested child container itself.
	* <br/><br/>
	* By nesting an additional sprite within a sprite, that sprite can be positioned relative off the parent's container dimensions, allowing greater flexibility in aligning and positioning child display
	* elements relative off the parent IDisplay container's bounds. 
	* The IDisplay interface provides a generic method
	* <code>IDisplay.getDisplay():DisplayObject</code> to directly retreive this nested display instance reference to
	* allow other classes to perform operations like alignment, among other stuff.
	* <br/><br/>
	* IDisplay is usually a more advanced DisplayObjectContainer (Sprite/MovieClip) for Flash, and provides various 
	* stage invalidation methods like <code>refresh()</code>/<code>invalidate()</code> , among other stuff typical to a Flash UI component
	* framework to control when certain portions of it's appearance/layout should update itself during the stage's Event.RENDER event.
	* <br/><br/>
	* 
	  */
	public interface IDisplay
	{
		// --Required implementations
		
		// stage validation/invalidation and auto-refresh
		/**
		 * Normally refreshes the container and display immediately, updating with any  size/alignment changes.
		 */
		function refresh():void;
		/**
		 * Invalidates the display so it'll attempt a refresh and display update on the next
		 * Event.RENDER dispatched from the stage.
		 */
		function invalidate():void;	
		function invalidateSize():void;
		
		
		// nested display
		/**
		 * Usually retrieves child nested display.
		 * <br/><br/>
		 *  <i>Some implementators of IDisplay may return a TextField (or any other types of DisplayObject) 
		 *  as their "child display" under getDisplay() to allow other classes/behaviours to work on a different
		 *  target.</i>
		 * @return  (DisplayObject) A valid DisplayObject instance
		 */
		function getDisplay():DisplayObject; 


		// get/set id  (is this realy needed?)
		/*
		function get id() : String;
		function set id(value : String) : void;
		*/
		
		// positioning/resize controls (is this boiler plate?)
		/*
		function move(newX : Number,newY : Number) : void;
		function resize(w : Number, h : Number) : void;
		*/
		
		/** Clears all registered listeners. 
		 * <br/><br/>
		 * <i>NOTE: May consider possibly phasing this out of this method if it forces all other classes
		 * to implement this method in an overly prescriptive way.</i> */
		//function clearEventListeners() : void;  
		
		
		// No longer needed, use specific IDestroyable interface signature if destruction is required
		//function destroy(recurse:Boolean=false) : void;   
		
		
		
		// ---- Borrowed methods
		
		// Already found in display object   // -- TO DO, all proxy methods for display object?
		/** @private */function get x() : Number;
		/** @private */function set x(value : Number) : void;

		/** @private */function get y() : Number;
		/** @private */function set y(value : Number) : void;
		
		/** @private */function set width(value : Number):void; // added 
		/** @private */function get width():Number; // added
		
		/** @private */function set height(value :Number):void; // added
		/** @private */function get height():Number; // added 

		/** @private */function get alpha() : Number;
		/** @private */function set alpha(value : Number) : void;

		/** @private */function get scaleX() : Number;
		/** @private */function set scaleX(value : Number) : void;

		// This is removed. Unnecessary overhead and not really implemented. 
		//function get bitmapData() : BitmapData;
		
		// Already found in IEventDispatcher
		/** @private */function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		/** @private */function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
		
		
		// Already found in displayObjectContainer   
		// -- TO DO, all proxy methods for display object containers ?
		/** @private */function addChild(child : DisplayObject) : DisplayObject;
		/** @private */function addChildAt(child : DisplayObject, index : int) : DisplayObject;

		/** @private */function getChildAt(index : int) : DisplayObject;
		/** @private */function getChildByName(name : String) : DisplayObject;

		/** @private */function getChildIndex(child : DisplayObject) : int;
		
		/** @private */function removeChild(child : DisplayObject) : DisplayObject;
		/** @private */function removeChildAt(index : int) : DisplayObject;

		/** @private */function setChildIndex(child : DisplayObject, index : int) : void;
		
		/** @private */function swapChildren(child1 : DisplayObject, child2 : DisplayObject) : void;
		/** @private */function swapChildrenAt(index1 : int, index2 : int) : void;
	}
}