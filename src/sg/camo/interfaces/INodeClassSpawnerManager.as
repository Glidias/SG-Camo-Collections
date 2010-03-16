package sg.camo.interfaces 
{
	
	/**
	 * Parse and write interface for NodeClassSpawnerManager.
	 * 
	 * @see sg.camogxml.utils.NodeClassSpawnerManager
	 * 
	 * @author Glenn Ko
	 */
	public interface INodeClassSpawnerManager extends INodeClassSpawner
	{
		// configure by XML 
		function mapXMLSubjects(xml:XML):void;
		
		// manually wire up a subject by code to a certain attribute/value pair for subject mapping
		function mapSubjectAttributeToValue(subject:*, attribute:String, typeParam:String, type:String = null, value:*= null, compulsory:Boolean=false, methodParams:Array=null):void;
		
		// clear a subject mapping compleely
		function clearSubject(subject:*):void;
		
		// sets binding function to convert strings
		function set bindingMethod(func:Function):void;
	}
	
}