package sg.camo.interfaces 
{
	import flash.system.ApplicationDomain;
	
	/**
	 * Parse-only base interface for INodeclassSpawnerManager 
	 * to only allow instantiating classes from xml nodes without the 
	 * possibility of configuring wirings.
	 * 
	 * @see sg.camogxml.utils.NodeClassSpawnerManager
	 * 
	 * @author Glenn Ko
	 */
	public interface INodeClassSpawner 
	{
		function injectInto(instance:*, node:XML = null, subject:*= null, additionalBinding:Function = null):void;
		function parseNode(node:XML, subject:*= null, domain:ApplicationDomain = null, additionalBinding:Function=null):*;
		function spawnClassWithNode(classDef:Class, node:XML=null, subject:*= null, additionalBinding:Function=null):*
	}
	
}