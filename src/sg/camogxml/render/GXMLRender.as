package sg.camogxml.render
{
	import camo.core.display.IDisplay;
	import camo.core.property.IPropertySheet;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPseudoBehaviour;
	import sg.camogxml.api.IDTypedStack;
	
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	import sg.camo.interfaces.ITextField;
	import sg.camo.interfaces.IText;
	
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.ISelectorSource;
	
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IRecursableDestroyable;
	import sg.camo.interfaces.IDisplayRender;

	import sg.camogxml.api.IGXMLRender;

	/**
	* A basic one-time(render-once) DisplayObjectContainer/DisplayObject renderer in DOM-based XML.
	* 
	* @author Glenn Ko
	*/
	
	[Inject(name='gxml',name='gxml',name='gxml',name='',name='textStyle')]
	public class GXMLRender extends XMLDocument implements IRecursableDestroyable, IDisplayRender, IGXMLRender
	{
		protected var _rootNode:XMLNode;
		protected var _behCache:Dictionary = new Dictionary();
	
		protected var _rendered:DisplayObject;
		protected var _renderId:String = "GXMLRender";
		protected var _isActive:Boolean = false;
		
		protected var bindAttribute:Function = dummyBinding;
		protected var bindText:Function = dummyBinding;
		
		
		// Required injectable properties (method/constructor supplied)
		public var dispPropApplier:IPropertyApplier;
		public var behPropApplier:IPropertyApplier;
		public var textPropApplier:IPropertyApplier;
		public var attribPropApplier:IPropertyApplier;
		
		// Required (constructor supplied)
		public var stylesheet:ISelectorSource;
		public var behaviours:IBehaviouralBase;
		public var definitionGetter:IDefinitionGetter;
				
		// Required (for inline stylesheet support. This must be a IPropertyApplier instance)
		[Inject(name="inlineSheet")]
		public var inlineStyleSheetClass:Class;
		
		// Optional Public Settings
		public static var DEFAULT_COMPRESS_CSS:Boolean = true;
		public var compressInlineCSS:Boolean;
		
		// rarely injected (constructor initialised by convention based on global stylesheet/definitions)
		public var defaultClass:Class;
		public var defaultTextClass:Class;
		public var defaultTextFieldProps:Object;
		public var defaultPseudoBehaviours:Object;

		// Flags
		protected var _curProps:Object;
		protected var _curPropsArr:Array;
		protected var _curInlineAttributes:Object;
		protected var _parsed:Boolean = false;
		protected var _xmlCache:XML;
		
		/**
		 * If stacking id is supplied, you can stack inline stylesheet selector over
		 * existing base stylesheet dependency if base stylesheet dependency is an IDTypedStack. Otherwise,
		 * a fresh clone of the IDTypedStack stylesheet is created and combined with the inline stylesheet. THis is usually
		 * used under a site framework like Gaia Flash Framework.
		 */
		public var stackingId:String;
		
	
		public function GXMLRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier) 
		{
			super();
	
			if (definitionGetter == null) return;
			
			compressInlineCSS = DEFAULT_COMPRESS_CSS;
			
			this.stylesheet = stylesheet;
			this.behaviours = behaviours;
			this.definitionGetter = definitionGetter;
			
			defaultClass = defaultClass || definitionGetter.getDefinition("DefaultNode") as Class;
			defaultTextClass = defaultTextClass || definitionGetter.getDefinition("DefaultTextNode") as Class;
			defaultTextFieldProps = defaultTextFieldProps || stylesheet.getSelector("TextField") || { };
			defaultPseudoBehaviours = defaultPseudoBehaviours || stylesheet.getSelector("PseudoBehaviours") || { };
			
		
			this.dispPropApplier = propApplier;
			this.behPropApplier = propApplier;
			this.attribPropApplier = propApplier;
			this.textPropApplier = textPropApplier || propApplier;
			
			
			ignoreWhite = true;
		}
		
		[Inject(name='gxml.display', name='gxml.behaviour', name='gxml.text', name='gxml.attribute')]
		public function setCustomPropAppliers(dispPropApplier:IPropertyApplier=null,behPropApplier:IPropertyApplier=null,textPropApplier:IPropertyApplier=null,attributePropApplier:IPropertyApplier=null):void {
			if (dispPropApplier) this.dispPropApplier = dispPropApplier;
			if (behPropApplier)  this.behPropApplier  = behPropApplier;
			if (textPropApplier) this.textPropApplier = textPropApplier;
			if (attributePropApplier) this.attribPropApplier = attributePropApplier;
			
		}
		
		[Inject(name='gxml.attribute')]
		public function setAttribPropApplier(val:IPropertyApplier=null):void {
			if (val) this.attribPropApplier = val;
			
		}
		

		
	
		/**
		 * Sets string binding method to process inline attribute values in nodes. Inline attribute values are passed to the 
		 * rendered node instance as additional properties for the property selector.<br/><br/>
		 * The function must accept a string and return a string.
		 */
		[Inject(name="gxml")]
		public function setAttributeBinding(func:Function=null):void {
			bindAttribute = func || dummyBinding;
		}
		public function get attributeBinding():Function {
			return bindAttribute;
		}
		/**
		 * Sets string binding method to process text values in text nodes.<br/><br/>
		 * The function must accept a string and return a string.
		 */
		[Inject(name="gxml")]
		public function setTextBinding(func:Function=null):void {
			bindText = func || dummyBinding;
		}
		/**
		 * Allows re-setting of optional inline text binding
		 */
		[PostConstruct(name = "gxml.textBinding")]
		public function setTextBinding2(func:Function = null):void {
			bindText = func || dummyBinding;
		}
		
		private final function dummyBinding(val:String):String {
			return val;
		}
		


		
		protected function getBehaviour(behName:String, node:XMLNode):IBehaviour {
			var retBeh:IBehaviour;
			var ider:String 
			var pseudoIndex:int = behName.indexOf("!");
			if (pseudoIndex > -1) {
				var pseudoBehNamespace:String = behName.substr(pseudoIndex);  // with exclaimation mark
				var pseudoState:String = pseudoIndex > 0 ?  behName.substr(0, pseudoIndex) : " ";
				var findBeh:String = defaultPseudoBehaviours[behName] || defaultPseudoBehaviours[pseudoBehNamespace];
				retBeh =  behaviours.getBehaviour(findBeh);
				
	
			
				applyBehaviourProperties(retBeh, behName, node, pseudoBehNamespace, pseudoState);
				return retBeh;
			}
			retBeh = behaviours.getBehaviour(behName);


			applyBehaviourProperties(retBeh, behName, node);
			
			return retBeh;
		}
		
		protected function applyBehaviourProperties(beh:IBehaviour, behLookupName:String, node:XMLNode, pseudoNamespace:String=null, pseudoState:String=null):Object {
			var behStyleArr:Array =  pseudoNamespace != null ? [">"+beh.behaviourName, ">"+behLookupName, pseudoNamespace, ">"+behLookupName] : beh.behaviourName != behLookupName ? [">"+beh.behaviourName, ">"+behLookupName] : null;
			var totalArr:Array;
			var len:int = _curPropsArr.length;
			
			var i:int = 0;
			if (behStyleArr == null) {

				totalArr = new Array(len + 1);
				
				totalArr[0] = ">"+beh.behaviourName;
				i = 0;
				while ( i < len) {		// do single loop
					totalArr[i+1] =  _curPropsArr[i] + ">" + behLookupName;
					i++;
				}
			}
			else {  
				
				totalArr = behStyleArr;
				var ulen:int = behStyleArr.length;
				while (i < len) {		// do heavier nested loop
					var u:int = 0;
					while ( u < ulen) {
						totalArr.push( _curPropsArr[i] +  behStyleArr[u] );
						u++;
					}
					i++;
				}
				
			}

			var props:Object = stylesheet.getSelector.apply(null, totalArr);
			if (pseudoState) props.pseudoState = pseudoState;
			behPropApplier.applyProperties(beh, props)
			return props;
		}
		

		
		// -- IGXML
		
		/**
		 * 		
		 * Renders full xml with support for inline stylesheet and inline body.
		 * <br/><br/>
		 * Renders an already validated XML markup instance reference, and stores a XML cache of the reference 
		 * from which an inline stylesheet node and a body node can be retrieved. Use this method to render full GXML with
		 * support for inline stylesheets.
		 * @param	xml	A valid XML instance
		 */
		public function renderGXML(xml:XML):void {
			_xmlCache = xml;
			parseXML(xml);
		}
		
		// ---
		/**
		 * Used internally in parseXML() to retrieves XML cache instance by default, and also cleans up XML cache reference 
		 * after the XMLDocument has been created.<br/>
		 * If you need to keep the XML cache reference for whatever reason in extended classes, you have to overwrite 
		 * this method.
		 */
		protected function toRenderXMLCache():XML {
			var result:XML = _xmlCache;
			_xmlCache = null;
			return result;
		}
		
		/**
		 * Quick setter to parse an XMLDocument as a raw string. Same as parseXML().
		 */
		public function set xml(val:String):void {
			parseXML(val);
		}
	
		
		public function get rendered():DisplayObject {
			return _rendered;
		}
			
		public function getRenderedById(id:String):DisplayObject {
			
			return idMap[id] != null ? idMap[id].attributes.rendered : null;
		}
		
		public function restore(changedHash:Object = null):void {
			
		}
		
		public function get renderId():String { 
			return _renderId;
		}
		public function set isActive(boo:Boolean):void {
			_isActive = boo;
		}
		public function get isActive():Boolean {
			return _isActive;
		}
		
		
		public function get parsed():Boolean {
			return _parsed;
		}
		

		private function validateBody(xml:XML):XML {
			var body:XMLList = xml.body;
			if (body.length() < 1) return null;
			var bodyList:XMLList = body[0].*;
			return bodyList.length() > 0 ? XML(body) : null;
		}
		
		/** @private*/
		protected function considerInlineStylesheet(xml:XML):Boolean {
			if (inlineStyleSheetClass != null && xml.stylesheet.length()> 0) {
				
				var inlineCSS:String = xml.body.length() > 0 ? xml.stylesheet[0] || " " : null;
				if (inlineCSS ) {
					var propSheet:IPropertySheet = new inlineStyleSheetClass() as IPropertySheet;
					if (propSheet != null) {
						propSheet.parseCSS(inlineCSS, compressInlineCSS);
						if (stylesheet == null) {
							stylesheet = propSheet;
						}
						else {  // perform merge with current stylesheet
							var selNames:Array = stylesheet.selectorNames;  
							if ( (stylesheet is IDTypedStack)  ) { // merge using IDTypedStack interface
								if (stackingId != null) (stylesheet as IDTypedStack).addItemById(propSheet, stackingId)
								else {
									stylesheet = (stylesheet as IDTypedStack).cloneStack()  as ISelectorSource;
									(stylesheet as IDTypedStack).addItemById(propSheet, "");
								}
								return true;
							}
							else if (stylesheet!=null) {
								for each(var selName :String in selNames) {		// todo: non-destructive merge
									// consider don't overwrite if property sheeet already has selector, but merge ?
										propSheet.newSelector( selName, stylesheet.findSelector(selName) ); // overwrite directly for now..
									//}
								}
							}
							stylesheet = propSheet;
						}
						return true;
					}
					else {
						trace("parseXML inlineStylesheet. Cast to IPropertySheet failed for instantiated class:" + inlineStyleSheetClass);
						return false;
					}
				}
				else {
					trace("Parse gxml inline stylesheet and body section failed for gxml markup:" + xml);
					return false;
				}
			}
			return false;
		}
		
		// --XMLDocument
		
		/**
		 * Parses raw source string into an XMLDocument for rendering of display.  If the method<code>renderGXML(xml:XML)</code>
		 * is used to call this,  the parser will also consider it's XML markup's
		 * inline stylesheet node and actual body node to use for rendering the XMLDocument.
		 * @param	source
		 */
		override public function parseXML(source:String):void {
			if (_parsed) return;
			
			var renderXMLCache:XML = toRenderXMLCache();
		
			var body:XML = validateBody(renderXMLCache);
			if (body != null) {
				source = body;
				considerInlineStylesheet(renderXMLCache);
				
			} 
			
			
			super.parseXML(source);
			_parsed = true;
			
			var node:XMLNode = firstChild;
			
			
			if (node == null) {
				trace("GXMLRender: parseXML() halted. No first child node from root!");
				
				return;
			}
			
			_rootNode = node.firstChild;
			
			
			_renderId = node.attributes.renderId || node.nodeName;
			
			node = _rootNode;
			
			//delete node.attributes['class'];
			
			_rendered = renderNode(node);
			
	
			
	
			if (_rendered == null) {
				trace("GXMLRender: parseXML() halted. Root node must be a displayObject");
				
				return;
			}
			
			if (_rendered is DisplayObjectContainer && !isTerminalNode(node) ) {
				createChild(node.firstChild, _rendered as DisplayObjectContainer)  // recurse and create children
			}
			
		
			_curProps = null;
			
			
			
		}
		

		
		protected function createChild(node:XMLNode, parent:DisplayObjectContainer):DisplayObject {
			
			while (node) {
				var disp:DisplayObject = renderNode(node);
				if (disp != null) parent.addChild(disp);
				
				var cont:DisplayObjectContainer = disp as DisplayObjectContainer;
				if (cont != null)  {
					if ( !isTerminalNode(node) ) createChild(node.firstChild, cont);
				}
				node = node.nextSibling;
			}
			
			return disp;
		}

		
		protected function renderUntyped(untyped:*, node:XMLNode, props:Object):void {
			if (untyped is IBehaviour) {
				var behBase:IBehaviouralBase = node.parentNode.attributes.rendered as IBehaviouralBase;
				if (behBase == null) return;
				behBase.addBehaviour( untyped as IBehaviour );
				dispPropApplier.applyProperties(untyped, props);
			}
		}

		protected function renderNode(node:XMLNode):DisplayObject {			
			var props:Object = getSelectorFromNode (node);
			
			_curProps = props;
			var isTxtNode:Boolean = isTextNode (node);
			var renderedItem:* = getRenderedItem(node, isTxtNode);
			if (renderedItem == null) {
				trace("Warning:: renderedItem of " + node.nodeName + " is null");
			}
			var disp:DisplayObject = renderedItem as DisplayObject;
			
			if (disp == null) {
				
				renderUntyped(renderedItem, node, props);
				return null;
			}
			
			injectDisplayProps(disp, props, node);
			
			isTxtNode = isTextPropInjectable(renderedItem);
			if (isTxtNode) injectTextFieldProps(disp, props, node)
			
			injectDisplayBehaviours(disp, props, node);
			

			node.attributes.rendered = disp;
		
			return disp;
		}
		
		protected function isTextPropInjectable(untyped:*):Boolean {
			return untyped is IText || untyped is ITextField || untyped is TextField;
		}
		
		protected function getRenderedItem(node:XMLNode, isTxtNode:Boolean):* {

			return definitionGetter.hasDefinition(node.nodeName) ? new  (definitionGetter.getDefinition(node.nodeName) as Class)() : isTxtNode ? new defaultTextClass() : new defaultClass();
		}
		

		
		
		protected function injectDisplayBehaviours(disp:DisplayObject, props:Object, node:XMLNode):Array {
			var behArray:Array = null;
			var attrib:Object = node.attributes;
	
			 if (props.behaviours) {	
				behArray =  props.behaviours.split(" ");
				var beh:IBehaviour;
				var len:int = behArray.length;
				var i:int = 0 ;
				if (disp is IBehaviouralBase) {  // use interface method to add behaviours, but leave it to the class to activate them
					var behBase:IBehaviouralBase = disp as IBehaviouralBase;
					while (i < len) {
						
						beh = getBehaviour( behArray[i], node );
							
						if (beh is IPseudoBehaviour) {
							behArray[i] = beh.behaviourName;
						}
						
						
						
						behBase.addBehaviour( beh);
						i++;
					}
				}
				else  {		// force-add behaviours over DisplayObject and activate them automatically
					
					while (i < len) {	
						beh = getBehaviour( behArray[i], node );
						
						if (beh is IPseudoBehaviour) {
							behArray[i] = beh.behaviourName;
						}
						
						beh.activate(disp);
						_behCache[beh] = true;
						i++;
					}
					
					
				}
				
				
			}	
			return behArray;
		}
		
		
		protected function findTextField(obj:Object):TextField {
			return obj is ITextField ? (obj as ITextField).textField :  obj as TextField;
		}
		protected function injectTextFieldProps(disp:DisplayObject, props:Object, node:XMLNode):Object {
			var props:Object;
			var txtField:TextField = findTextField(disp);
			if (txtField != null) { 
				var i:int = 0;
				var len:int = _curPropsArr.length;
				var totalArr:Array = new Array(len + 1);
				
				totalArr[0] = "TextField";
				while ( i < len) {		
					totalArr[i + 1] =  _curPropsArr[i] + ">textField";
					i++;
				}
				props = stylesheet.getSelector.apply(null, totalArr);
				textPropApplier.applyProperties( txtField, props );
			}
	
			var tarValue:String = node.firstChild ? node.firstChild.nodeValue : null;
			if (tarValue == null) return props; 
			if (disp is IText) (disp as IText).text = bindText(tarValue)
			else if (txtField != null) txtField.text = bindText(tarValue);
			
			return props;
		}
		
		protected function injectDisplayProps(disp:DisplayObject, props:Object, node:XMLNode):void {
			dispPropApplier.applyProperties( disp, props );
			attribPropApplier.applyProperties(disp, _curInlineAttributes);
		}
		
		// -- DOM Helpers
		
				
		protected function isTerminalNode(node:XMLNode):Boolean {
			return node.firstChild ? node.firstChild.nodeType == XMLNodeType.TEXT_NODE : true;
		}
		
		protected function getSelectorFromNode(node:XMLNode):Object {
			var sels:String = node.nodeName;
			var myPattern:RegExp =  /\s/g;
			var attrib:Object = node.attributes;
			sels += attrib["class"] ? ",."+ attrib["class"].replace(myPattern, ",.") : "";
			sels += attrib["id"] ? ",#" + attrib["id"] : "";
			var arr:Array = sels.split (",");
		
			var propSel:Object = stylesheet.getSelector.apply(null, arr);
			
			var obj:Object = { };
			_curInlineAttributes = obj;
			var tarObj:Object;
			
			if (attrib.behaviours) {
				propSel.behaviours = attrib.behaviours;
				delete attrib.behaviours;
			}
			
			for (var i:String in attrib) { 
				var str:String = attrib[i];
				obj[i] = bindAttribute(str);
			}
		
			_curPropsArr = arr;
			
			return propSel;
		}
		
		
		
		protected function isTextNode (node:XMLNode):Boolean {
			return node.firstChild!=null ?  node.firstChild.nodeType === XMLNodeType.TEXT_NODE : false;
		}
		
		// -- Destructors
		
		/**
		 * Automatically calls main <code>destroyRecurse()</code> function to perform full garbage collection.
		 */
		public function destroy():void {
			destroyRecurse(false);
		}
		
		public function destroyRecurse(boo:Boolean = false):void {
			for (var i:* in _behCache) {
				i.destroy();
			}
			
			if (_rootNode == null) return;
						
			/*if (boo && _rendered is IRecursableDestroyable) {
				(_rendered as IRecursableDestroyable).destroyRecurse(boo);
			}
			else*/
			destroyDisplay(_rendered, _rootNode.attributes);
			destroyAllFromNode(_rootNode, _rendered as DisplayObjectContainer);
			
			delete _rootNode.attributes.rendered;
			idMap = null;
			_rendered = null;
			_xmlCache = null;
		}
		
	
		
		protected function destroyDisplay(disp:DisplayObject, attrib:Object):void {
			if (disp is IDestroyable) (disp as IDestroyable).destroy();
		}
		
		protected function destroyAllFromNode(baseNode:XMLNode, dispCont:DisplayObjectContainer=null):void {	
			var node:XMLNode = baseNode.firstChild;
			var nextNode:XMLNode;
			var attrib:Object;
			while (node) {
				attrib = node.attributes;
				nextNode = node.nextSibling;
				node.removeNode();
				if (attrib.rendered) { 
					//if (attrib.rendered is IRecursableDestroyable) (attrib.rendered as IRecursableDestroyable).destroyRecurse(false)
					//else 
					var disp:DisplayObject = attrib.rendered;
					
					// this should consider exceptions if child was unparented
					dispCont.removeChild(disp); 
					
					destroyDisplay(disp, attrib);
					
					if ( !isTerminalNode (node) ) destroyAllFromNode(node, disp as DisplayObjectContainer);
					delete attrib.rendered;
				}
				node = nextNode;
			}
		}
		
		override public function toString():String {
			return "[A GXMLRender Instance]{" + _renderId + "}";
		}
		
		public function $toString():String {
			return super.toString();
		}
		
	}
	

	
}