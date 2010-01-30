package sg.camo.interfaces 
{
	
	/**
	 * Base interface for scroll targets (supports both directions). 
	 * <br/><br/>
	 * This interface can also be used on classes that respond to directional controls like joysticks. 
	 * (not just scrollbars/scrollers!).
	 * 
	 * @author Glenn Ko
	 */
	public interface IScroll 
	{ 				
		/**
		 * Sets horizontal scroll value by ratio
		 */
		function set scrollH (ratio:Number):void;
		/**
		 * Sets vertical scroll value by ratio
		 */
		function set scrollV (ratio:Number):void; 
	}
	
}