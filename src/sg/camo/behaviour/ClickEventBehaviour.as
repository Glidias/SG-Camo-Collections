package sg.camo.behaviour {
	import flash.display.Sprite;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	* Hooks up DisplayObject with buttonMode behaviour to dispatch your own custom event upon click.
	* @author Glenn Ko
	*/
	public class ClickEventBehaviour implements IBehaviour {
		
		/** @private */
		protected var _targDispatcher:IEventDispatcher;
		/** @private */
		protected var _clickEvent:Event;
		
		public static const NAME:String = "ClickEventBehaviour";
		
		public var genericBubbles:Boolean = true;
	
		/**
		 * Constructor
		 * @param	clickEvent	An event to dispatch when the targetted display object instance is clicked.
		 */
		public function ClickEventBehaviour(clickEvent:Event=null) {
			_clickEvent = clickEvent;
		}
		
		/**
		 * Public setter to set or change click event.
		 */
		public function set clickEvent(e:Event):void {
			_clickEvent = e;
		}
		public function get clickEvent():Event {
			return _clickEvent;
		}
		
		public function set genericEvent(type:String):void {
			_clickEvent = new Event(type, genericBubbles);
		}
		
		
		// -- IBehaviour
		
		public function get behaviourName():String {
			return NAME;
		}
		/**
		 * Activates DisplayObject instance.
		 * @param	targ	A DisplayObject instance
		 */
		public function activate(targ:*):void {
			_targDispatcher = (targ as IEventDispatcher);
			if (_targDispatcher == null) {
				trace("ClickBehaviour activate() halt. targ as IEventDispatcher is null!");
				return;
			}
			AncestorListener.addEventListenerOf(_targDispatcher, MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Dispatches custom clickEvent on MouseEvent.CLICK
		 * @param	e	(Event)
		 */
		protected function clickHandler(e:Event):void {
			if (_clickEvent == null) return;
			_targDispatcher.dispatchEvent( _clickEvent );
		}
		
		public function destroy():void {
			AncestorListener.removeEventListenerOf(_targDispatcher, MouseEvent.CLICK, clickHandler);
			_targDispatcher = null;
		}
		
		
		
	}
	
}