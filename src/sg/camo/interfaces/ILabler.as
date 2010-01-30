package sg.camo.interfaces 
{
	
	/**
	 * Standard interface to set up multiple labels (or any sort of parameters) in array format,
	 * @author Glenn Ko
	 */
	public interface ILabler 
	{
		/**
		 * 
		 * @param	...args
		 * @return	Returns another array of textfields whose texts were successfully set, or null if non-applicable
		 */
		function setLabels( ...args ):Array;
	}
	
}