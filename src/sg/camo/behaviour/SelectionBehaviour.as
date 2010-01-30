package sg.camo.behaviour {
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.display.DisplayObject;
	import sg.camo.notifications.GDisplayNotifications;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.interfaces.ISelection;
	import flash.events.Event;
	import sg.camo.events.SelectionEvent;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	* Hooks up a DisplayObject (which is usually a Sprite container) to listen for GDisplayNotifications.SELECT
	* events and handles selections in a "single-selection" manner. Once the selection is handled,
	* it dispatches a SelectionEvent.SELECT event to notify that a selection has been made. 
	* 
	* @see sg.camo.notifications.GDisplayNotifications
	* @see sg.camo.events.SelectionEvent
	* 
	* @author Glenn Ko
	*/
	public class SelectionBehaviour implements IBehaviour, ISelection {
		
		public static const NAME:String = "SelectionBehaviour";
		/** @private */
		protected var _disp:DisplayObject;
		/** @private */
		protected var _curSelected:IEventDispatcher;
		
		/**
		 * Defaulted to True. Whether dispatched SelectionEvent.SELECT event is bubbling.
		 */
		public var bubbling:Boolean = true;
		
		/**
		 * Constructor
		 */
		public function SelectionBehaviour() {
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Performs single selection when received a GDisplayNotifications.SELECT event
		 * from specific target via <code>doSelection(targ:*)</code>.
		 * @param	e	(Event)
		 */
		protected function selectionHandler (e:Event):void {
			e.stopPropagation();
			 doSelection (e.target) 		
		}
		
		/**
		 * Activates DisplayObject to listen for GDisplayNotification.SELECT events
		 * @param	targ	A valid DisplayObject reference
		 */
		public function activate(targ:*):void {
			_disp = (targ as DisplayObject);
			if (_disp == null) {
				trace("SelectionBehaviour activate() halt. targ as DisplayObject is null!");
				return;
			}
			AncestorListener.addEventListenerOf(_disp, GDisplayNotifications.SELECT, selectionHandler, 1);
			//_disp.addEventListener (GDisplayNotifications.SELECT, selectionHandler, false, 1, true);
		}
		
		public function destroy():void {
			if (_disp != null) {
				AncestorListener.removeEventListenerOf(_disp, GDisplayNotifications.SELECT, selectionHandler);
				//_disp.removeEventListener(GDisplayNotifications.SELECT, selectionHandler);
				_disp = null;
			}
		}
		
		/** @private */
		protected function dispatchSelection(sel:*):void {
			_disp.dispatchEvent (new SelectionEvent(SelectionEvent.SELECT, sel, bubbling));
		}
		
		
	
		
		// -- ISelection
		/**
		 * Gets currently selected item (if any) in untyped format.
		 */
		public function get curSelected ():* {
			return _curSelected;
		}
		
		/**
		 * Clears current selection.
		 */
		public function clearSelection():void {
			if (_curSelected == null) return;
			if (_curSelected is ISelectable) (_curSelected as ISelectable).selected = false;
			_curSelected.dispatchEvent ( new Event(GDisplayNotifications.UNSELECTED) );
			_curSelected = null;
		}
		
		/**
		 * Class-specific public method to perform a selection directly on event target. 
		 * <br/>Also dispatches generic "selected"/"unselected" Events from the selected instances 
		*  that were changed as a result of a new selection.
		 *  <br/>Finally dispatches a SelectionEvent.SELECT event once successfully done.
		 * @param	targ	(Required) A DisplayObject or some valid IEventDispatcher target.<br/>
		 * (Recomended) A valid ISelectable instance. 
		 * @see sg.camo.interfaces.ISelectable
		 * @return	Whether selection was successful or not
		 */
		public function doSelection (targ:*):Boolean {
			if (!targ is IEventDispatcher) {
				trace("SelectionBehaviour doSelection() halt!  targ isn't IEventDispatcher or null");
				return false;
			}
			if (_curSelected!=null) {
				if (_curSelected is ISelectable) (_curSelected as ISelectable).selected = false
				_curSelected.dispatchEvent( new Event(GDisplayNotifications.UNSELECTED) );
			}
			
			var sel:ISelectable = targ as ISelectable;
			if (sel != null) sel.selected = true
			else trace ("Warning: SelectionBehaviour doSelection();  targ isn't ISelectable");
			_curSelected = targ as IEventDispatcher;
			_curSelected.dispatchEvent( new Event(GDisplayNotifications.SELECTED) );
			dispatchSelection(targ);
			return true;
		}
	}
	
}