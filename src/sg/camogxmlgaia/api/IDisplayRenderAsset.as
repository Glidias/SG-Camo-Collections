package sg.camogxmlgaia.api 
{
	import com.gaiaframework.api.IAsset;
	import sg.camo.interfaces.IDisplayRender;
	
	/**
	 * Interface for Gaia assets that contain a IDisplayRender instance,
	 * and is also used to identify assets that can be registered to index stack managers for renders.
	 * 
	 * @see sg.camo.interfaces.IDisplayRender
	 * 
	 * @author Glenn Ko
	 */
	public interface IDisplayRenderAsset extends IAsset
	{
		function get displayRender():IDisplayRender;
	}
	
}