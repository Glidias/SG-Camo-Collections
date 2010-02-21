package sg.camo.interfaces 
{
	
	/**
	 * Base interface for classes that allow setting of model/app-related data through XML.
	 * @author Glenn Ko
	 */
	public interface IXMLModel 
	{
		function set modelXML(xml:XML):void;
	}
	
}