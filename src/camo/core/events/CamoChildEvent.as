package camo.core.events 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	* This event is used by DisplayObjectContainer-based classes that needs 
	* to notify of any adding/removing of it's children from it's own display-list.
	* <br/><br/>
	* By dispatching this event,  it notifies other layout engines (or behaviours) 
	* to perform layouting processes immediately on the assosiated child instance and surrounding child instances.
	* <br/><br/>
	* Examples of classes relying on this event:
	* @see sg.camo.behaviour.HLayoutBehaviour
	* @see sg.camo.behaviour.DivLayoutBehaviour
	* 
	* @author Glenn Ko
	*/
	public class CamoChildEvent extends Event
	{
		/**
		 * Notifies that a child has been added to the display list.
		 */
		public static const ADD_CHILD : String = "addChild";
		/**
		 * Notifies that a child is about to get removed from the display list.
		 */
		public static const REMOVE_CHILD : String = "removeChild";
		
		/**
		 * The child being added or removed.
		 */
		public var child:DisplayObject;
		
		/**
		 * Constructor.
		 * @param	type	
		 * @param	child	The child being added or removed.
		 * @param	bubbles	 Non bubbling by default, since this is specific to the target container's operations.
		 * @param	cancelable
		 */
		public function CamoChildEvent(type : String, child:DisplayObject, bubbles : Boolean = false, cancelable : Boolean = true) 
		{
			super(type, bubbles, cancelable);
			this.child = child;
		}
		
		override public function clone():Event {
			return new CamoChildEvent(type, child, bubbles, cancelable);
		}
		
	}
	
}