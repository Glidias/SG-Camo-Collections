package sg.camogxmlgaia.pages 
{
	import com.gaiaframework.templates.AbstractPage;
	import sg.camo.interfaces.ITransitionManager;
	import sg.camogxmlgaia.api.IGXMLIndexTree;
	import com.gaiaframework.api.Gaia;
	
	import com.gaiaframework.debug.GaiaDebug;
	
	/**
	 * Base extendable node page template for all pages. Every page is a node in the CGG framework.
	 * (Also Consider: a final pre-defined Lite version that doesn't provide an extendable code-base)
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLNodePage extends AbstractPage
	{
		/**
		 * Reference to IGXMLIndexTree api on the root index page
		 * @see sg.camogxmlgaia.api.IGXMLIndexTree
		 */
		protected var cggTree:IGXMLIndexTree;
		
		/**
		 * Reference to a ITransitionManager interface
		 * @see sg.camo.interfaces.ITransitionManager
		 */
		protected var _transitionManager:ITransitionManager;
		
		public function GXMLNodePage() 
		{
			super();
		}
		
		override public function transitionIn():void {
			super.transitionIn();
			// if not already declared, declare one
			cggTree =  cggTree || Gaia.api.getSiteTree().content as IGXMLIndexTree; 
			$transitionIn();
		}
		
		override public function transitionOut():void {
			super.transitionOut();
			$transitionOut();
		}
		
		/**
		 * Runs default transition out complete procedure
		 */
		override public function transitionOutComplete():void  {
			$transitionOutComplete();
		}
		
		/**
		 * Default transition out complete procedure which asks root index page to unload all it's sources,
		 * including it's transition manager if it was initialised from there.
		 */
		public function $transitionOutComplete():void {
			cggTree.removeSources(page);
			super.transitionOutComplete();
		}
	
		/**
		 * Runs default 5 transition-in steps for typical node pages through the "my" functions. 
		 * Can be overwritten or extended in sub-classes if you wish, depending on user's needs.
		 */
		protected function $transitionIn():void {
			GaiaDebug.log("Node Page transiioning in:" + page.branch);
			myTransitionManager();
			myPrepareSources();
			myRenderDisplays();
			myRenderPageLayers();
			myRenderPageContent();
		}
		
		protected function $transitionInComplete():void {
			super.transitionInComplete();
		}
		
		/**
		 * Retrieves a new ITransitionManager implementation remotely through the root index page
		 * for this page.
		 * @see sg.camo.interfaces.ITransitionManager
		 * @return
		 */
		protected function myTransitionManager():void {
			var retManager:ITransitionManager =  cggTree.getNewTransitionManager(page);
			if (retManager != null) {
				retManager.transitionInComplete = transitionInComplete;
				retManager.transitionOutComplete = transitionOutComplete;
				_transitionManager = retManager;
			}
		}
		
		/**
		 * Prepares all ISourceAssets through the GXMLIndexTree for this page
		 * @see sg.camogxmlgaia.api.ISourceAsset
		 */
		protected function myPrepareSources():void {
			cggTree.prepareSources(page); 
		}
		
		/**
		 * Renders all IDisplayRenderAssets through the GXMLIndexTree for this page, particularly
		 * GXML renders.
		 * @see sg.camogxmlgaia.api.IDisplayRenderAsset
		 */
		protected function myRenderDisplays():void {
			cggTree.renderDisplays(page);
		}
		
		/**
		 * Renders all GXML page layers through the GXMLIndexTree, and also lays out 
		 * all other IDisplayRenderAssets at their appropiate depth levels.
		 */
		protected function myRenderPageLayers():void {
			cggTree.renderPageLayers(page);
		}
		/**
		 * Final phase which renders all SEO page content through the GXMLIndexTree. 
		 * Also calls transitionIn() on the transitionManager for this page, if available.
		 */
		protected function myRenderPageContent():void {
			cggTree.renderPageContent(page);
			if (_transitionManager != null) {
				_transitionManager.transitionIn();
			}
			else $transitionInComplete();
		}
		
		/**
		 * Default transition out process for a typical node page.
		 * Calls transitionOut() on the transitionManager for this page, if available.
		 */
		protected function $transitionOut():void {
			GaiaDebug.log("Node Page transiioning out:" + page.branch);
			if (_transitionManager != null) {
				_transitionManager.transitionOut();
				trace("Transioning out through transition manager");
			}
			else $transitionOutComplete();
		}
		

		

		
	}

}