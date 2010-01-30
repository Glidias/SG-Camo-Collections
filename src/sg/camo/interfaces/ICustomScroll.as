package sg.camo.interfaces 
{
	import flash.events.IEventDispatcher;
	
	/**
	 * Interface that defines custom scroll states and availability
	 * @author Glenn Ko
	 */
	public interface ICustomScroll extends IScroll
	{
		/**  Indicates whether horizontal scrolling is allowed  */
		function get hScrollable():Boolean;
		/** Indicates whether vertical scrolling is allowed */
		function get vScrollable():Boolean;
		
		
		/** Reference to any IEventDispatcher that could  dispatch Overflow or CamoDisplayEvent.DRAW events
		 * to trigger content updates .
		 * @see sg.camo.events.OverflowEvent
		 * @see camo.core.events.CamoDisplayEvent
		 * */
		function get contentUpdateDispatcher():IEventDispatcher; 
		
		/**
		 * reset scroll back to default values
		 */
		function resetScroll():void; 
	}
	
}