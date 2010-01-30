package sg.camo.interfaces 
{
	
	/**
	* Identifies classes with the ability to get pseudo state (or any set of property objects) by id.
	* @author Glenn Ko
	*/
	public interface IPropertyStatable 
	{
		function getPropertyState(id:String):Object;
	}
	
}