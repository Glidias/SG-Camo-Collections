package sg.camo.events 
{
	import flash.events.Event;
	
	/**
	* Event to usually notify scrollbars to update, or any other listener interested in content overflow changes.
	* 
	* @author Glenn Ko
	*/
	public class OverflowEvent extends Event
	{
		
		/** @private */
		public static const NAME:String = "GCamo.OverflowEvent";
		
	
		/** Set this to one of the Overflow constants */
		public var value:int;
	
		/** Overflow constant. (Neutral or negative values imply scrolling disabled) 
		 * <p> Describes a situation where content is masked in a container, but does not require scrolling </p>
		 * */
		public static const HIDDEN:int = -1;
		
		/** Overflow constant. (Neutral or negative values imply scrolling disabled) 
		 *  <p> Describes a situation where content is masked, but does not require scrolling </p>
		 * */
		public static const NONE:int = 0;
		
		/** Overflow constant.  (Positive value implies scroll enabling) 
		 *  <p> Describes a situation where content isn't masked, and may require scrolling.
		 *  (ie. Scrollbar only appears if required) </p>
		 * */
		public static const AUTO:int = 1;
		
		/** Overflow constant.  (Positive value implies scroll enabling) 
		 *  <p> Describes a situation where content is masked and require scrolling regardless 
		 * (ie. Even if the content doesn't  overflow, it still shows the scrollbar visually, only it's disabled. </p>
		 * */
		public static const SCROLL:int = 2;
		
		/**
		 * Constructor
		 * @param	$value		(int) Set this to one of the Overflow constants
		 * @param	$bubbles	
		 */
		public function OverflowEvent($value:int, $bubbles:Boolean=false) 
		{
			super(NAME, $bubbles);
			value = $value;
		}
		
		override public function clone():Event 
		{ 
			return new OverflowEvent(value, bubbles);
		} 
		
		override public function toString():String 
		{ 
			return formatToString("OverflowEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}