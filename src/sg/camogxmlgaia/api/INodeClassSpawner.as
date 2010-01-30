package sg.camogxmlgaia.api 
{
	import flash.system.ApplicationDomain;
	
	/**
	 * Parse-only base interface for INodeclassSpawnerManager 
	 * to only allow instantiating classes from xml nodes without the 
	 * possibility of configuring wirings.
	 * 
	 * @see sg.camogxmlgaia.inject.NodeClassSpawnerManager
	 * 
	 * @author Glenn Ko
	 */
	public interface INodeClassSpawner 
	{
		function parseNode(node:XML, subject:*= null, domain:ApplicationDomain = null, additionalBinding:Function=null):*;
		function spawnClassWithNode(classDef:Class, node:XML, subject:*= null, additionalBinding:Function=null):*
	}
	
}