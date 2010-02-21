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
		
		/**
		 * Sets custom click event to dispatch when a click occurs on target dispatcher
		 */
		public var clickEvent:Event;
		
		public static const NAME:String = "ClickEventBehaviour";
		
		/**
		 * Flag to determine whether <code>genericEvent</code> setter's native Flash Event
		 * is bubbling.
		 */
		public var genericBubbles:Boolean = true;
	
		/**
		 * Constructor
		 * @param	clickEvent	An event to dispatch when the targetted display object instance is clicked.
		 */
		public function ClickEventBehaviour(clickEvent:Event=null) {
			this.clickEvent = clickEvent;
		}
		

		/**
		 * Sets up a native Flash Event for the click event.
		 */
		public function set genericEvent(type:String):void {
			clickEvent = new Event(type, genericBubbles);
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
			if (clickEvent == null) return;
			_targDispatcher.dispatchEvent( clickEvent );
		}
		
		public function destroy():void {
			if (_targDispatcher == null) return;
			AncestorListener.removeEventListenerOf(_targDispatcher, MouseEvent.CLICK, clickHandler);
			_targDispatcher = null;
		}
		
		
		
	}
	
}