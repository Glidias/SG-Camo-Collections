package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for destroyable items to facilitate garbage collection.
	 * @author Glenn Ko
	 */
	public interface IDestroyable 
	{
		function destroy():void;
	}
	
}