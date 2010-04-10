package sg.camo.interfaces 
{
	
	/**
	 * The IDisplayBase interface provides special width and height getters to get the original width/height settings
	 * explicitly defined for the container's viewable content zone.
	 * <br/><br/>
	 * In various cases, this can come in useful as other classes extending from <code>AbstractDisplay</code> 
	 * (particularly <code>BoxModelDisplay</code>) have their width/height getters overwritten to include additional 
	 * surrounding padding and borders. This interface provides a quick means to get back the original width/height values 
	 * thereof based on the viewable context region found on the container, without considering padding/borders.
	 * 
	 * @see camo.core.display.AbstractDisplay
	 * @see camo.core.display.BoxModelDisplay
	 * @see camo.core.display.CamoDisplay
	 * 
	 * @author Glenn Ko
	 */
	public interface IDisplayBase 
	{
		/**
		 * 1st level class getters/setters
		 */
		function set __width(val:Number):void;
		function set __height(val:Number):void;
		function get __width():Number;
		function get __height():Number;
		
		/**
		 * Overwritablr widht/height getters for layouts/drawing
		 */
		function get displayWidth():Number;
		function get displayHeight():Number;
		
		
		
	}
	
}