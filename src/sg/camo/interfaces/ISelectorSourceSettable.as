package sg.camo.interfaces 
{
	
	/**
	* Marker interface which identifies classes that can be provided with a selector source reference.
	* @author Glenn Ko
	*/
	public interface ISelectorSourceSettable 
	{
		function set selectorSource(src:ISelectorSource):void;
	}
	
}