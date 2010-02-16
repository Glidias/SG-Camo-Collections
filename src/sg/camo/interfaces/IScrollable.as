package sg.camo.interfaces 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * Extended IScroll interface for actual display-based scroll containers or scrollable content (to usually work with scrollbars).
	 * @author Glenn Ko
	 */
	public interface IScrollable extends IScroll
	{	
		/**  A sprite container that can be used to provide scroll-wheeling support or receive focus or dispatch Event.SCROLL events.  */
		function get scrollContainer ():Sprite;  		
		
		/** A displayObject or rectangle of the screen mask containing the content  */
		function get scrollMask ():*; 

		/** The actual content to scroll  */
		function get scrollContent ():DisplayObject
		
		/** Resets scroll back to default values, and normally cancels any current movement */
		function resetScroll():void;
		
		/** Gets on-screen item length (which is useful for snap-scrolling to unit lengths) */
		function get itemLength ():Number;	
		
		/** Re-sets on-screen item length to something else */
		function set itemLength(val:Number):void;
		
		// ***********************
		/**
		 * Borrowed listener method required to listen for content update changes
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 * @param	priority
		 * @param	useWeakReference
		 * 
		 */
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		/**
		 * Borrowed listener method required to listen for content update changes
		 * @param	type
		 * @param	listener
		 * @param	useCapture
		 */
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
	
}