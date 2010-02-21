package sg.camogxmlgaia.api 
{	
	/**
	 * Marker interface for assets that need to render their xml content as GXML once
	 * dependencies are fulfilled.
	 * 
	 * @author Glenn Ko
	 */
	public interface IGXMLAsset extends IDisplayRenderAsset
	{
		function renderGXML():void;
	}
	
}