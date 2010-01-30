package sg.camogxml.dummy 
{
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.IDefinitionGetter;
	/**
	 * An IDefinitionGetter interface to retrieve class definitions through
	 * an ApplicationDomain.
	 * @author Glenn Ko
	 */
	public class ApplicationDomainGetter implements IDefinitionGetter
	{
		
		private var appDomain:ApplicationDomain;
		
		/**
		 * Constructor
		 * @param	appDomain	Supplies an application domain or uses current domain if undefined.
		 */
		public function ApplicationDomainGetter(appDomain:ApplicationDomain = null) 
		{
			this.appDomain = appDomain || ApplicationDomain.currentDomain;
		}
		
		public function getDefinition(str:String):Object {
			return appDomain.getDefinition(str);
		}

		public function hasDefinition(str:String):Boolean {
			return appDomain.hasDefinition(str);
		}
		

		public function get definitions():Array {
			return []; // not implemented. No definition list pubilcily available
		}
		
	}

}