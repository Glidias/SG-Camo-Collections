package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for classes that can retrieve definitions
	 * @author Glenn Ko
	 */
	public interface IDefinitionGetter 
	{
		/**
		 * Gets definition by name
		 * @param	str		The name of the definition
		 * @return	A Class, function, IFUnctionDef, etc. 
		 */
		function getDefinition(str:String):Object;
		
		/**
		 * Checks whether class has a certain definition by name
		 * @param	str	 The name of the definition
		 * @return
		 */
		function hasDefinition(str:String):Boolean;
		
		/**
		 * Returns a string of definition names available for use
		 */
		function get definitions():Array;
	}
	
}