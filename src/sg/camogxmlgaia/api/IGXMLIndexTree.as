package sg.camogxmlgaia.api 
{
	import com.gaiaframework.api.IPageAsset;
	import sg.camo.interfaces.ITransitionManager;
	
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.ISelectorSource;
	
	/**
	 * This interface is implemented by the root index page of any CamoGXMLGaia website,
	 * and acts as a central control center and engine from which all other pages (including sub-index pages)
	 * can be auto-wired up. 
	 * <br/><br/>
	 * For information on how to configure your CGG website using Gaia's site.xml and CGG's
	 * cgg_config.xml, check the wiki.
	 * 
	 * @author Glenn Ko
	 */
	public interface IGXMLIndexTree extends IGXMLIndexPage
	{
		// Basic steps/services to hook up a page
		function getNewTransitionManager(page:IPageAsset):ITransitionManager;
		function prepareSources(page:IPageAsset, ...args):void;
		function renderDisplays(page:IPageAsset, ...args):void;
		function renderPageLayers(page:IPageAsset, ...args):void;
		function renderPageContent(page:IPageAsset, ...args):void;
		
		// Cleans up page
		function removeSources(page:IPageAsset, ...args):void;
		
		// Modified Gaia.api.resolveBinding service for application to retrieve untyped data
		function resolveBinding(str:String):*;
		
		// -- Sub index page support 
		function addIndexPage(page:IGXMLIndexPage):void;
		function removeIndexPage(page:IGXMLIndexPage):void;
		
		// Goto from another sub index page
		function gotoFrom(path:String, fromPage:IPageAsset = null):void;
		
		
	}
	
}