package sg.camogxmlgaia.api 
{
	import sg.camogxml.api.IDTypedStack;
	import sg.camo.interfaces.INodeClassSpawner;
	
	/**
	 * This interface is implemented by all 'index/sub-index' pages under any CamoGXMLGaia site.
	 * In reality, there can only be 1 main index page in Gaia Flash Framework, but the 'index'
	 * page in a GXML context refers to a page where you can overwrite new implementations of
	 * stylesheets, behaviours, injectors and class definitions under a completely different 
	 * application domain, effectively allowing you to have entirely different-looking/behaving
	 * sub-sites. IT also provides a base to dynamically instnatiate instances
	 * 
	 * @author Glenn Ko
	 */
	public interface IGXMLIndexPage 
	{
		
		function get nodeClassSpawner():INodeClassSpawner; 
		function getStack(id:String):IDTypedStack;
		function getNewStack(id:String):IDTypedStack;
	}
	
}