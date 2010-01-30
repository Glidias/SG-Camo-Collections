package sg.camo.interfaces 
{
	
	/**
	 * Marker interface to identify list items, with the ability to set/get ids.
	 * @author Glenn Ko
	 */
	public interface IListItem 
	{
		function set id(str:String):void;
		function get id():String;
	}
	
}