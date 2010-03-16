package sg.camo.behaviour 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IPseudoBehaviour;
	
	/**
	 * Dynamic base class for pseudo event behaviours, which extends from Proxy to allow
	 * setting of any properties if required.
	 * 
	 * @author Glenn Ko
	 */
	public class AbstractEventBehaviour extends AbstractProxyBehaviour implements IPseudoBehaviour
	{
		
		protected var _listenEvent:String;
		protected var _targDispatcher:IEventDispatcher;
		
		
		[CamoInspectable(description = "Sets event string to listen to, in order to trigger action of behaviour", type="textEntry")]
		public function set pseudoState(str:String):void {
			listenEvent = str;	
		}
		
		[CamoInspectable(description = "Sets event string to listen to, in order to trigger action of behaviour", type="textEntry")]		
		/**
		 * IPseudoState implementation that sets listenEvent for this class
		 */
		public function set listenEvent(str:String):void {
			if (_targDispatcher != null && _listenEvent!=null) {
				_targDispatcher.removeEventListener(_listenEvent, listenEventHandler);
				_targDispatcher.addEventListener(str, listenEventHandler);
			}
			_listenEvent = str;
		}
		public function get listenEvent():String {
			return _listenEvent;
		}
		
		
		public function AbstractEventBehaviour(self:AbstractEventBehaviour, listenEvent:String=null) 
		{
			super(this);
			if (self != this) throw new Error("AbstractEventBehaviour cannot be instantiated directly!")
			_listenEvent = listenEvent;
		}
		
		override public function get behaviourName():String {
			throw new Error("AbstractEventBehaviour cannot have a behaviour name! Please override.");
		}
		
		
		
		override public function destroy():void {
			if (_targDispatcher) {
				if (_listenEvent) {
					_targDispatcher.removeEventListener(_listenEvent, listenEventHandler);
				}
			}
			_targDispatcher = null;
		}
		
		protected function listenEventHandler(e:Event):void {
			//  overwrite in extended classes to define specifics
		}
		
		
		/**
		 * This method can be overwritten to return a different target dispatcher to listen for the
		 * event.
		 * @param	targ	The currently activated target
		 * @return	The returned instance
		 */
		protected function getTargetDispatcherOf(targ:Object):IEventDispatcher {
			return targ as IEventDispatcher;
		}
		
		override public function activate(targ:*):void {
			_targDispatcher = getTargetDispatcherOf(targ);

			if (_targDispatcher == null) throw new Error("activate() Can't find target dispatcher for:"+behaviourName);	
			
			
			if (_listenEvent == null) {
				trace(behaviourName+":: No listen event supplied for:"+targ.name);
				return;
			}
			_targDispatcher.addEventListener(_listenEvent, listenEventHandler, false, 0, true);
			
		}
		

		
	}

}