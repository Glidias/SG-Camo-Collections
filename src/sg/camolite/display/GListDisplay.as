package sg.camolite.display {
	import camo.core.events.CamoChildEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IList;
	import flash.events.Event;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IText;
	import sg.camo.notifications.GDisplayNotifications;
	
	/**
	* Base class display implementing IList that allows adding of list items and assosiating an id with the item.
	* <br/><br/>
	* Note that this class doesn't prescribe any layout behaviours and such. You have to compose such behaviour into extended classes.
	* <br/><br/>
	* To get this to work, you must supply a sample <code>listItem</code> DisplayObject reference or <code>listItemClass</code>
	* Class reference, from which items can be generated from that reference. 
	* Note that the <code>listItem</code> reference must have a linkaged class definition assosiated with it for it to work.
	* <br/><br/>
	* The use of the <code>IListItem</code> interface for generated list items is entirely optional (since the class already stores
	* there's already an internal hash relating each generated list item to an id accordingly. ). However, if the generated listItem
	* happens to implement the <code>IListItem</code> interface, the id is set for that item class as well.
	* 
	* @see sg.camo.interfaces.IListItem
	* 
	* @author Glenn Ko
	*/
	public class GListDisplay extends GBaseDisplay implements IList {
		
		protected var _idHash:Object = { };
		protected var _targHash:Dictionary = new Dictionary(true);


		protected var _listItemClass:Class  = Sprite;
		
		public function GListDisplay(customDisp:Sprite=null) {
			super(customDisp);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GListDisplay;
		}
		
		/**
		 * The list item class reference.
		 */
		public function set listItemClass(classe:Class):void {
			_listItemClass = classe;
		}
		public function get listItemClass():Class {
			return _listItemClass;
		}
		
		/**
		 * Usually a <b>[Stage instance]</b> to set sample list item.
		 */
		public function set listItem(disp:DisplayObject):void {
			listItemClass = Object(disp).constructor as Class;
			disp.visible = false;
		}
		

		
		
		public function addListItem (label:String, id:String):DisplayObject {
			var disp:DisplayObject = new listItemClass() as DisplayObject;
			if (disp == null) {
				trace("GListDisplay addListItem() halted. new listItemClass() is not a displayObject or null!");
				return null;
			}
			addChildToDisplayList(disp, label, id);
			_idHash[id] = disp;
			_targHash[disp] = id;
			dispatchEvent ( new CamoChildEvent(GDisplayNotifications.ADD_LIST_ITEM, disp) );
			return disp;
		}
		public function removeListItem (id:String):DisplayObject {
			var disp:DisplayObject = _idHash[id] as DisplayObject;
			var valid:Boolean = contains(disp);
			if (valid) removeChildFromDisplayList(disp,  id);
			delete _idHash[id];
			delete _targHash[disp];
			if (valid) dispatchEvent ( new CamoChildEvent(GDisplayNotifications.REMOVE_LIST_ITEM, disp) );
			return valid ? disp : null;
		}
		
		override public function contains(child:DisplayObject):Boolean {
			return child.parent === display;
		}
		
		/** @private */
		protected function getIdOfItem(disp:DisplayObject):String {
			return disp is IListItem ? (disp as IListItem).id : _targHash[disp];
		}
		
		public function getItemById(id:String):DisplayObject {
			return _idHash[id];
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
		
		override public function destroy():void {
			super.destroy();
			_idHash = null;

			var des:IDestroyable;
			for (var i:* in _targHash) {
				if ( (des=i as IDestroyable) ) des.destroy();
			}
			_targHash = null;

		}
		
	}
	
}