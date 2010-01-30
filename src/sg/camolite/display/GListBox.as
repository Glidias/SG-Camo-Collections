package sg.camolite.display {
	import camo.core.events.CamoChildEvent;
	import flash.text.TextField;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.ISelection;
	import sg.camo.interfaces.ITextField;
	import sg.camo.notifications.GDisplayNotifications;
	import sg.camo.scrollables.SnapScrollProxy;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.behaviour.SelectionBehaviour;
	import sg.camo.behaviour.SkinBehaviour;
	import sg.camo.behaviour.VLayoutBehaviour;
	import sg.camo.behaviour.HLayoutBehaviour;
	import sg.camo.behaviour.SelectableBehaviour;
	import sg.camo.interfaces.ISelectioner;

	
	/**
	* A standard list box implementation (similar to <code>GListDisplay</code>) that layouts vertically (by default) and supports scrolling.
	* 
	* @see sg.camolite.display.GListDisplay
	* 
	* @author Glenn Ko
	*/
	public class GListBox extends GScrollContainer implements IList, ISelectioner, ISelection {
		
		/** @private */
		protected var _listItem:Sprite;
		/** @private */
		protected var _listItemClass:Class;
		
		/**
		 * The hash of registered DisplayObject items by id.
		 */
		protected var _idHash:Dictionary = new Dictionary();
		
		/** @private */
		protected var _maxItemLength:Number = 5;

		
		/**
		 * The composed SelectionBehaviour in the list box.
		 */
		protected var _selBehaviour:SelectionBehaviour;
		
		/** @private */
		protected var _isHorizontal:Boolean; 

		/**
		 * Sets up default settings for list box. <br/>
		 * If <b>only</b> a horizontal scrollbar is found, a horizontal layout is created, else it creates
		 * a vertical layout.
		 * @param	customDisp
		 */
		public function GListBox(customDisp:Sprite = null) {
			
			
			super(customDisp);
	
			iScroll = new SnapScrollProxy(this);
			overflow = "auto";
			_isHorizontal = _scrollBarH != null && _scrollBarV == null;
			var layoutBeh:IBehaviour = _isHorizontal ? new HLayoutBehaviour() : new VLayoutBehaviour();
			addBehaviour(layoutBeh);
			_selBehaviour = new SelectionBehaviour();
			addBehaviour( _selBehaviour );
			
			if (_listItem != null) {
				if ($contains(_listItem)) $removeChild(_listItem); 
				_itemLength = _isHorizontal ? _listItem.width :  _listItem.height;
				_listItem = null;
			}
			

		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GListBox;
		}
		
		
		public function clearSelection():void {
			_selBehaviour.clearSelection();
		}

		
		public function set selection(str:String):void {
			_selBehaviour.doSelection( _idHash[str] );
		}
	
	
		
		public function get curSelected ():* {
			return _selBehaviour.curSelected;
		}
		

		
		override public function destroy():void {
			super.destroy();
			_selBehaviour = null;
			if (_skinBehaviour != null) {
				_skinBehaviour.destroy();
				_skinBehaviour = null;
			}
		}
		
		protected function capLength(val:Number):Number {
			
			var max:Number = maxItemLength * _itemLength;
			return  val < max ?  val : max;
		}
		
		// To also try and support below skinBehaviour impl.....
		override public function get width():Number {
			return display != null ? _skinBehaviour != null ? _isHorizontal ? capLength(display.width):super.width : super.width : super.width;
		}
		
		override public function get height():Number {
			return display != null ? _skinBehaviour != null ? !_isHorizontal? capLength(display.height):super.height : super.height : super.height;
		}
		
		/** @private */
		protected var _skinBehaviour:IBehaviour;
		/**
		 * @private This still needs some testing to be more robust. 
		 * Sets up skin to resize together with current no. of items and visible max item count.
		 */
		public function set skin(disp:DisplayObject):void {
			_skinBehaviour = new SkinBehaviour(disp);
			_skinBehaviour.activate(this);
		}
		/**
		 * @private This still needs some testing to be more robust.
		 */
		public function set maskSkin(targ:DisplayObject):void {
			_scrollMask = targ;
			display = getDisplaySprite();
			display.mask = targ;
			addBehaviour(new SkinBehaviour(targ) );
		}
		/**
		 * Visible Max item count
		 * @private
		 */
		public function set maxItemLength(val:Number):void {
			_maxItemLength = int(val);
		}
		/**
		 * @private
		 */
		public function get maxItemLength():Number {
			return _maxItemLength;
		}
		
		
		
		override public function resize(w:Number,h:Number):void {
			super.resize(w, h);
			if (_scrollMask!=null) {
				_scrollMask.width = _width;
				_scrollMask.height = h;
			}
		}
		
		/**
		 * Usually a <b>[Stage instance]</b> to set sample list item.
		 */
		public function set listItem(spr:Sprite):void {
			_listItem = spr;
			_listItemClass = Object(spr).constructor as Class;
		
		}
		
		/**
		 * @private
		 */
		protected function updateItemLengthSize():void {
			var len:int = numChildren < _maxItemLength ?  numChildren : _maxItemLength;
		}
		
		/**
		 * @private Retrieves id of item,
		 * @param	disp
		 * @return
		 */
		protected function getIdOfItem(disp:DisplayObject):String {
			return disp is IListItem ? (disp as IListItem).id : _idHash[disp];
		}

		// IList impl
		
		public function addListItem(label:String, id:String):DisplayObject {
			var disp:DisplayObject = new _listItemClass() as DisplayObject;
			if (!disp is ISelectable) addDisplayBehaviourTo( new SelectableBehaviour(), disp );
			

			
			var success:DisplayObject = addChild(disp);
			if (!success) {
				trace("Warning, GListBox:: addListItem()  Unsuccessful adding of child to display list");
				return null;
			}
			if (id != null) {
				_idHash[disp] = id;
				_idHash[id] = disp;
				//trace("adding id:"+id);
			}

			
			if (disp is IText) (disp as IText).text = label
			else if (disp is ITextField) (disp as ITextField).textField.text = label
			else if (disp is TextField) (disp as TextField).text = label;
			
			if (disp is IListItem)  (disp as IListItem).id = id;
			if (disp is IIndexable) (disp as IIndexable).setIndex( disp.parent.getChildIndex(disp) );
			
			updateItemLengthSize();
			dispatchEvent ( new CamoChildEvent(GDisplayNotifications.ADD_LIST_ITEM, disp) );
			return success;
		}
		
		

		
		
		public function removeListItem(id:String):DisplayObject {
			var child:DisplayObject = (_idHash[id]);
			if (child == null) {
				trace("GListBox removeListItem():: No child found for id:" + id);
				return null;
			}
			if (!(child is ISelectable) ) removeDisplayBehaviourOf( SelectableBehaviour.NAME, child );
			
			if (child is IDestroyable) (child as IDestroyable).destroy();
			var success:Boolean = contains(child);
			if (success) {
				removeChild(child);  
			}
			
			delete _idHash[_idHash[child]]
			delete _idHash[child];
			if (success) dispatchEvent ( new CamoChildEvent(GDisplayNotifications.REMOVE_LIST_ITEM, child) );
			return success ? child : null;
		}
		
		
		
		
		
	}
	
}