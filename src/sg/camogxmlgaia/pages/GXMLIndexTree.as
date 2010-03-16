package sg.camogxmlgaia.pages 
{
	import com.gaiaframework.templates.AbstractPage;
	import com.gaiaframework.events.*;
	import com.gaiaframework.debug.*;
	import com.gaiaframework.api.*;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.ISelectorSource;
	import sg.camo.interfaces.ITransitionManager;
	import sg.camogxml.api.IDTypedStack;
	import sg.camogxml.api.IFunctionDef;
	import sg.camogxml.utils.FunctionDefCreator;
	import sg.camogxml.utils.ValueMap;
	
	import sg.camogxmlgaia.api.IGXMLIndexTree;
	import com.gaiaframework.api.*;
	
	import flash.system.ApplicationDomain;
	import sg.camogxmlgaia.api.*;
	import sg.camogxml.api.ISEORenderer;
	
	import sg.camogxmlgaia.utils.CamoAssetFilter;
	
	import sg.camogxml.utils.DependencyResolverUtil;
	
	import flash.utils.getDefinitionByName;
		
	
	/**
	 * This is the root index page of any CamoGXMLGaia website,
	 * and acts as a central control center and engine from which all other pages and their assets 
	 * can be auto-wired up. 
	 * <br/><br/>
	 * The GXMLIndexTree supports housing of multiple sub-GXMLIndexPages as well and navigating relatively
	 * from those index page locations, allowing sub-site development.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLIndexTree extends GXMLIndexPage implements IGXMLIndexTree
	{
		
		// Renderers
		private static var SEO_RENDERER_PRESET:XML = <seo class="sg.camogxml.seo.SEOPageRender"></seo>;
		private static var TRANSITION_RENDERER_PRESET:XML = <seo class="sg.camogxml.managers.gs.GSTransitionManager"></seo>;
	
		private static var GXML_RENDERER_PRESET:String = "sg.camogxml.render.GXMLRender";
		private static var GXMLPAGE_RENDERER_PRESET:String = "sg.camogxml.render.GXMLPageRender";
		
		// -- Render class name subjects and mapped values
		protected static const SUBJECT_GXML:String = "gxml";
		protected static const SUBJECT_GXMLPAGE:String = "gxmlPage"
		protected static const SUBJECT_SEOPAGE:String = "seoRender";
		protected static const SUBJECT_TRANSITION:String = "transition";
		
		// Node class spawner manager
		private static const DEFAULT_NODE_CLASS_SPAWNER:String = "sg.camogxml.utils.NodeClassSpawnerManager";
		
		// Storage 
		/** @private */ protected var _transitionManagers:Dictionary = new Dictionary();
		/** @private */	protected var _pageInstances:Dictionary = new Dictionary();
		
		// References
		/** @private */ protected var _renderClassNames:Dictionary = new Dictionary();
		
		// Private flags
		/** @private */ protected var _curPageRenderPath:String = "index";
		/** @private */ protected var _assetPathQuery:String;
		
		public function GXMLIndexTree() 
		{
			super();
		}
		
		/**
		 * This method can be registered to some ITypeHelperUtil to resolve strings to ValueMaps
		 * @param	str
		 * @return
		 */
		public function resolveValueMapHandler(str:String):ValueMap {
			return ValueMap.fromXMLString(str)
		}

		override public function transitionIn():void 
		{
			setupConfig();
			setupRenderClassNames();
			super.transitionIn(); 
		}

		
		/**
		 * Resolve binding method under Gaia to allow retrieving values in untype format for fully binded strings.
		 * @param	str		The string to consider
		 * @return	
		 */
		public function resolveBinding(str:String):* {
			
			if (str.charAt(0) === "{" && str.charAt(str.length - 1) === "}") {  // Check fully binded string
				var expression:String = str.substr(1, str.length - 2); 
				var bracketIndex:int = expression.indexOf("(");
				var substr:String  = null;
				if (bracketIndex > -1) {
					substr = expression.slice( bracketIndex + 1, expression.length - 1);
					expression = expression.slice(0, bracketIndex);
				}
				if (expression.charAt(0) === "@") return stage.loaderInfo.parameters[expression.substr(1)];
				// if expression does not contain a branch, look in Main (can't seem to support this due to namespace limitations)
				//if (expression.indexOf(".") == -1 && expression.indexOf("/") == -1) return resolveBinding(GaiaMain.instance[expression]);
				
				if (expression.indexOf(".") == -1 && expression.indexOf("/") == -1) return Gaia.api.resolveBinding(expression);
				// if str contains a branch, look in that page
				var branchVarPair:Array = expression.split(".");
				var page:IPageAsset = Gaia.api.getPage(branchVarPair[0]);
				if (page != null)
				{
					if (page.content && page.percentLoaded == 1) {
						//var prop:String = branchVarPair[1];
						//var chkContentProp:* = page.content.hasOwnProperty(prop) ? page.content[prop] : null;
						var chkContentProp:* =page.content[branchVarPair[1]];
							if ( (chkContentProp is Function) && substr!=null) return chkContentProp(substr);
		
						return chkContentProp;
					}
				}
				else
				{
					GaiaDebug.error("*Invalid str* Page '" + branchVarPair[0] + "' does not exist in site.xml");
					return Gaia.api.resolveBinding(str);
				}
			}
			
			return Gaia.api.resolveBinding(str);	// Use Gaia's regular binding
		}
		
		
		/**
		 * Uses Gaia.api's resolveBinding() method.
		 * @param	str
		 * @return
		 */
		public function resolveBindingString(str:String):String {
			return Gaia.api.resolveBinding(str);
		}
		
		public function getBranchContent(str:String=""):* {
			str = str || page.branch;
			return Gaia.api.getPage(str).content;
		}
		
		
		
	
		public function getNewTransitionManager(page:IPageAsset):ITransitionManager {
			_curPageRenderPath = page.branch;
			var node:XML = page.node;
			_transitionManagers[page] = node.hasOwnProperty("transition") ? parseRenderNode(node.transition[0]) : parseRenderNode( TRANSITION_RENDERER_PRESET);
			return _transitionManagers[page];
		}
		
		

		/**
		 * Retrieves an already-available, or not yet available, page instance and inject dependencies
		 * accordingly into it.
		 * @param	classe	 A class  to instantiate
		 * @param	branch	A specified page branch to determine the lifecycle of the instance, 
		 * 					otherwise if null or blank, uses current index page branch. You can use unique named instances under
		 * 					a page branch by specifying a single '*' character and the name after it.
		 * 					(eg. index/home/*someNamedInstance)
		 * @param	node	Any XML node to use for instantiating through a NodeClassSpawner.
		 * @param   subject	A subject key you might want to pass to NodeClassSpawner
		 * @return
		 */
		public function getPageInstance(classe:Class, branch:String=null, node:XML = null, subject:*=null):* {	
			return checkPageInstance(classe, branch, node, subject, createPageInstance);
		}

		
		protected function checkPageInstance(classe:Class, branch:String, node:XML, subject:*, createMethod:Function, extraArgs:Array=null):* {
			branch = branch || page.branch;
			extraArgs = extraArgs || [];
			
			if (branch.indexOf("{") > -1) {
				branch = resolveBinding(branch);
			}
			
			var chkIndex:int = branch.indexOf("*");
			var pageBranch:String = chkIndex > -1 ? branch.substr(0, chkIndex) : branch;
			
			var trailingSlash:Boolean = pageBranch.charAt(pageBranch.length - 1) === "/";
			if (trailingSlash) {
				pageBranch = pageBranch.substr(0, pageBranch.length - 1);
			}
			if (!pageExists(pageBranch))  throw new Error("GXMLIndexTree checkPageInstance() failed! Page branch doesn't exist:"+pageBranch)

			var dictToRegister:Dictionary = _pageInstances[pageBranch] || (_pageInstances[pageBranch] = new Dictionary());
			var chkId:String = getQualifiedClassName(classe);  // to convert last dot to :: for first case
			chkId = chkIndex > -1 ? chkId + "*" + branch.substr(chkIndex + 1) : chkId;
			if (dictToRegister[chkId] != null) return dictToRegister[chkId];
			return createMethod.apply(null, [classe,branch,node,subject,dictToRegister,chkId].concat(extraArgs) );
		}

		protected function createPageInstance(classe:Class, branch:String, node:XML, subject:*, dictToRegister:Dictionary, keyToRegister:String):* {
			if (classe == null) throw new Error("GXMLIndexPage:: createPageInstance failed for:"+classe, branch);
			var instance:* = node != null ? _nodeClassSpawnerManager.spawnClassWithNode(classe, node, subject) : new classe();
			dictToRegister[keyToRegister] = instance;
			return instance;
		}
		
		 
		public function pageExists(path:String):Boolean {
			var validBranch:String = Gaia.api.getValidBranch(path);
			var page:IPageAsset = validBranch.length < path.length ? Gaia.api.getPage( validBranch ) : Gaia.api.getPage(path);
			return page ? page.branch === path : false;
		}
		
		
		// TODO: multicore indexing to find current relative index page
		protected function getCurrentIndex(page:IPageAsset):IGXMLIndexPage {
			return this;
		}
		

		private function getAssetFromPath(path:String):IAsset {
			var queryIndex:int = path.indexOf("#");
			if (queryIndex > -1) {
				_assetPathQuery = path.substr( queryIndex + 1);
				path = path.substr(0, path.length - (_assetPathQuery.length + 1) );
			}
			else _assetPathQuery = null;
			
			if (path.charAt(0) === "/" ) 
				path = (path.length < 2)  ? _curPageRenderPath :  _curPageRenderPath + path;
							
			if ( pageExists(path)  ) {
				return Gaia.api.getPage(path);
			}
			else {
				var split:Array = path.split("/");
				return split.length > 1 ? getPathPathAsset(split, path.slice(0, path.length - split[split.length - 1].length - 1)) :   null;
			}
			return null; 
		}
		private function getPathPathAsset(split:Array, path:String):IAsset {
			var page:IPageAsset = pageExists(path) ? Gaia.api.getPage(path) : null;
			return page ? page.assets[split[split.length - 1]] : null;
		}
		
		
		private function getSource(str:String):* {
			
			var asset:IAsset;
			var origStr:String = str;
			var strArray:Array  = str.split(" ");
			var len:int = strArray.length;
			var val:*;
			if (len > 1) {  // create a custom stack of asset sources
				var retArr:Array = [];
				for ( var i:int = 0; i < len;  i++ ) {
					val = resolveBindingString( strArray[i] );
					if (val is String) {
						str = val;
						asset =   getAssetFromPath(str);
						val = asset;
					}
					if (val == null) {
						GaiaDebug.log("GXMLIndexTree() getSource $stack$unit "+i+" failed. Can't find asset data for:"+val + " under: "+origStr);
						continue;
					}
					retArr.push(val);
				}
				return retArr;
			}
			else {	// reference asset directly
				val = resolveBindingString(str);
				if (val is String) {
					str = val;
					asset = getAssetFromPath(str);
					return asset;
				}
				else return val;
			}
			return null;
		}
		

		
		
		// Start Bindable resolvings boiler-plate...

		public function getRenderedFromStack(id:String):DisplayObject {
			// Assumption made for convention. THere is a default stack name of "render" which is also a IDisplayRenderSource.
			var renderStack:IDisplayRenderSource = getStack("render") as IDisplayRenderSource;
		
			if (!renderStack) return null;
		
			var dispRender:IDisplayRender = renderStack.getRenderById(id); 
			return dispRender ? dispRender.rendered : null;
			
		}
		public function get assetPathQuery():String {
			return _assetPathQuery;
		}
		public function get curPageRenderPath():String {
			return _curPageRenderPath;
		}
		
		public function get currentTransitionManager():ITransitionManager {
			var page:IPageAsset = Gaia.api.getPage(_curPageRenderPath);
			return  _transitionManagers[page] as ITransitionManager;
		}
		
		public function get currentTransitionManagerMethod():IFunctionDef {
			var transManager:ITransitionManager = currentTransitionManager;
			if (transManager == null) return null;

			 // assumpion made on last 2 params
			return FunctionDefCreator.create( transManager, "addTransitionModule", false, "|");
			
		}
		
		public function determineSource(str:String, attribVal:String = null):* {
			var typedStack:IDTypedStack = getStack(str);
			if (attribVal == null) {
				if (typedStack == null) {
					throw new Error("GXMLIndexTree.determineSource() failed! No typed stack found for:" + str +".");	
				}
				return typedStack;
			}

		
			var src:* = getSource(attribVal);
			if (typedStack == null) throw new Error("GXMLIndexTree::determineSource(). Can't find typed stack");
			var className:String =  getQualifiedClassName( typedStack.stackType );
			
			if (src is Array) {
				var newStack:IDTypedStack = getNewStack(str);
		
				var arr:Array = src;
				var len:int = arr.length;
				var page:IPageAsset = Gaia.api.getPage(_curPageRenderPath);
				for (var i:int = 0; i < len; i++) {
					var unitItem:* = DependencyResolverUtil.resolveDependency( arr[i], className, "gxml")
					if (unitItem != null) newStack.addItemById(unitItem, page.branch);
					else GaiaDebug.log("GXMLIndexTree::determineSource() stack unit failed for array:", i , arr[i]);
				}
				return newStack;
			}
			return DependencyResolverUtil.resolveDependency( src, className, "gxml") || warn("Couldn't find source dependency for -"+attribVal+" - "+className, typedStack);
		}
		
		public function cloneStack(branchId:String, stackId:String):IDTypedStack {
			var referStack:IDTypedStack = getStack(stackId);
			return referStack ? referStack.cloneStack(branchId) : null; 
		}
		

		// -- End Boiler plate
		
		
		
		
		// TODO: multicore indexes from current index page path
		public function gotoFrom(path:String, fromPage:IPageAsset = null):void {
			Gaia.api.goto(path);
		}
		
				

	
		
		/**
		 * Static Helper method to create e4x XML node class for node class spawner manager
		 */
		protected static function createXMLClass(nodeName:String, classAttrib:String, attributes:Object=null):XML {
			var node:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, "");
			node.nodeName = nodeName;
			node.attributes =  attributes || {};
			node.attributes["class"] = classAttrib;
			return XML(node);
		}
		

		// -- Resources
		
		override protected function setupInjector():void  {
			$setupInjector();
			
			// Enforce dependencies, if not found..and show warnings/error if still not found..
			if (_nodeClassSpawnerManager == null) {
				_nodeClassSpawnerManager = getImplementation(DEFAULT_NODE_CLASS_SPAWNER);
				_nodeClassSpawnerManager.bindingMethod = resolveBinding;
				if (_nodeClassSpawnerManager == null) GaiaDebug.error("GXMLIndexTree :: No Injector found!");
			}
			
			if (cgg_config.hasOwnProperty("DependencyResolverManager")) {
				DependencyResolverUtil.addFindingsMapBatch(cgg_config.DependencyResolverManager[0]);
			}
			DependencyResolverUtil.bindingMethod = resolveBinding; 
		}
		
		protected function $setupInjector():void {
			super.setupInjector();
		}
		
		/**
		 * Sets up render class names for each render category based on cgg_config xml.
		 */
		protected function setupRenderClassNames():void {
			var tryList:XMLList = cgg_config.renderClasses;
			tryList = tryList.length() > 0 ? tryList : cgg_config.renderClasses;
			if (tryList.length() < 0) {
			//	GaiaDebug.log("No render class definitions found
				return;
			}
			tryList = tryList[0].*; 
			for each ( var xml:XML in tryList) {
				considerRenderClassSubject(xml);
			}
		}
		
		/** @private */
		protected function considerRenderClassSubject(xml:XML):void {
			var nodeName:String = String( xml.name() );
			var targDefaultProp:String;
			switch (nodeName) {
				case SUBJECT_GXML: break;
				case SUBJECT_GXMLPAGE:  break;
				case SUBJECT_SEOPAGE:  break;
				case SUBJECT_TRANSITION:  break;
				default: return;
			}
			var listNodes:XMLList = xml.*;
			for each (var node:XML in listNodes) {
				var value:String = String(node["@class"]);
				if ( !Boolean(value) ) {
					GaiaDebug.warn("GXMLIndexTree considerRenderClassSubject() :: Warning. No valid class name supplied for:"+node.toXMLString() );
					continue;
				}
				 _renderClassNames[String(node.name())] = value; // should also consider subject?
			}
			
			if (_renderClassNames['default']) {
				trace( "Setting default class for subject:" + _renderClassNames['default'], nodeName ); 
				if (nodeName === SUBJECT_GXML) GXML_RENDERER_PRESET = _renderClassNames['default']
				else if (nodeName === SUBJECT_GXMLPAGE) GXMLPAGE_RENDERER_PRESET =  _renderClassNames['default']
				else if (nodeName === SUBJECT_SEOPAGE) SEO_RENDERER_PRESET = node
				else if (nodeName === SUBJECT_TRANSITION) TRANSITION_RENDERER_PRESET = node;
				delete _renderClassNames['default'];
			}
		}
		
		
		// --IGXMLIndexTree 
		
		public function prepareSources(page:IPageAsset, ...args):void {
			var assetsHash:Array = CamoAssetFilter.getSourceAssets(page.assets, page.node.asset);
			var len:int = assetsHash.length;
			var curIndex:IGXMLIndexPage =  getCurrentIndex(page);
			for (var i:int = 0; i < len; i++) {
				var asset:ISourceAsset = assetsHash[i];
				var node:XML = (asset as IAsset).node;
				if (node.@stacking == "false" ) continue;
				addSourceAssetToStack(asset, node, curIndex, page);
			}
		}
		
		private function addSourceAssetToStack(asset:ISourceAsset, node:XML, curIndex:IGXMLIndexPage, page:IPageAsset):void {
			var sourceType:String = asset.sourceType;
			var typedStack:IDTypedStack = getStack(sourceType);
		
			if (typedStack == null) return;
			var settings:XML = _stacksXML[sourceType];
			if ( !(settings.@alwaysStack != "false" || node.@stacking == "true") ) return;
			var stackType:Class = typedStack.stackType;
			if (asset is INodeClassAsset) (asset as INodeClassAsset).spawnClass(_nodeClassSpawnerManager);
			//if (asset.source is stackType) {
			
				typedStack.addItemById(asset.source, page.branch);
			//}
		}
		
		
		public function removeSources(page:IPageAsset, ...args):void {
			var iDes:IDestroyable;
			for (var i:* in _stacks) {
				_stacks[i].removeItemsById(page.branch);
			}
			
			if (_transitionManagers[page]) {
				iDes = _transitionManagers[page] as IDestroyable;
				if (iDes) iDes.destroy();
				delete _transitionManagers[page];
			}
			
			var hash:Dictionary = _pageInstances[page.branch];
			if (!hash) return;
			for (i in hash) {
				iDes = hash[i] as IDestroyable;
				if (iDes) iDes.destroy();
			}
			delete _pageInstances[page.branch];
		}
		
		
		public function renderDisplays(page:IPageAsset, ...args):void {
			
			_curPageRenderPath = page.branch;
			var displayRenderAssets:Array = CamoAssetFilter.getDisplayRenderAssets(page.assets, page.node.asset);
			var len:int = displayRenderAssets.length;
			
			for (var i:int = 0; i < len; i++) {
				var dispRenderAsset:IAsset = displayRenderAssets[i];
				var node:XML = dispRenderAsset.node;

				
				if (node.@type == "gxmlPage") continue;
				
				if (dispRenderAsset is INodeClassAsset) {
					
					if (node['@class'] == undefined) node['@class'] = node['@renderType']!= undefined  ? _renderClassNames[node['@renderType'].toString()] || GXML_RENDERER_PRESET : GXML_RENDERER_PRESET;
					(dispRenderAsset as INodeClassAsset).spawnClass(nodeClassSpawner);
				}
				// gxml pages are rendered later (but declared first in the asset list)
				if (dispRenderAsset is IGXMLAsset) (dispRenderAsset as IGXMLAsset).renderGXML();
				
			
				if (node.@stacking != undefined && node.@stacking != "false" ) {
					var renderStack:IDTypedStack = getStack("render");
					
					if (renderStack) {
						renderStack.addItemById( (dispRenderAsset as IDisplayRenderAsset).displayRender, page.branch);
					}
				}
			}
		}
		

		public function renderPageLayers(page:IPageAsset, ...args):void {
			_curPageRenderPath = page.branch;
			var list:XMLList = page.node.asset;
			var assets:Object = page.assets;
			var len:int = list.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = list[i];
				// assumption made automatically based on type to render gxmlpage . 
				// Such assets should be declared first in the list
				if (xml.@type == "gxmlPage") {	
					var gxmlAsset:IGXMLAsset = (assets[xml.@id.toString()] as IGXMLAsset);
					var gxmlPageRender:*;
					if (gxmlAsset is INodeClassAsset) {
						if (xml['@class'] == undefined) xml['@class'] = xml['@renderType']!= undefined  ? _renderClassNames[xml['@renderType'].toString()] || GXMLPAGE_RENDERER_PRESET : GXMLPAGE_RENDERER_PRESET;
						gxmlPageRender = (gxmlAsset as INodeClassAsset).spawnClass(nodeClassSpawner);
					}
					gxmlAsset.renderGXML();
					var renderStack:IDTypedStack = getStack("render");
					if (gxmlPageRender &&  renderStack && xml.@stacking=="true" && (gxmlPageRender is IDisplayRenderSource) ) {
						// Always stack page renders regardless
						// assumption made that 'gxmlPage' is IDisplayRenderSource, 
						// and IDTypedStack handles IDisplayRenderSource. No type checking done....
						renderStack.addItemById(gxmlPageRender ,_curPageRenderPath);
					}
				}
				if ( xml.@depth != undefined ) {
					var disp:DisplayObject= DependencyResolverUtil.resolveDependency( assets[xml.@id.toString()], "flash.display::DisplayObject", "depth");
					if (disp) addChildAtDepth(disp, xml.@depth.toString() );
					else GaiaDebug.log("renderPageLayers() depth. No displayObject dependency found for:" + assets[xml.@id.toString()] );
				}
			}
		}
		
		private function addChildAtDepth(child:DisplayObject, depth:String):void {
			child.visible = true;  // imply always visible, since default Gaia assets start out invisible by default
			
			switch (depth) {
				case Gaia.TOP:  
				case Gaia.MIDDLE:
				case Gaia.BOTTOM: 
								Gaia.api.getDepthContainer(depth).addChild(child);
								  return;
				case Gaia.NESTED:
				case "page":	
							Gaia.api.getPage( _curPageRenderPath ).content.addChild(child);
							return;
				default: 
					var cont:DisplayObjectContainer = getRenderedFromStack(depth) as DisplayObjectContainer || DependencyResolverUtil.resolveDependency( getAssetFromPath(depth), "flash.display::DisplayObject", "depth" ) as DisplayObjectContainer;
					if (cont) {
						cont.addChild(child);
						return;
					}
				break;
			}
			GaiaDebug.log("addChildAtDepth() failed. No container found for:" + depth);
		}
		
		public function renderPageContent(page:IPageAsset, ...args):void {
			_curPageRenderPath = page.branch;
		
			var checkSeo:XML = page.copy ? page.copy.innerHTML : null;

			if (checkSeo) {
				var targetNode:XML = page.node.hasOwnProperty("seo") ? page.node.seo[0] : SEO_RENDERER_PRESET;
				var seoRenderer:ISEORenderer =  parseRenderNode( targetNode, "seo" ) as ISEORenderer;
				
				// have to clean up xmlns root header, since Gaia doesn't do it.
				seoRenderer.renderSeo( XML(String(checkSeo).replace(/\s+xmlns(:[^=]+)?="[^"]*"/g, ""))  );
			}
			
		}
		
		public function parseRenderNode(node:XML, subject:*= null):* {
			if (node["@class"] == undefined && node.@renderType != undefined) {
				node["@class"] = _renderClassNames[node.@renderType.toString()];
			}
			return parseNode(node, subject );
		}
		
		// TODO: Multicore indexes
		public function addIndexPage(page:IGXMLIndexPage):void {
			
		}
		public function removeIndexPage(page:IGXMLIndexPage):void {
			
		}
		
	}

}