package sg.camo.interfaces 
{
	
	/**
	* Identifies classes with the ability to apply object properties manually on themselves, without resorting
	* to external application.
	* @author Glenn Ko
	*/
	public interface IPropertyApplyable 
	{
		function applyProperties(style: Object):void;
		
	}
	
}