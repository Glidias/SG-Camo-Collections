package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for classes which can be used to retrieve pooled instances, or return the relavant
	 * render instance within specific contexts.
	 * 
	 * @author Glenn Ko
	 */
	public interface IRenderPool 
	{
		/** retrieves render from pool */
		function get object():IDisplayRender;
		
	}
	
}