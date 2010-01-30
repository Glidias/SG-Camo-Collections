package sg.camo.behaviour {
	import flash.events.Event;
	import sg.camo.interfaces.IBehaviour;
	import flash.display.DisplayObject;
	import sg.camo.notifications.GDisplayNotifications;
	import flash.events.MouseEvent;
	import sg.camo.interfaces.ISelectable;

	/**
	* Hooks up a display object to dispatch GDisplayNotifications.SELECT bubbled notifications upon MouseEvent.CLICK 
	* (or some other event you wish to trigger a selection).
	* 
	* @see sg.camo.notifications.GDisplayNotifications
	* 
	* @author Glenn Ko
	*/
	public class SelectableBehaviour implements IBehaviour {
		
		public static const NAME:String = "SelectableBehaviour";
		
		/** @private */
		protected var _disp:DisplayObject;
		
		/** Borrowed from MouseEvent.CLICK **/
		public static const CLICK:String = MouseEvent.CLICK;
		/** Borrowed from MouseEvent.PRESS **/
		public static const PRESS:String = MouseEvent.MOUSE_DOWN;
		
		/**
		 * Supplies listener type prior to activating behaviour
		 */
		public var listenerType:String;
		
		/**
		 * Constructor
		 * @param	initListenerType	Defaulted to MouseEvent.CLICK. Supplies listener type to listen to prior to activating behaviour
		 */
		public function SelectableBehaviour(initListenerType:String = MouseEvent.CLICK) {
			listenerType = initListenerType;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates a DisplayObject to be able to dispatch GDisplayNotifications.SELECT event notifications
		 * @param	targ	A valid DisplayObject instance, prefably if it's ISelectable as well.
		 * @see sg.camo.interfaces.ISelectable
		 */
		public function activate(targ:*):void {
		
			if (!targ is ISelectable) {
				trace("SelectableBehaviour activate(). WARNING. targ is not ISelectable!");
			}
			var disp:DisplayObject = targ as DisplayObject;
			if (disp == null) {
				trace("SelectableBehaviour activate() halt. targ as DisplayObject is null!");
				return;
			}
			disp.addEventListener( listenerType, onSelectedHandler, false , 0, true);
			_disp = disp;
		}
		
		
		/**
		 * Dispatches a GDisplayNotifications.SELECT notification bubble.
		 * @param	e	(Event)
		 */
		protected function onSelectedHandler(e:Event):void {
			_disp.dispatchEvent ( new Event (GDisplayNotifications.SELECT, true) );
		}
		
		public function destroy():void {
			_disp.removeEventListener(listenerType, onSelectedHandler);
			_disp = null;
		}
		
	}
	
}