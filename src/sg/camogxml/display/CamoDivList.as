﻿package sg.camogxml.display 
{
	import camo.core.events.CamoChildEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IText;
	import sg.camo.notifications.GDisplayNotifications;
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
		public var dividerRender:IDisplayRender;
		
		/** Concrete Displayobject class to use by default for rendering list items */
		public var listItemClass:Class;
		
		/** If render src is provided, will attempt to render list items through IDisplayRenderSource 
		 * with assosiated id.  */
		[Inject(name='gxml')] 
		public var listItemRender:IDisplayRender;
		
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
			return  listItemRender ? listItemRender.rendered : listItemClass ? new listItemClass() as DisplayObject : null;
		}
		protected function getDividerItem():DisplayObject {
			return  dividerRender ? dividerRender.rendered  : dividerClass ? new dividerClass() as DisplayObject : null;
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
			dispatchEvent( new CamoChildEvent(GDisplayNotifications.ADD_LIST_ITEM, listItem) );
			_length++;
			return listItem;
		}
		

		public function removeListItem (id:String):DisplayObject {
			var listItem:DisplayObject = _listHash[id];
		
			if (listItem) {
				delete _listHash[id];
				dispatchEvent( new CamoChildEvent(GDisplayNotifications.REMOVE_LIST_ITEM, listItem) );
				removeChildFromDisplayList(listItem, id);
				_length--;
			}
			
			return listItem;
		}
		
		override public function destroy():void {
			super.destroy();
			_listHash = null;
			dividerClass = null;
			listItemClass = null;
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