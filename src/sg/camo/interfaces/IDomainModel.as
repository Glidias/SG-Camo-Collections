package sg.camo.interfaces 
{
	import flash.system.ApplicationDomain;
	
	/**
	 * Marker interface for classes that support setting of application domain context with usually any accompanying xml-parsed
	 * class-related definitions.
	 * @author Glenn Ko
	 */
	public interface IDomainModel extends IXMLModel
	{
		function set appDomain(domain:ApplicationDomain):void;
	}
	
}