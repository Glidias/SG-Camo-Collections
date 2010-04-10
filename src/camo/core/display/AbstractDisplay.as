/** 
 * <p>Original Author:  jessefreeman</p>
 * <p>Class File: AbstarctDisplay.as</p>
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
 * 	2.0  Initial version Jan 7, 2009</p>
 * 
 *  *  Changes made on Sept 05, 2009 - Glenn (commented)
 *
 */

package camo.core.display 
{
	import flash.geom.Point;
	import sg.camo.interfaces.IDisplayBase;

	import camo.core.events.CamoDisplayEvent;
	import camo.core.events.CamoChildEvent;
	
	//import flash.display.BitmapData;   // BitmapData unnecessary for AbstractDisplay
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.utils.Dictionary;	
	
	import flash.display.Stage;
	
	// Include camo interfaces
	import sg.camo.interfaces.IRecursableDestroyable;  
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IAncestorSprite;
	
	import sg.camo.SGCamoSettings;
	
	/**
	 * The base class for the Flash Camouflage display core. 
	 * <br/><br/>
	 * For more information on the whole Flash Camouflage display core and AbstractDisplay in general, refer
	 * to: 
	 * <br/><br/>
	 * For more information on the nature of the class' methods, refer to the following interfaces:
	 * @see camo.core.display.IDisplay
	 * @see sg.camo.interfaces.IAncestorSprite
	 * 
	 * @author jessefreeman
	 * 
	 * @author glenn  (changes commented with text)
	 * 
	 * 
	 * 
	 */
	public class AbstractDisplay extends Sprite implements IDisplay, IDisplayBase, IRecursableDestroyable, IAncestorSprite
	{
		/**
		 * The child <code>display</code> Sprite reference.
		 * @see camo.core.display.IDisplay
		 */
		protected var display : Sprite;
		
		/** @private */
		protected var _id : String;
		/** @private */
		protected var _invalid : Boolean;
		/** @private */
		protected var _width : Number = 0;
		/** @private */
		protected var _height : Number = 0;
		
		 // indicator to denote size/add/remove child changes which normally requires the draw event to bubble up the display list,
		/** @private */
		 protected var _bubblingDraw:Boolean = false;
		
		//protected var invalidated : Dictionary = new Dictionary( );  // <- not being used in this version
		

		/** @private Flag to determine */
		protected var _destroyChildren:Boolean = SGCamoSettings.DESTROY_CHILDREN;
		
		public function	get id() : String
		{
			return _id;
		}

	
		public function set id( value : String ) : void
		{
			_id = value;
		}


		public override function get width() : Number
		{
			return _width;
		}
		
		public function get __width():Number {
			return _width;
		}

	
		public override function set width( value : Number ) : void
		{
			if ( _width == value ) return;
			_bubblingDraw = true;
			_width = ! isNaN( value ) ? value : 0;
			invalidate( );
		}

		public override function get height() : Number
		{
			return _height;
		}
		
		public function get __height():Number {
			return _height;
		}
		
		public function set __width(val:Number):void {
			_width = val;
			_bubblingDraw = true;
			invalidate();
		}
	
		
		public function set __height(val:Number):void {
			_height = val;
			_bubblingDraw = true;
			invalidate();
		}

		public function get displayWidth():Number {
			return _width;
		}
		public function get displayHeight():Number {
			return _height;
		}
		
		public function get $width():Number {
			return super.width;
		}
		public function get $height():Number {
			return super.height;
		}
		public function set $width(val:Number):void {
			super.width = val;
		}
		public function set $height(val:Number):void {
			super.height = val;
		}


		public override function set height( value : Number ) : void
		{
			if ( _height == value ) return;
			_bubblingDraw = true;
			_height = ! isNaN( value ) ? value : 0;
			invalidate( );
		}
		
		// Not being used ...
		/*
		public function set center(point:Point):void
		{
			//TODO add center based on point.
		}*/
		
	
		override public function get numChildren() : int
		{
			return display.numChildren;
		}
		
		/**
		 * @see sg.camo.interfaces.IAncestorSprite
		 */
		public function get $numChildren():int {
			return super.numChildren;
		}
		
		
		// -- Removed, not being used.
		
		/*
		 *   Jesse:
		 * <p>This allows immediate access to the bitmapData of the display. By
		 *	accessing this getter you can take a screen shot of the instance.</p>
		 *	
		 *	<p>TODO this needs to be fleshed out</p>
		 */
		/*public function get bitmapData() : BitmapData
		{
			// Create BitmapData
			var bitmapData : BitmapData = new BitmapData( width, height, true );
			bitmapData.draw( this );
			
			return bitmapData;
		}
		*/
		
		
		/**
		 * Constructor. Attempts creation of <code>display</code> sprite reference if <code>display</code> value is found to be empty.
		 * @param	self	(Required) A concrete reference to self (ie. <code>"this"</code>). (Else will throw an error)
		 */
		public function AbstractDisplay(self : AbstractDisplay=null)
		{
			super(); // Construct children in super
			
			if(self != this)
			{
				throw new IllegalOperationError( "AbstarctDisplay cannot be instantiated directly." );
			}
			else
			{
				//  Adds new display to the display-list only if needed, 
				display = display != null ? display : $addChild( new Sprite() ) as Sprite;
				//display.name = "display";  // not required, on-stage instances cannot be renamed.
				addStageListeners( );
			}
		}
		

		public function getDisplay():DisplayObject {
			return display;
		}
		
		// Exclusive add/remove stage listener functions not tied to handlers
		protected function addStageListeners() : void
		{
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true );
		}


		protected function removeStageListeners() : void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}


		public function move(newX : Number,newY : Number) : void
		{
			x = newX;
			y = newY;
		}


		public function resize(w : Number,h : Number) : void
		{
			width = w;
			height = h;
		}

		public function invalidate() : void
		{
			if( ! _invalid )
			{
				try
				{
					stage.invalidate( );
					_invalid = true;
					initializeAutoUpdate();

				}
				catch( error : Error )
				{
					_invalid = false;
				}
			}
		}


		// Stage listeners 
		/**
		 * @private
		 * @param	event
		 */
		protected function onAddedToStage( event : Event ) : void
		{
			stage.addEventListener( Event.RENDER, onRender, false, 0, true );
			draw( );
		}
		
		/**
		 * @private
		 * @param	e
		 */		
		protected function onRemovedFromStage(e:Event):void {
			stage.removeEventListener( Event.RENDER, onRender);
			
			// bug workaround: additional measure required to not break stage
			stage.addEventListener(Event.RENDER, killRender, false, 0, true);  
		}
		
		
		private function killRender(e:Event):void {
			e.currentTarget.removeEventListener(Event.RENDER, killRender);
		}
		
		
		// WORKAROUND : need to retain listeners in case onRemovedFromStage occurs for another abstract display which 
		// somehow prevents Event.RENDER from dispatching during stage.invalidate(), ever.
		/**
		 * @private
		 */
		protected function initializeAutoUpdate():void {
			stage.removeEventListener(Event.RENDER, onRender, false);
			stage.addEventListener(Event.RENDER, onRender, false, 0, true);
		}

		
		
		/**
		 * @private
		 * @param	event
		 */
		protected function onRender( event : Event = null) : void
		{   
			if( _invalid )
			{
				draw( );
				_invalid = false;
				_bubblingDraw = false;
			}
		}
		
		public function invalidateSize():void {
			_bubblingDraw = true;
			invalidate();
		}
		

	
		public function refresh() : void
		{
			draw( );
			_invalid = false;
		}

		// -- Destructor 
		public function destroy() : void
		{
			destroyRecurse(_destroyChildren);
		}
		
		public function destroyRecurse(recurse:Boolean = true):void { 
			removeStageListeners();
			if (stage!=null) stage.removeEventListener( Event.RENDER, onRender);
			if (recurse) destroyChildren();
		}
		
		/**
		 * @private
		 */
		protected function destroyChildren():void {
			var child : DisplayObject;
			// changed for loop to while loop for performance, also removes all children from display list
			var i:int = numChildren;
			while (--i > -1) {
				child = getChildAt(0);
				if (child is IRecursableDestroyable) (child as IRecursableDestroyable).destroyRecurse(true)
				else if (child is IDestroyable) (child as IDestroyable).destroy();
				removeChild(child);
			}	
		}
	
		
		
		

		/**
		 * @private
		 */
		protected function draw() : void
		{
			dispatchEvent( new CamoDisplayEvent( CamoDisplayEvent.DRAW, _bubblingDraw ) );
		}





	
		override public function addChild(child : DisplayObject) : DisplayObject
		{
			var retChild:DisplayObject = display.addChild( child );
			
			 dispatchEvent( new CamoChildEvent( CamoChildEvent.ADD_CHILD, child ) );
			_bubblingDraw = true;
			invalidate( );
			return retChild;
		}

	
		public function $addChild(child : DisplayObject) : DisplayObject
		{
			invalidate( );
			return super.addChild( child );
		}


		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject
		{
			var retChild:DisplayObject = display.addChildAt( child, index );
			dispatchEvent( new CamoChildEvent( CamoChildEvent.ADD_CHILD, child ) );
			_bubblingDraw = true;
			invalidate();
			return retChild;
		}

	
		public function $addChildAt(child : DisplayObject, index : int) : DisplayObject
		{
			invalidate( );
			return super.addChildAt( child, index );
		}

		override public function getChildAt(index : int) : DisplayObject
		{
			return display.getChildAt( index );
		}

	
		public function $getChildAt(index : int) : DisplayObject
		{
			return super.getChildAt( index );
		}


		override public function getChildByName(name : String) : DisplayObject
		{
			return display.getChildByName( name );
		}

	
		public function $getChildByName(name : String) : DisplayObject
		{
			return super.getChildByName( name );
		}

	
		override public function getChildIndex(child : DisplayObject) : int
		{
			return display.getChildIndex( child );
		}

	
		public function $getChildIndex(child : DisplayObject) : int
		{
			return super.getChildIndex( child );
		}

	
		override public function removeChild(child : DisplayObject) : DisplayObject
		{
			dispatchEvent( new CamoChildEvent( CamoChildEvent.REMOVE_CHILD, child) );
			_bubblingDraw = true;
			invalidate( );
			return display.removeChild( child );
		}

	
		public function $removeChild(child : DisplayObject) : DisplayObject
		{
			invalidate( );
			return super.removeChild( child );
		}

	
		override public function removeChildAt(index : int) : DisplayObject
		{
			var retChild:DisplayObject = display.removeChildAt( index )
			dispatchEvent( new CamoChildEvent( CamoChildEvent.REMOVE_CHILD, retChild) );
			_bubblingDraw = true;
			invalidate();
			return retChild;
		}


		public function $removeChildAt(index : int) : DisplayObject
		{
			invalidate( );
			return super.removeChildAt( index );
		}

	
		override public function setChildIndex(child : DisplayObject, index : int) : void
		{
			invalidate( );
			display.setChildIndex( child, index );
		}

	
		protected function $setChildIndex(child : DisplayObject, index : int) : void
		{
			invalidate( );
			super.setChildIndex( child, index );
		}

	
		override public function swapChildren(child1 : DisplayObject, child2 : DisplayObject) : void
		{
			invalidate( );
			display.swapChildren( child1, child2 );
		}

	
		protected function $swapChildren(child1 : DisplayObject, child2 : DisplayObject) : void
		{
			invalidate( );
			super.swapChildren( child1, child2 );
		}

	
		override public function swapChildrenAt(index1 : int, index2 : int) : void
		{
			invalidate( );
			display.swapChildrenAt( index1, index2 );
		}


		protected function $swapChildrenAt(index1 : int, index2 : int) : void
		{
			invalidate( );
			super.swapChildrenAt( index1, index2 );
		}
	
		override public function contains(child : DisplayObject) : Boolean
		{
			return display.contains( child );
		}

		public function $contains(child : DisplayObject) : Boolean
		{
			return super.contains( child );
		}	
	}
}
