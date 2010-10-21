package camo.core.events
{
	import flash.events.Event;	

	/**
	 * This event has been deprecated from the Camo core under SG-Camo. 
	 * A plain Flash event of "draw" is dispatched from AbstractDisplay instead.
	 * However, this class is still kept since some classes still uses this event for enumeration 
	 * and dispatching. (However, draw handlers should only require a plain Event parameter, 
	 * since there's no special properties in this event.)
	 */
	
	//[Deprecated]
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