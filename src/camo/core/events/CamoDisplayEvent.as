package camo.core.events
{
	import flash.events.Event;	

	/**
	 * This event is normally used by container-based classes to notify of any content/size
	 * updates. 
	 * <br/>This normally results in redrawing of the container's appearance, 
	 * or updating of attached scrollbars and the like...
	 */
	public class CamoDisplayEvent extends Event
	{
		public static const DRAW : String = "draw";

		public function CamoDisplayEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = true)
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone():Event {
			return new CamoDisplayEvent(type, bubbles, cancelable);
		}
	}
}