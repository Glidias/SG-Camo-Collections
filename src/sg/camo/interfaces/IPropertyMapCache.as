package sg.camo.interfaces 
{
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IPropertyMapCache 
	{
		function getPropertyMapCache(className:String):Object;
		function getPropertyMap(target : * ) : Object;
	}
	
}