package sg.camogxmlgaia.pages
{
	import camo.core.display.IDisplay;
	import com.gaiaframework.templates.AbstractPage;
	import com.gaiaframework.events.*;
	import com.gaiaframework.debug.*;
	import com.gaiaframework.api.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import sg.camogxml.api.IDTypedStack;
	import sg.camogxmlgaia.api.*;
	import sg.camogxml.api.ISEORenderer;
	


	/**
	 * A GXMLIndexPage is a boiler-plate page supporting configuration of standalone resources 
	 * (like stylesheets, behaviours, renders, etc.) and it's own content dependency injector to support the viewing of 
	 * every sub-page running under it, and the management of their sub assets.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLIndexPage extends GXMLNodePage implements IGXMLIndexPage
	{	
		protected var _stacksXML:Dictionary = new Dictionary();
		protected var _stacks:Dictionary = new Dictionary();
		
		protected var _nodeClassSpawnerManager:INodeClassSpawnerManager;
		protected var cgg_config:XML;

		public function GXMLIndexPage()
		{
			super();
		}
		
		protected function warn(verse:String, value:*):* {
			GaiaDebug.log(verse, "Using:", String(value));
			return value;
		}
		protected function throwError(message:String):* {
			throw new Error(message);
			return null;
		}
		
		
		
		override protected function $transitionIn():void {	
			if (cggTree != this) {
				cggTree.addIndexPage(this);
			}
			super.$transitionIn();
		}
		override protected function $transitionOut():void {
			super.$transitionOut();
			if (cggTree != this) {	
				cggTree.removeIndexPage(this);
			}
		}
		
		override public function transitionIn():void 
		{
			cggTree =  Gaia.api.getSiteTree().content as IGXMLIndexTree;
			
			// Run the prescribed operations in order.
			setupConfig();
			setupInjector();
			setupInjectorMappings();
			setupResourceStacks();
			

			super.transitionIn();
		}
		

		
		override public function transitionOut():void 
		{
			super.transitionOut();
		}

		
		/**
		 * 1. Sets up cgg_config xml if not set up before yet.
		 * Uses either the page's site.xml node or a preloaded "cgg_config" xml asset for the configuration xml.
		 */
		protected function setupConfig():void {
			if (cgg_config != null) return;
			cgg_config = assets.cgg_config is IXml ? (assets.cgg_config as IXml).xml :  page.node;
		}
		
		/**
		 * 2. Sets up a simple standalone XML node class instantiator/injector utility from cgg_config xml.
		 */
		protected function setupInjector():void  {

			var simpleDef:String = cgg_config.hasOwnProperty("NodeClassSpawnerManager") ? cgg_config.NodeClassSpawnerManager[0]["@class"] : null;
			if (simpleDef) {
				_nodeClassSpawnerManager = getImplementation(simpleDef);
				if (_nodeClassSpawnerManager == null) {
					throw new Error("GXMLIndexpage Critical Error! Setup NodeClassSpawner injector failed!");
					return;
				}
				_nodeClassSpawnerManager.bindingMethod = cggTree.resolveBinding;
			}
		}
		
		/**
		 * 3. Sets up attribute mappings for injector based on cgg_config xml.
		 */
		protected function setupInjectorMappings():void {
			if (_nodeClassSpawnerManager == null) return;
			
			var mappingList:XMLList = cgg_config.hasOwnProperty("NodeClassSpawnerManager") ? cgg_config.NodeClassSpawnerManager[0].NodeClassMapping : cgg_config.NodeClassMapping;
			for each ( var xml:XML in mappingList) {
				_nodeClassSpawnerManager.mapXMLSubjects(xml);
			}
		}
		
		/**
		 * 4. Sets up standalone resource stacks, if any, based on cgg_config xml.
		 */
		protected function setupResourceStacks():void {
			if (_nodeClassSpawnerManager == null) return;
			
			var tryStacks:XMLList = cgg_config.stacks;	
			if (tryStacks.length() > 0) {
				tryStacks = tryStacks[0].*
				for each (var xml:XML in tryStacks) {
				if (xml.@id == undefined) {
					GaiaDebug.log("setupResourceStacks() Warning! No id specified for:" + xml.toXMLString() );
					continue;
				}
				var ider:String = xml.@id.toString();
				_stacksXML[ider] = xml;
				if (xml.@instantiateNow == "true") getStack(ider);
				}	
			}
		}
		

		// -- IGXMLIndexPage
		
		/**
		 * Retrieves an already-available, or not yet available, resource stack under this page based on id.
		 * @param	id
		 * @return
		 */
		public function getStack(id:String):IDTypedStack {
			return _stacks[id]  || ( _stacks[id] = parseNode(_stacksXML[id]) );
		}
		
		/**
		 * Retrieves a fresh new resource stack instance based on id.
		 * @param	id
		 * @return
		 */
		public function getNewStack(id:String):IDTypedStack {
			return parseNode(_stacksXML[id], id);
		}
		

		
		
		/**
		 * Helper methods to instantiate a simple stand-alone class implementation without any constructor/setter injection.
		 * @param	className	
		 * @return
		 */
		public function getImplementation(className:String):* {
			var domain:ApplicationDomain  = loaderInfo.applicationDomain !== ApplicationDomain.currentDomain ? loaderInfo.applicationDomain : null;
			var classe:Class =  domain!=null  ? domain.hasDefinition(className) ? domain.getDefinition(className) as Class : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : null   : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : throwError("class retrieval failed:"+className);
			return new classe();
		}
		public function getClass(className:String):Class {
			var domain:ApplicationDomain  = loaderInfo.applicationDomain !== ApplicationDomain.currentDomain ? loaderInfo.applicationDomain : null;
			return  domain!=null  ? domain.hasDefinition(className) ? domain.getDefinition(className) as Class : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : null   : ApplicationDomain.currentDomain.hasDefinition(className) ? ApplicationDomain.currentDomain.getDefinition(className) as Class : throwError("class retrieval failed:"+className);
		}
		

		/**
		 * Helper method to  spawn instance via nodeClassSpawnerManager.
		 */
		protected function parseNode(xml:XML, subject:*=null):* {
			return _nodeClassSpawnerManager.parseNode(xml, subject, loaderInfo.applicationDomain);
		}
		
	

		// Get renderer/node class spawner implementations
		public function get nodeClassSpawner():INodeClassSpawner {
			return _nodeClassSpawnerManager;
		}

	}
}
