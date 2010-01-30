package sg.camo.interfaces 
{
	
	/**
	 * Helper extended IList Interface to immediately retrieve selected id (if any) of current list item.
	 * @author Glenn Ko
	 */
	public interface ISelectionList extends IList
	{
		function get selectedId():String;
	}
	
}