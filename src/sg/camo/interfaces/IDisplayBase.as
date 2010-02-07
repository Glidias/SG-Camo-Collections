package sg.camo.interfaces 
{
	
	/**
	 * The IDisplayBase interface provides special width and height getters to get the original width/height settings
	 * explicitly defined for the container's viewable content zone.
	 * <br/><br/>
	 * In various cases, this can come in useful as other classes extending from <code>AbstractDisplay</code> 
	 * (particularly <code>BoxModelDisplay</code>) have their width/height getters overwritten to include additional 
	 * surrounding padding and borders. This interface provides a quick means to get back the original width/height values 
	 * thereof.
	 * <br/><br/>
	 * The interface is also used to check the intended dimensions of a container's viewable content screen-mask when 
	 * using <code>ScrollableBehaviour</code> with automatically appearing/dissapearing inner scrollbars, so that the 
	 * scrolling content mask can be re-fitted down or restored back to original values when scrollbars are dynamically added 
	 * into or removed from such displays.<br/>
	 * The <code>CamoDisplay</code> is specifically optimised to support such
	 * "inner-scrollbar" functionality under <code>ScrollableBehaviour</code>, since <code>CamoDisplay</code>
	 * not only has a CSS BoxModel base to that supports surrounding padding/border settings typical to a windows-like display,
	 * it also includes overflow settings to determine masking of its inner display content.
	 * 
	 * @see sg.camo.behaviour.ScrollableBehaviour
	 * @see camo.core.display.AbstractDisplay
	 * @see camo.core.display.BoxModelDisplay
	 * @see camo.core.display.CamoDisplay
	 * 
	 * @author Glenn Ko
	 */
	public interface IDisplayBase 
	{
		function get __width():Number;
		function get __height():Number;
		
	}
	
}