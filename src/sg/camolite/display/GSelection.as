package sg.camolite.display
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.notifications.GDisplayNotifications;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.events.SelectionEvent;
	import sg.camo.interfaces.ISelectioner;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.ISelectionScanner;
	
	import flash.display.DisplayObject;
	
	import flash.display.Sprite;
	
	/**
	 * Selection display-based class that handles and perform single selections similar to
	 * <code>SelectionBehaviour</code>.
	 * <br/>Also includes other functionalities to execute selections by string id through 
	 * extended <code>ISelectioner</code> interface.
	 * <br/>It also has <code>ISelectionScanner</code> functionality.
	 * 
	 * @see sg.camo.behaviour.SelectionBehaviour
	 * 
	 * @author Glenn Ko
	 */
	public class GSelection extends GBase implements ISelectioner, IDestroyable, ISelectionScanner
	{
		/** @private  TODO */
		public var defaultSelected:String = ""; // flag to automatically select a sub/content id ISelectable item by default 
		
		
		public var autoSelect:Boolean = true;   // flag to determine if selection is done automatically by the class itself
		public var bubbling:Boolean = true;	// whether dispatched selectionEvent is bubbling or not
		
		/** @private */
		protected var _curSelected:IEventDispatcher;
		
		/**
		 * Current data hash of scanned selectables (if any)
		 */
		protected var data:Object = { }; 

		public function GSelection() 
		{	
			super();
			addEventListener (GDisplayNotifications.SELECT, selectionHandler, false, 1, true);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GSelection;
		}
		
		/**
		 * ISelectionScanner method to MANUALLY scan a display list for ISelectables, which are registered to the data hash.
		 * @param	targ	A target Sprite container to run the scan on, calling processSelectableChild() on any found ISelectable instances.
		 * 
		 * @see sg.camo.interfaces.ISelectable
		 */
		public function scan(targ:Sprite):void {
			var total:int = targ.numChildren;
			for (var i:int=0; i<total; i++) {
				var child:DisplayObject = targ.getChildAt(i);
				if (!(child is ISelectable)) continue;
				processSelectableChild(child);
			}
		}
		
		public function clearSelection():void {
			if (_curSelected == null) return;
			if (_curSelected is ISelectable) (_curSelected as ISelectable).selected = false;
			_curSelected.dispatchEvent ( new Event(GDisplayNotifications.UNSELECTED) );
			_curSelected = null;
		}
		
		/**
		 * Registers scanned ISelectable child to data hash. By default,
		 * uses the child's name as the key to the data hash.
		 * @param	child
		 */
		protected function processSelectableChild(child:DisplayObject):void {
			data[child.name] = child;
		}
		

		
		public function destroy():void {
			data = null;
			removeEventListener(GDisplayNotifications.SELECT, selectionHandler);
		}
		
		
		// -- Selection handlers/methods
		
		
		/** @private */
		protected function selectionHandler (e:Event):void {
			if (autoSelect) doSelection (e.target) 		 // do first than dispatch notification
			else dispatchSelection(e.target);  // dispatch notification only
		}
		
		/** @private */
		protected function dispatchSelection(sel:*):void {
			dispatchEvent (new SelectionEvent(SelectionEvent.SELECT, sel, bubbling));
		}
		
		// manual remote runtime public setter based on subId/contentId string
		public function set selection(str:String):void {
			if (str == null) {
				clearSelection();
				return;
			}
			var chk:* = data[str];
			if (chk == null) chk = getChildByName(str);
			doSelection(chk);
		}
		
		
		public function get curSelected ():* {
			return _curSelected;
		}
		
		
		public function doSelection (targ:*):Boolean {
			if (!targ is IEventDispatcher) {
				trace("GSelection doSelection() halt!  targ isn't IEventDispatcher or null!");
				return false;
			}
			if (_curSelected!=null) {
				if (_curSelected is ISelectable) (_curSelected as ISelectable).selected = false
				_curSelected.dispatchEvent( new Event(GDisplayNotifications.UNSELECTED) );
			}
			
			var sel:ISelectable = targ as ISelectable;
			if (sel != null) sel.selected = true
			else trace ("Warning: GSelection doSelection();  targ isn't ISelectable");
			_curSelected = targ as IEventDispatcher;
			_curSelected.dispatchEvent( new Event(GDisplayNotifications.SELECTED) );
			dispatchSelection(targ);
			return true;
		}

		
		
	}
	
}