package sg.camo.interfaces 
{
	import camo.core.property.IPropertySelector;
	
	/**
	* Selector source interface to retrieve property selectors in a read-only manner. 
	* @author Glenn Ko
	*/
	public interface ISelectorSource 
	{
		
		/**
		 * Retrieves a dynamic selector object based on an array of stipulated selector names
		 * @param	... selectorNames
		 * @return	An object (usually a dynamic PropertySelector) consisting of string-based property values or is 
		 * an empty selector with a selectorName of "EmptyProperties".
		 */
		function getSelector( ... selectorNames) : Object;
		
		/**
		 * Looks up a specific selector by name, or null if not found.
		 * @param	selectorName	The stipulated selector name
		 * @return	Returns a IPropertySelector instance or null if not found
		 */
		function findSelector(selectorName:String):IPropertySelector;
		
		/**
		 * Returns an array of valid selector names found in the selector source for use. 
		 * This also allows individual selectors to be easily retrieved via the findSelector() method.
		 */
		function get selectorNames() : Array;


		

	}
	
}