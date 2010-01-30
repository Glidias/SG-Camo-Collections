package sg.camo.interfaces 
{
	import flash.display.DisplayObject;
	/**
	 * Standard 1-D (1-dimensinal) list interface to add and remove items with/by string ids.
	 * @author Glenn Ko
	 */
	public interface IList 
	{
		/**
		 * Adds list item, providing a label and id.
		 * @param	label	The label
		 * @param	id		The ID to assosiate with the item
		 * @return	A DisplayObject reference of the list item being added, or null if adding was unsuccessfull.
		 */
		function addListItem (label:String, id:String):DisplayObject;
		
		/**
		 * Removes list item by id.
		 * @param	id	The id of item to remove.
		 * @return	A DisplayObject reference of the list item being removed, or null if removal was unsuccessful for whatever reason.
		 */
		function removeListItem (id:String):DisplayObject;
		
	}
	
}