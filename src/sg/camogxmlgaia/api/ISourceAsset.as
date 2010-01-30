package sg.camogxmlgaia.api 
{
	import com.gaiaframework.api.IAsset;
	
	/**
	 * Base interface to identify assets that can register itself to source stacks/managers
	 * from each index page during the prepareSources() phase.
	 * 
	 * @author Glenn Ko
	 */
	public interface ISourceAsset
	{
		/**
		 * Conventionally returns "behaviour", "definition", "render", "stylesheet", etc. to identify
		 * the type of ISourceAsset. Based on your stack configuration, it's up to you 
		 * to link sourceTypes to different IDTypedStacks.
		 */
		function get sourceType():String;
		
		function get source():*;
		
	
		
	}
	
}