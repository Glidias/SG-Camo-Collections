package sg.camo.notifications 
{
	
	/**
	 * Enum list of commonly-shared display notifications for events.
	 * @author Glenn Ko
	 */
	public class GDisplayNotifications 
	{
		// -- ISelection/ISelectable
		/**
		 * When a selection attempt is made on a particular object (usually caused by a click).
		 * (Usually Bubbling)
		 */
		public static const SELECT:String = "GDisplay.SELECT";
		
		/**
		 * Event type to dispatch from displayObject when a target has been 
		 * successfully selected within a group. (Usually Non-Bubbling)
		 */
		public static const SELECTED:String = "selected";
		/**
		 * Event type to dispatch from displayObject when it has been 
		 * successfully un-selected within a group. (Usually Non-Bubbling)
		 */
		public static const UNSELECTED:String = "unselected";
		
		// -- IPageDisplay
		
		/**
		 * When a page change attempt is made. (Usually Bubbling).
		 */
		public static const PAGE_CHANGE:String = "GDisplay.PAGE_CHANGE";
		
		// -- IList
		
		/**
		 * When a list item is being added/removed. This usually runs under a CamoChildEvent containing a reference 
		 * to a displayobject (if available) of the list item being added/removed.
		 */
		public static const ADD_LIST_ITEM:String = "addListItem";
		public static const REMOVE_LIST_ITEM:String = "removeListItem";
		
		
		//  -- IDiv
		/**
		 * When a change of zIndex has occured on a IDiv display object element.
		 */
		public static const Z_INDEX_CHANGE:String = "zIndexChange";
	}
	
}