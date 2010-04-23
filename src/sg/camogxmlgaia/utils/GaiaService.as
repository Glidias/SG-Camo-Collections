package sg.camogxmlgaia.utils 
{
	import com.gaiaframework.api.IGaia;
	import com.gaiaframework.api.IPageAsset;
	import flash.display.MovieClip;
	/**
	 * This utility class provides a commonly used set of methods to retrieve various useful information quickly
	 * from IGaia's api. Dump whatever methods here being used for Gaia's api for quick short-hand.
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject]
	public class GaiaService
	{
		public var api:IGaia;
		
		public function GaiaService(api:IGaia) 
		{
			this.api = api;
		}
		
		public function getPage(branch:String):IPageAsset {
			return api.getPage(branch);
		}
		public function getPageContent(branch:String):MovieClip {
			return api.getPage(branch).content;
		}
		public function getPageNode(branch:String):XML {
			return api.getPage(branch).node;
		}
		
		public function getCurrentPage():IPageAsset {
			return api.getPage( api.getCurrentBranch() );
		}
		
		public function getCurrentPageContent(branch:String):MovieClip {
			return api.getPage( api.getCurrentBranch() ).content;
		}
		
		public function getCurrentPageNode():XML {
			return api.getPage( api.getCurrentBranch() ).node;
		}
		
		
	}

}