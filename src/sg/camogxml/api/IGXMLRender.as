package sg.camogxml.api 
{
	import sg.camo.interfaces.IDisplayRender;
	
	/**
	 * Denotes a IDisplayRender instance that requires rendering of some gxml/XML markup
	 * @author Glenn Ko
	 */
	public interface IGXMLRender extends IDisplayRender
	{
		function renderGXML(xml:XML):void;
	}
	
}