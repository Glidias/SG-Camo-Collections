package sg.camogxml.seo 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.ILabler;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.IRenderPool;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IListItem;
	import sg.camogxml.api.ISEORenderer;
	
	
	/**
	 * An E4x XML-based renderer for content management/injection and supports SEO-compliant integration.
	 * <br/><br/>
	 * Also supports various interface implementations under SG-Camo core (lists, text, etc.),  
	 * and various xHTML tags that link to these interfaces, including hyperlinking. 
	 * <br/><br/>
	 * Due to the nature of SEO content, it is assumed the xHTML/XML content being received
	 * is already localized and doesn't require bindings, or has already been type-converted.
	 * 
	 * @see sg.camo.interfaces.ITextField
	 * @see sg.camo.interfaces.IText
	 * @see sg.camo.interfaces.IList
	 * @see sg.camo.interfaces.ILabler
	 * 
	 * @author Glenn Ko
	 */
	public class SEOPageRender implements IDestroyable, ISEORenderer
	{
		/** @private */	protected var _xml:XML;
		/** @private */	protected var _renderSrc:IDisplayRenderSource;
		
		// Trackers
		/** @private */	protected var _anchors:Dictionary = new Dictionary();
		
		public var defaultLiAnchorMode:Boolean = true
		
		// Class Flags
		/** @private */  protected var _liAnchorMode:Boolean = true;
		/** @private */ protected var _liRenderMode:Boolean = false;
		/** @private */ protected var _liOrdered:Boolean = false;
		
		/**
		 * Constructor.
		 * @param	renderSrc	An IDisplayRenderSource reference from which to retrieve display render instances by id.
		 * @param	xml			(Optional) An XML reference to automatically start injecting content immediately.
		 */
		public function SEOPageRender(renderSrc:IDisplayRenderSource, xml:XML=null) 
		{
			_renderSrc = renderSrc;
			if (xml != null) this.xml = xml;
		}
		
		
		public function renderSeo(xmler:XML):void {
			//default xml namespace = new Namespace("http://www.w3.org/1999/xhtml");

			
			_xml = xmler;

			var rootList:XMLList = xmler.*;
			var i:int = 0;
			
			var len:int = rootList.length();
			
			
			var axml:XML;
			while ( i < len) {
				axml = rootList[i];	
			
				rootCaseNode( axml ); 
				i++;
			}
			
		}

		
		/**
		 * Sets xml reference to inject content immediately
		 */
		public function set xml(xmler:XML):void {
			renderSeo(xmler);
		}	
		public function get xml():XML {
			return _xml;
		}
		
		/**
		 * When the XML is set, this handles the following nodes on the root level: 
		 * div, a, span, ol and ul.
		 * 
		 * @param	node	The currently parsed node on the root level
		 */
		protected function rootCaseNode(node:XML):void {
			var nodeName:String = node.name();
			switch (nodeName) {
				case "div":  addDiv(node);  return;
				case "a": addRootAnchor(node);  return;
				case "span":  addSpan(node);  return;	
				case "ol":  
				case "ul":  addList(node); return;
				case "p":	addPNode(node); return;
				default: return;
			}
		}
		
		
		
		/** @private */
		protected function getInnerCopy(listChildren:XMLList):String {

			var prevIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
			var prevPrettyPrinting:Boolean = XML.prettyPrinting;
			XML.ignoreWhitespace = false;
			XML.prettyPrinting = false;
			///*
				var str:String = "";
				var len:int = listChildren.length();

				for (var i:int = 0; i < len; i++)
				{
					str += listChildren[i].toXMLString();
					
				}
				str = str.replace(/\s+xmlns(:[^=]+)?=\"[^=]*?\"/g, "");
				
			//*/
				/*
			var i:int = 0;
			var len:int = listChildren.length();
			var str:String = "";
			while (i < len) {
				str += listChildren[i].toXMLString();
				
				i++;
				}
			*/
			XML.ignoreWhitespace = prevIgnoreWhitespace;
			XML.prettyPrinting = prevPrettyPrinting;
			return str;
		}
		
	
		
		
		/**
		 * Supports inner copy <code>p</code> tags & inner anchor <code>a</code> tags under each div . <br/>
		 * Also supports recursively parsing nested divs to re-parent any rendered display objects into the current
		 * parent context.
		 * @param	node	The <code>div</code> node.
		 * @param	parentContext  (Used internally for recursing) any nested divs and re-parenting to that container (if available).
		 */
		protected function addDiv(node:XML, parentContext:DisplayObjectContainer = null):void {
			
			var txtField:TextField;
			var xml:XML; 
			
			var chkId:String = node.@id;

			var render:IDisplayRender = getRenderById(chkId, node);
			if (render == null) {
				trace("addDiv failed. No render for "+ chkId+" :" + node.toXMLString() );
				return;
			}
			var chkDisp:DisplayObject = validateRendered(render, node);
			
			if (chkDisp != null) {
				if (parentContext != null) { 
					addNestedChild(parentContext, chkDisp, render);
				}
				else if (chkDisp.stage == null) {
					//trace("Warning. No stage reference found for div:"+node);
				}
			}
			else {
				trace("addDiv critical warning! No rendered instance found for:"+node.toXMLString());
			}

		
			
			// Nested p tags
			var copyList:XMLList = node.p;
			var copyDisp:DisplayObject;
			
			for each (xml in copyList) {
				chkId = xml.@id;
				copyDisp = Boolean(chkId) ? getRenderedBy(chkId, render, xml) : chkDisp;
				if (copyDisp == null) {
					trace("addDiv p failed. Can't find rendered by id:"+chkId);
					continue;
				}
				addCopy(xml, copyDisp);
			}
			
			
			// Nested anchor tags
			addListOfAnchors(node.a, render);
			
			
			// Nested div tags
			var divList:XMLList = node.div;
			var len:int = divList.length();
			if (len < 1) return;

			var chkCont:DisplayObjectContainer = chkDisp as DisplayObjectContainer;
			if (chkCont == null) {
				trace("addDiv warning! Can't parse nested div list as DisplayObjectContainer:"+divList);
				return;
			}
			var i:int = 0;
			while ( i < len) {
				addDiv( divList[i], chkCont );
				i++;
			}
		}
		
		protected function addPNode(node:XML):Boolean {
			var copyDisp:DisplayObject = node.@id!=undefined? validateRenderedOf( node.@id, node) : null;
			if (copyDisp == null) {
				trace("add p node failed. Can't find rendered by id:"+node.toXMLString() );
				return false;
			}
			addCopy(node, copyDisp);
			return  true;
		}
		
		protected function addCopy(node:XML, copyDisp:DisplayObject):void {
			var chkChildren:XMLList =  node.children();
			var copyStr:String =  chkChildren.length() > 0 ? getInnerCopy(chkChildren) : String(node);
			
			if (!populateTextOf( copyDisp, copyStr, chkChildren.length() > 0 ) )
				trace("addDiv copy failed:" + node.toXMLString() );
		}
		


		/**
		 * Sets up labeling only through ILabler interface, with each nested <code>p</code> tag representing
		 * a label parameter in the array of labels. Also supports nested spans to repeat the process for any related ILabler items under the root IDisplayRender node.
		 * @param	node	The <code>span</code> node from which to start the labeling process.
		 * @param   labler	(Used internally for recursing) an already-supplied ILabler instance from the nested span node.
		 * @param   render  (Used internally for recursing) The already-supplied IDisplayRender instance from the root node.
		 * 
		 */
		protected function addSpan(node:XML, labler:ILabler = null, render:IDisplayRender=null):void {
			
			var render:IDisplayRender = render || getRenderById(node.@id, node);
				
			if (labler==null && render == null) {
				trace("addSpan halted. No render or ILabler found:" + node.toXMLString() );
				return;
			}
			
			labler = labler || 	validateRendered(render, node) as ILabler;
			
			if (labler == null) {
				addNestedSpans( node.span, render );
				return;
			}
			
			var xmlList:XMLList = node.p;
			var i:int = 0;
			var len:int = xmlList.length();
			var arr:Array = [];
			while ( i < len) {
				arr.push(xmlList[i]);
				i++;
			}
			if (arr.length < 1) {
				// don't apply labels, just skip and consider nested spans
				addNestedSpans( node.span, render );
				return;
			}
			
			labler.setLabels.apply(null, arr);	
			addNestedSpans( node.span, render );
			
		}
		/** @private */
		protected function addNestedSpans(xmlList:XMLList, render:IDisplayRender):void {
			for each (var xml:XML in xmlList) {
				var tryLabler:ILabler = getRenderedBy(xml.@id, render, xml) as ILabler;
				if (tryLabler == null) {
					trace("Nested span failed:" + xml.@id);
					continue;
				}
				addSpan(xml, tryLabler, render );
			}
		}
		
		/**
		 * Considers the following class values for each ul/li node to perform additional (or fixed) operations per list,
		 * or pre-define specific preferences for list item generation.... 
		 * (TODO: document ul/ol class formats)
		 * @param	node
		 * @param	id
		 * @param	classValue
		 * @param	render
		 * @param	list
		 * @return
		 */
		protected function considerListClass(node:XML, id:String, classValue:String, render:IDisplayRender =null, list:IList=null):Boolean {
			var list:IList;
			var xmlList:XMLList;
			var xml:XML;
			var render:IDisplayRender;
			var i:int;
			var len:int;
			
			_liAnchorMode = defaultLiAnchorMode;
			_liRenderMode = false;
			

			switch (classValue) {
				case "fast" :
					// Fast IList routine without considering nested lists or list anchor modes
					// Useful for mass-generating huge lists.
					if (list == null) {
						trace("SEOPageRender:: list fast routine failed. No found IList implementation: "+node.toXMLString() );
						return false;
					}
					xmlList = node.li;
					i = 0;
					len = xmlList.length();
					while ( i < len) {
						xml = xmlList[i];
						
						addToList(list, xml, xml.@id);
						i++;
					}
					// Trust that pple know better.
					//if (node.ol.length() > 0) trace("Warning! Nested lists don't render under fast routine:" + node.ol);
					//if (node.ul.length() > 0) trace("Warning! Nested lists don't render under fast routine:"+ node.ul);
					return true;
				
				// Turn off display object anchoring for list items, assuming htmlText will be 
				// set on  list item labels
				case "html": _liAnchorMode = false; 
				break;
				
				// Allow labeling operations through span labels and p tag for text copy.
				case "htmlLabler": _liAnchorMode = false;
				case "labler":  
				case "lablerRender":  // will perform "render" case as well
					var labler:ILabler = render ? validateRendered(render, node) as ILabler : null;
					if (labler != null) {	
						xmlList =  node.span;
						i = 0;
						len = xmlList.length();
						var arrOfLabels:Array = [];
						while ( i < len) {
							arrOfLabels.push(String( xmlList[i]));
							i++;
						}
						labler.setLabels.apply( null, arrOfLabels);
						
						xmlList = node.p;
						len = xmlList.length();
						if (len > 0) {
							var txt:String = len > 1 ? String(xmlList) : xmlList[0];
							populateTextOf(labler as DisplayObject, txt);
						}
					}	
				if (classValue != "lablerRender") break;
				
				// Use non IList implementation instead (ie. DisplayObjectContainer)
				case "render":	
					_liRenderMode = true;
				break;
				
				default: break;
			}
			
			return false;	// returning false continues regular IList routine under addList()
		}
		
		/** @private */
		
		/**
		 * @private
		 * @param	disp
		 * @param	text
		 * @param	useHtml
		 * @return	Any available textField instance that was succesffully set or null if unavalable
		 */
		protected function populateTextOf(disp:DisplayObject, text:String, useHtml:Boolean = false):TextField {
		
			if (disp is IText) {
				(disp as IText).text = text; // warning: encapsulates and ignores useHtml
				return disp is ITextField ? (disp as ITextField).textField : null;
			}
			var txtField:TextField = findTextField(disp);
			if (txtField) {
				if (!useHtml) txtField.text = text
				else txtField.htmlText = text;
				
				return txtField;
			}
			return null;
		}
		
		/**
		 * Sets up list item generation through the IList interface, with each nested li tag representing a list item.
		 * @param	node	The <code>ol</code> or <code>ul</code> node.
		 * @param	list	(Used internally for recursing) an already-supplied IList reference from the nested ol/ul node.
		 * @param   render  (Used internally for recursing) an already-supplied IDisplayRender reference from the nested ol/ul node
		 * @param   listCont  (Used internally for recursing) an already-supplied DisplayObjectContainer reference.
		 */
		protected function addList(node:XML, list:IList = null, render:IDisplayRender=null, listCont:DisplayObjectContainer=null ):void {
			_liOrdered = node.name() == "ol";
		
			var classValue:String = String(node["@class"]);
			//node.@style == "";
			var xmlList:XMLList;
			var i:int;
			var len:int;
			var id:String = node.@id;
			var xml:XML;
			
			render = render || getRenderById(id, node);
			
			if (list==null && render == null) {
				trace("addList failed. No render or IList found:"+node.toXMLString());
				return;
			}
			
			var rendered:DisplayObject = render != null ? validateRendered(render, node) : listCont || list as DisplayObject;
			listCont =  listCont ||  rendered as DisplayObjectContainer;
			list = list || 	rendered as IList;
			
			if ( considerListClass(node, id, classValue, render, list) ) return;
			
			
			xmlList = node.children();	// consider all nodes
			i = 0;
			len = xmlList.length();
			
		
			while ( i < len) {
				xml = xmlList[i];
				handleListNode(xml, render, list, listCont);
				i++;
			}
		
			
		}

		/** @private */
		protected function handleListNode(node:XML, render:IDisplayRender=null, list:IList=null, listCont:DisplayObjectContainer=null):void {
			var nodeName:String = node.name();
			var disp:DisplayObject;
			var dispCont:DisplayObjectContainer;
			var xml:XML;
			var id:String = node.@id;
			switch(nodeName) {
				case "ol": 
				case "ul": 	
				// Nested list routine
					dispCont = listCont; 
		
					list = render != null ? getRenderedBy(id, render, node) as IList : null; 
					trace(id, list, render);
					if (list != null) {
						addList(node, list);
						return;
					}
					
					render = getRenderById(id, node);
					if (render == null) {
						trace("Nested list node failed. No render for:" + node.toXMLString() );
						return;
					}
					
					disp = validateRendered(render, node);
		
					if (dispCont != null && disp != null) {
						addNestedChild(dispCont, disp, render);
					}
					addList(node, disp as IList, render, dispCont);
					return;
				case "li": 	 	
					if (list == null) {
						trace("IList is null");
						return;
					}
					
					if (_liRenderMode) { 
						dispCont = listCont;
						render = getRenderById(String(node["@class"]), null);
						disp = render ? render.rendered : null;
	
						if (disp != null && dispCont != null) {
							
							
							addNestedChild(dispCont, disp, render);
							if (disp is IListItem) (disp as IListItem).id = Boolean(String(node.@id)) ? node.@id : String(node.childIndex());
							if (disp is IIndexable && _liOrdered) {
								(disp as IIndexable).setIndex( node.childIndex() );  //dispCont.getChildIndex(disp)
							}
							
							var spans:XMLList = node.span;
							if (spans.length() > 0 ) {
								var labler:ILabler = disp as ILabler;
								if (labler == null) return;
								setLabelsOf(labler, spans);
								
								spans = node.p;
								if (spans.length() > 0) {
									populateTextOf(disp, spans[0]);
								}
							}
							else populateTextOf(disp, node);
				
						
							return;
						}
		
					}
					
					var ider:String = String(node.@id);
					
					if (!_liAnchorMode || node["@class"] == "html" ) { // don't consider any nested anchor tag 
						addToList(list, node, ider); 
						return;
					}

					var aList:XMLList = node.a;
					if (aList.length() <  1) {
						addToList(list, node, ider); 
						return;
					}
					node = aList[0];
					disp = addToList(list, node, ider);
					if (disp!=null) addAnchorToDisplay(disp, node);
					return;
					
					addToList(list, node, ider); 
					return;
				default: return;
			}
		}
		
		protected function setLabelsOf(labler:ILabler, listOfSpans:XMLList):Array {
			var len:int = listOfSpans.length();
			var i:int = 0;
			var arr:Array = [];
			while ( i < len) {
				var node:XML = listOfSpans[i];
				var innerList:XMLList = node.*;
				var txt:String = innerList.length() > 0 ?  getInnerCopy(innerList) : String(node);
				arr.push( txt );
				i++;
			}
			if (arr.length < 1) {
				return null;
			}
			return labler.setLabels.apply(null, arr);
		}
		
		
		// -- Anchors
		
		/**
		 * Add anchor hyperlink to rendered node on the root level
		 * @param	node	The <code>a</code> node.
		 */
		protected function addRootAnchor(node:XML):void {
			var chkDisp:DisplayObject = validateRenderedOf(node.@id, "addRootAnchor", node);
			if (chkDisp == null) return;
			addAnchorToDisplay(chkDisp, node);
		}
		
		/**
		 * Add anchor hyperlink to rendered node based on current IDisplayRender DIV context.
		 * @param	node   The <code>a</code> node.
		 * @param	parentDisplay	The current IDisplayRender DIV context
		 * @param 	text   Any accompanying text to set to the target anchored displayobject
		 */
		protected function addAnchor(node:XML, parentDisplay:IDisplayRender, text:String = null):void {
			var chkDisp:DisplayObject;
			var chkId:String =  node.@id;

			
			if (!Boolean(chkId)) {
				var parentContext:DisplayObjectContainer = parentDisplay.rendered as DisplayObjectContainer;
				if (parentContext == null) {
					trace("addAnchor failed, no valid id target or parent!"+node.toXMLString() );
					return;
				} 
				// Add anchor to parent node DisplayObjectContainer
				chkDisp = parentContext;
				addAnchorToDisplay(chkDisp, node, text);
				return;
			}
			
			// Add anchor to child rendered.
			chkDisp = getRenderedBy(chkId, parentDisplay, node);
			if (chkDisp == null) {
				trace("addAnchor failed, no valid rendered id: "+chkId+ " under IDisplayRender:"+parentDisplay.renderId);
				return;
			}
			addAnchorToDisplay(chkDisp, node, text);
			return;	
		}
		
		/** @private */
		protected function addListOfAnchors(xmlList:XMLList, parentDisplay:IDisplayRender):void {
			for each (var xml:XML in xmlList) {
				addAnchor(xml, parentDisplay, xml);
			}
		}
	
		/** @private */
		protected function addAnchorToDisplay(disp:DisplayObject, node:XML, text:String = null):void {
			
			if (_anchors[disp]) AncestorListener.removeEventListenerOf(disp, MouseEvent.CLICK, hrefClickHandler);  // rep
			AncestorListener.addEventListenerOf(disp, MouseEvent.CLICK, hrefClickHandler, 0, false);
			if (text != null) {
				populateTextOf(disp, text);
			}
			
			_anchors[disp] = node;
		}

		
		/**
		 * Handles click by dispatching a TextEvent.LINK bubble with supplied href attribute as the text value.
		 * @param	e	
		 */
		protected function hrefClickHandler(e:MouseEvent):void {
			//e.stopPropagation();
			
			var disp:DisplayObject = e.currentTarget as DisplayObject;
			disp.dispatchEvent ( new TextEvent(TextEvent.LINK, true, false, String((_anchors[disp] as XML).@href) ) );
		}
		
		// --Helpers
		
		/** @private */
		protected function validateRenderedOf(id:String, prefix:String="SEOPageRender::validateRenderedOf()", node:XML=null):DisplayObject {
			var render:IDisplayRender =  getRenderById(id, node);
			if (render == null) {
				trace(prefix+" retrieving IDisplayRender failed for id:" + id);
				return null;
			}
			var rendered:DisplayObject = validateRendered(render, node);
			if (rendered == null) {
				trace(prefix+" retrieving rendered DIsplayObject failed for id:" + id);
				return null;
			}
			return rendered;
		}
		
		/**
		 *  Used internally to keep track of render displayobject requests per node.
		 * @param	render    The IDisplayRender to call "rendered" accessor.
		 * @param	node  
		 * @return	The rendered DisplayObject instance of the IDisplayRender, if found.
		 */
		protected function validateRendered(render:IDisplayRender, node:XML=null):DisplayObject {
			return render.rendered;
		}
		
		/**
		 * @private Used internally to keep track of render requests per node.
		 * @param	id		
		 * @param	node	
		 * @return	The IDisplayRender instance, if successfully found
		 */
		protected function getRenderById(id:String, node:XML=null):IDisplayRender {
			var retRender:IDisplayRender = _renderSrc.getRenderById(id);
			return retRender is IRenderPool ? (retRender as IRenderPool).object : retRender is IRenderFactory ? (retRender as IRenderFactory).createRender() :  retRender;
		}
		
		/**
		 * @private Used internally to keep track of render displayobject requests per node.
		 * @param	id		
		 * @param	render	The IDisplayRender to call getRenderedById		
		 * @param	node	
		 * @return	The IDisplayRender instance, if successfully rendered
		 */
		protected function getRenderedBy(id:String, render:IDisplayRender, node:XML=null):DisplayObject {
			return render.getRenderedById(id);
		}

		
		/** @private */
		protected function findTextField(disp:DisplayObject):TextField {
			return disp is ITextField ? (disp as ITextField).textField : disp as TextField;	
		}
		
		/** @private */
		protected function addToList(list:IList, node:XML, id:String):DisplayObject {
			
			// consider additional spans.
							var spans:XMLList = node.span;
							if (spans.length() > 0 ) {
								var disp:DisplayObject = node.p.length() > 0 ? list.addListItem( getInnerCopy(node.p[0].*), id) : list.addListItem("", id);
								var labler:ILabler = disp as ILabler;
								if (labler != null){
									setLabelsOf(labler, spans);
								}
								return disp;
							}
								
			var xmlList:XMLList = node.children();
			var copyStr:String = xmlList.length() > 0 ? getInnerCopy(xmlList) : node;
			return list.addListItem(copyStr, id);
			
		}
		
		/** @private */
		protected function addNestedChild(parentContext:DisplayObjectContainer, child:DisplayObject, render:IDisplayRender=null):void {
			parentContext.addChild(child); 
		}
		
			

		// -- Destructors
		
		/**
		 * Cleans up all hyperlinks
		 */
		public function destroy():void {
			
			// Clean up anchor hyperlinks	 
			var hash:Object = _anchors;
			var i:*;
			
			for (i in hash) {

				AncestorListener.removeEventListenerOf(i, MouseEvent.CLICK, hrefClickHandler)

				//TO factor out to seperate funciton in extened class
				/*var node:XML = hash[i];
				if (node["@class"] == "button") {
					var spr:Sprite =  i as Sprite;
					if (spr) spr.buttonMode = node.@restoreButtonMode == "true";
				}*/
				delete hash[i];
			}
		}
		
		
		
	}

}
