package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for classes that can generate fresh new IDisplayRender instances.
	 * 
	 * @see sg.camo.interfaces.IDisplayRender
	 * @see sg.camo.interfaces.IRenderPool
	 * 
	 * @author Glenn Ko
	 */
	public interface IRenderFactory 
	{
		function createRender():IDisplayRender;
	}
	
}