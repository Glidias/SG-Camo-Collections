package sg.camolite.display {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.TextEvent;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IIterarable;
	import sg.camo.interfaces.IPageDisplay;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.notifications.GDisplayNotifications;
	import flash.text.TextField;

	/**
	* Standard paging display typically used for tab-viewing control.
	* @author Glenn Ko
	*/
	public class GPageDisplay extends GBaseDisplay implements IPageDisplay, IIndexable, IIterarable {
		
		/** The page array list */ 
		protected var _pageArr:Array = [];
		/** Array of page title (if any) for each page in the array */
		protected var _pageTitles:Array;
		
		/** @private */ protected var _size:int = 0;
		/** @private */ protected var _curPageIndex:int = 0;
		/** @private */ protected var _pageContainer:DisplayObjectContainer;	
		/** @private */ protected var _paged:Boolean = false;
		/** @private */ protected var _pageTitleField:TextField;
		/** @private */ protected var _curPageHash:Dictionary;
		/** @private */ protected var _visHash:Dictionary = new Dictionary();
	
		/**
		 * Constructor.
		 */
		public function GPageDisplay() {
			_pageContainer = this;
			if (!_paged) $addEventListener(Event.ADDED_TO_STAGE, onAddedToStagePages, false , 0, true);
			
			$addEventListener(TextEvent.LINK, hrefHandler, false , 0, true);
			
			super();
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GPageDisplay;
		}
		
		/**
		 * GPageDisplay also handles TextEvent.LINK bubbling events whose <code>"text"</code> property is 
		 * is set to to "next" or "prev". When GPageDisplay detects these "href values", 
		 * the class will automatically interrupt this TextEvent from propagating further
		 * and proceed to the next or previous page respectively.
		 * @param	e
		 */
		protected function hrefHandler(e:TextEvent):void {
			var texter:String = e.text;
			if (texter === "next") {
				nextPage();
				e.stopPropagation();
			}
			else if (texter === "prev") {
				prevPage();
				e.stopPropagation();
			}
		}
		
		/**
		 * Gets current page index
		 * @return	The current page index
		 */
		public function getIndex():int {
			return _curPageIndex;
		}
		/**
		 * Goes to page based on supplied index
		 * @param	pg	The page index to supply.
		 */
		public function setIndex(pg:int):void {
			gotoPage(pg);
		}
		
		/**
		 * When the GPageDisplay is added to the stage, it attempts to load the "first" page being
		 * registered, and sets all other registered paged display objects to be invisible.
		 * @param	e
		 */
		protected function onAddedToStagePages(e:Event):void {
			$removeEventListener(Event.ADDED_TO_STAGE, onAddedToStagePages, false);
			for (var i:String in _pageArr) {
				if (_curPageIndex == Number(i) ) continue;
			//	if (_curPageName
				var dict:Dictionary = _pageArr[i];
				for (var d:* in dict) {
					var disp:DisplayObject = d;
					if (_visHash[disp]) {
						disp.visible = false;
						continue;
					}
					if (disp.parent === this) {
						$removeChild(disp)  
					}
					else if (disp.parent != null) {
						disp.parent.removeChild(disp);	// should check .parent as IAncestorSprite else use removeChild instead of $
					}
				}
			}
			updatePageTitle();
			
			_paged = true;
			
			gotoPage(_curPageIndex);
		}
		
		/**
		 * Updates page title automatically if a staged <code>txtPageTitle</code> field is set.
		 */
		protected function updatePageTitle():void {
			if (_pageTitleField != null) {
				var str:String = _pageTitles[_curPageIndex];
				_pageTitleField.text = str;
				_pageTitleField.visible = str != "";
			}
		}
		
		// IIteratable impl
		
		/**
		 * Goes to next page
		 */
		public function goNext():void {
			nextPage();
		}
		
		/**
		 * Goes to previous page
		 */
		public function goPrev():void {
			prevPage();
		}
		

		// IPaging impl
		
		/**
		 * Key method to go to a particular page by index
		 * @param	index	The page index to travel to
		 * @return	(Boolean) Whether page switch was successful.
		 */
		public function gotoPage(index:int):Boolean {
			if (index <0 || index > _pageArr.length - 1) return false;
			
			var dict:Dictionary = _pageArr[index];
			if (_curPageHash === dict) return false;
			
			openDict(dict);
			_curPageIndex = index;
			updatePageTitle();
			dispatchEvent( new Event(GDisplayNotifications.PAGE_CHANGE, true) );
			return true;
		}
		/**
		 * Goes to a page by registered string id
		 * @param	str	   The registered string id of the page
		 * @return	(Boolean) Whether page switch was successful.
		 */
		public function gotoPageByString(str:String):Boolean {
			//if (!_pageTitles[str]) return false;
			trace(_pageArr);
			var chkNum:Number = Number(str);
			var dict:Dictionary = _pageArr[str];
			if (_curPageHash === dict) return false;
			if ( !isNaN(chkNum) ) {
				_curPageIndex = chkNum;
			}
			openDict(dict);
			updatePageTitle();
			dispatchEvent( new Event(GDisplayNotifications.PAGE_CHANGE, true) );
			return true;
		}
		
		public function nextPage():Boolean {
			return gotoPage( _curPageIndex + 1);
		}
		public function prevPage():Boolean {
			return gotoPage( _curPageIndex -1);	
		}
		
		protected function openDict(dict:Dictionary):void {
			if (!_paged) {
				trace("GPageDisplay:: openDict() note: Item isn't added to stage yet, cannot page items");
			}
			var disp:DisplayObject;
			//trace("Opening");
			if (_curPageHash != null) {
				for (var i:* in _curPageHash) {
					disp = i;
					if (_visHash[disp]) {
						disp.visible = false;
				//	trace("setting vis only false");
						continue;
					}
					_pageContainer.removeChild(disp);
				}
			}
			_curPageHash = dict;
			for (i in _curPageHash) {
				disp = i;
				if (_visHash[disp]) {
					
					disp.visible = true;
					if (disp.parent == null) $addChild(disp);  // assert vis
		
					continue;
				}
				_pageContainer.addChild(disp);
			}
		}

		// IPageDisplay
		
		/**
		 * Optional <b>[Stage Instance]</b> to set up page title text-field, which automatically updates on every page change.
		 */
		public function set txtPageTitle(txtField:TextField):void {
			_pageTitleField = txtField;
		}
		
		/**
		 * Registers display object into the current page array list.
		 * @param	disp	The display object reference
		 * @param	index	The page index to register to (if value supplied is zero or higher), 
		 * 					otherwise pushes the display object to the end of the page array list.
		 * @param	visOnly	 Whether page switching uses only visibility-switching instead of adding/removing children from the display
		 */
		public function addToPage(disp:DisplayObject, index:int = -1, visOnly:Boolean = false):void {
			if (index < 0) {
				_pageArr.push( new Dictionary() );
				index = _pageArr.length -1;
				
			}
			_pageArr[index][disp] = true;	
			if (visOnly) _visHash[disp] = true;		
		}
		/**
		 * Registers display object as assosiative string id (of a page) to the page array. 
		 * @param	disp		The display object reference to add to the page array assosiative string id entry.
		 * @param	strName		The string page id to use (if no such id is found in the page array, a new page entry is created)
		 * @param	visOnly   Whether page switching uses only visibility-switching instead of adding/removing children from the display
		 */
		public function addToPageName(disp:DisplayObject, strName:String, visOnly:Boolean=false):void {
			if (_pageArr[strName] == null) _pageArr[strName] = new Dictionary();
			_pageArr[strName][disp] = true;	
			if (visOnly) _visHash[disp] = true;		
			
		}
		
		/**
		 * Sets up a bunch of page titles into the page title array list.
		 * @param	...args
		 */
		public function setPageTitles(...args):void {
			for (var i:int = 0; i < args.length; i++) {
				_pageTitles[i] = args[i];
			}
		}
		
		/**
		 * Initialises page array (including page title array) with the number of slots
		 * (ie. size) supplied in the value.
		 */
		public function set initNumPages(num:int):void {
			_size = num;
			_pageArr = new Array(num);
			var i:int = num;
			while(--i > -1) {
				_pageArr[i] = new Dictionary();
			}
			_pageTitles = new Array(num);
			i = num;
			while(--i > -1) {
				_pageTitles[i] = "";
			}
		}
		
		
		
		override public function destroy():void {
			super.destroy();
			destroyPages();
			if (!_paged) $removeEventListener(Event.ADDED_TO_STAGE, onAddedToStagePages);
			$removeEventListener(TextEvent.LINK, hrefHandler);
		}
		

		/**
		 * @private
		 */
		protected function destroyPages():void {
			for (var i:String in _pageArr) {
				var dict:Dictionary = _pageArr[i];
				for (var key:* in dict) {
					if (key is IDestroyable) (key as IDestroyable).destroy();
					delete dict[key];
				}
			}
			_visHash = null;
			_pageTitles = null;
			_pageArr = null;
			_visHash = null;
		}
		
		
	}
	
}