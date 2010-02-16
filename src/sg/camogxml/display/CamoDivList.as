package sg.camogxml.display 
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IText;
	/**
	 * CamoDiv that implements IList interface and supports various list item/divider rendering methods.
	 * @author Glenn Ko
	 */
	public class CamoDivList extends CamoDiv implements IList
	{
		
		/** Concrete Displayobject class to use by default for rendering dividers */
		public var dividerClass:Class;
		
		/** If render src is provided, will attempt to render dividers through IDisplayRenderSource 
		 * with assosiated id. */
		[Inject(name='gxml')] 
		public var dividerRenderSrc:IDisplayRenderSource;
		public var dividerRenderId:String = "NO ID SPECIFIED";
		
		/** Concrete Displayobject class to use by default for rendering list items */
		public var listItemClass:Class;
		
		/** If render src is provided, will attempt to render list items through IDisplayRenderSource 
		 * with assosiated id.  */
		[Inject(name='gxml')] 
		public var listItemRenderSrc:IDisplayRenderSource;
		public var listItemRenderId:String = "NO ID SPECIFIED";
		
		/** @private */
		protected var _listHash:Dictionary = new Dictionary();
		/** @private */
		protected var _length:int = 0;
		
		
		public function CamoDivList() 
		{
			super();
		}
		
		override public function get reflectClass():Class {
			return CamoDivList;
		}
		
		public function get length():int {
			return _length;
		}
		
		/**
		 * Stage instance or generic setter to use for sampling a list item class
		 * for rendering by default. (Stage instance must have linkage id.)
		 */
		public function set listItem(disp:DisplayObject):void {
			listItemClass  = Object(disp).constructor as Class;
			if (disp.parent===this) disp.visible = false;
		}
		/**
		 * Stage instance or generic setter to use for sampling a divider class
		 * for rendering by default. (Stage instance must have linkage id.)
		 */
		public function set divider(disp:DisplayObject):void {
			dividerClass  = Object(disp).constructor as Class;
			if (disp.parent === this) disp.visible = false;
		}
		
		/** @private */
		protected function getListItem():DisplayObject {
			return  listItemRenderSrc ? getRenderedFrom(listItemRenderSrc,listItemRenderId,listItemClass)  : listItemClass ? new listItemClass() as DisplayObject : null;
		}
		protected function getDividerItem():DisplayObject {
			return  dividerRenderSrc ? getRenderedFrom(dividerRenderSrc,dividerRenderId,dividerClass)  : dividerClass ? new dividerClass() as DisplayObject : null;
		}
		
		/** @private */
		protected static function getRenderedFrom(renderSrc:IDisplayRenderSource, id:String, defaultClass:Class=null):DisplayObject {
			var findRender:IDisplayRender = renderSrc.getRenderById(id);
			if (findRender == null) {
				trace( new Error("CamoDivList find display render failed for:" + id) );
				return defaultClass ? new defaultClass() as DisplayObject  : null; // revert to default if available
			}
			var retDisp:DisplayObject = findRender.rendered;
			if (retDisp == null) {
				trace( new Error("CamoDivList can't find rendered display object for render:" + id) );
				return defaultClass ? new defaultClass() as DisplayObject  : null;// revert to default if available
			}
			
			return retDisp;
		}
		
		public function addListItem (label:String, id:String):DisplayObject {
			var listItem:DisplayObject = getListItem();
			if (listItem == null) {
				throw new Error("CamoDivList getListItem() retrieval failed!");
			}
			_listHash[id] = listItem;
			if (_length > 0) {  // prepend divider  if available
				var dividerItem:DisplayObject = getDividerItem();
				if (dividerItem) addDivider(dividerItem);
			}
			addChildToDisplayList(listItem, label, id);
			_length++;
			return listItem;
		}
		

		public function removeListItem (id:String):DisplayObject {
			var listItem:DisplayObject = _listHash[id];
			if (listItem) {
				delete _listHash[id];
				removeChildFromDisplayList(listItem, id);
				_length--;
			}
			return listItem;
		}
		
		override public function destroy():void {
			super.destroy();
			_listHash = null;
			dividerClass = null;
			dividerRenderSrc = null;
			listItemClass = null;
			listItemRenderSrc = null;
		}
				
		override public function contains(child:DisplayObject):Boolean {
			return child.parent === display;
		}
		
		/** @private */
		protected function addDivider(disp:DisplayObject):void {
			addChild(disp);
		}
		
		/** @private */
		protected function addChildToDisplayList(disp:DisplayObject, label:String, id:String):void {
			if (disp is IText) (disp as IText).text = label;
			if (disp is IListItem) (disp as IListItem).id  = id;
			addChild(disp);
			if (disp is IIndexable) (disp as IIndexable).setIndex(  getChildIndex(disp)  ) 
		}
		
		/** @private */		
		protected function removeChildFromDisplayList(disp:DisplayObject, id:String):void {
			if (disp is IDestroyable) (disp as IDestroyable).destroy();
			removeChild(disp);
		}
		
	}

}