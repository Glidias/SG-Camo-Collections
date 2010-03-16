package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for display objects that support immediate refreshing of skins/graphics, etc..
	 * @author Glenn Ko
	 */
	public interface IRefreshable 
	{
		// --Required implementations
		
		// stage validation/invalidation and auto-refresh
		/**
		 * Normally refreshes the container and display immediately, updating with any  size/alignment changes.
		 */
		function refresh():void;

	}
	
}