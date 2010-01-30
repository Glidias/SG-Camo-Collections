package sg.camogxmlgaia.inject 
{
	import flash.system.ApplicationDomain;
	import sg.camogxmlgaia.api.INodeClassSpawnerManager;
	/**
	 * Static utility class to retrieve a specific implementation instance of a INodeClassSpawnerManager.
	 * @author Glenn Ko
	 */
	public class NodeClassSpawn
	{
		public static const CLASSNAME_MANAGER:String = "sg.camogxmlgaia.inject.NodeClassSpawnerManager";
		
		/**
		 * Dynamically instantiates a class to retrieve a valid INodeClassSpawnerManager implementation.
		 * @param	className	The definition name to use. Defaults to CLASSNAME_MANAGER constant;
		 * @param	domain	If left unsupplied, defaults to current application domain. If supplied,
		 * will attempt to instantiate from  the stipulated domain first before considering current domain.
		 * @return	A valid INodeClassManager instance, or null if completely unsuccessful.
		 */
		public static function getImpl(className:String=CLASSNAME_MANAGER, domain:ApplicationDomain = null):INodeClassSpawnerManager {
			var classe:Class =  domain!=null && domain!==ApplicationDomain.currentDomain ? domain.hasDefinition(className) ? domain.getDefinition(className) as Class : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : null   : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : null;
			return classe ? new classe() as INodeClassSpawnerManager : null;
		}
	}

}