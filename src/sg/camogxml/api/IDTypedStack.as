package sg.camogxml.api 
{
	/**
	 * A generic 'resource stack-by-id' implementation in untyped format, but provides checking 
	 * of stack type (ie. the item class the stack is dealing with), for validation.
	 * @author Glenn Ko
	 */
	public interface IDTypedStack
	{
		/**
		 * Reflects the type of class item being used for the stack, or null if no public type validation 
		 * is required.
		 */
		function get stackType():Class;
		
		/**
		 * Adds an item and assosiates it with an id.
		 * @param	item
		 * @param	id
		 */
		function addItemById(item:*, id:String):void;
		
		/**
		 * Removes all items assosiated with the stipulated id.
		 * @param	id
		 */
		function removeItemsById(id:String):void;
		
		/**
		 * Clones the IDTypedStack.
		 * @param	id	If left undefined, clones an exact copy of the entire stack, 
		 * 				otherwise, clones stack consisting of only items assosiated with the stipulated id.
		 * @return	
		 */
		function cloneStack(id:String = null):IDTypedStack;
	}

}