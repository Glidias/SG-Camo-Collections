package sg.camogxml.api 
{
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.ISelectorSource;
	
	/**
	 * GXML dependencies for Builder GUI application or any (pre)viewer
	 * @author Glenn Ko
	 */
	public interface IGXMLBuild 
	{
		function get definitions():IDefinitionGetter  
		function get behaviourSrc():IBehaviouralBase;
		function get renderMarkup():XMLNode;
		function get inlineStylesheet():ISelectorSource;
		function get baseSelectorSource():ISelectorSource;  
		function get renderSrc():IDisplayRenderSource;
	}
	
}