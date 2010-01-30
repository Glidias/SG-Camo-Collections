package sg.camogxml.api 
{
	
	/**
	 * Marker interface to identify classes that can render SEO content
	 * @author Glenn Ko
	 */
	public interface ISEORenderer 
	{
		function renderSeo(xml:XML):void;
	}
	
}