package sg.camo.interfaces 
{
	
	/**
	 * Interface for any classes that can retrieve IDisplayRender instances. 
	 *
	 * @see sg.camo.interfaces.IDisplayRender
	 * 
	 * @author Glenn Ko
	 */
	public interface IDisplayRenderSource 
	{
		/**
		 * Retrieves a render remotely by ID
		 * @param	id
		 * @return
		 */
		function getRenderById(id:String):IDisplayRender;
		
		/**
		 * The payload of display renders that could be registered externally
		 * @return
		 */
		function getDisplayRenders():Array;
		
	}
	
}