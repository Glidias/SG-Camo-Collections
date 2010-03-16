package sg.camo.behaviour 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPseudoBehaviour;
	
	
	/**
	 * A base pseudo behaviour that listens to a specific event on a targetted displayobject,
	 * to apply a certain set of properties to the target through an injected IPropertyApplier implementation.
	 * 
	 * @author Glenn Ko
	 */
	public class StateBehaviour extends AbstractEventBehaviour 
	{
		
		public static const NAME:String = "StateBehaviour";
		

		protected var _applyTarget:Object;
		protected var _propApplier:IPropertyApplier;
		
		public var stopEvent:String; // temp
		public var restoreEvent:String; // temp  see hwo to handle this
		
		protected var _properties:Object = { };
		
		/**
		 * This flag can be set true prior to activate() to immediately apply given
		 * properties to target upon activation, making the target assume that state
		 * as the initial state. Therefore, StateBehaviour acts as a sub-property applier 
		 * in such a case.
		 */
		public var initialState:Boolean = false;
		
		
		[Inject]
		public function set propApplier(val:IPropertyApplier):void {
			_propApplier = val;
		}
		public function get propApplier():IPropertyApplier {
			return _propApplier;
		}
		
		[Inject(name="Proxy.properties")]
		public function setPropertiesClass(val:Class=null):void {
			if (val!=null) propertiesClass = val;
		}
		public function set propertiesClass(val:Class):void {
			_properties = new val();
		}

		
		/**
		 * 
		 * @param	listenEvent	 (Required) This can be set later through setter injection if you wish.
		 */
		public function StateBehaviour(listenEvent:String=null) 
		{
			super(this, listenEvent);
		}

		
		override public function get behaviourName():String {
			return NAME;
		}
		
		
		override public function activate(targ:*):void {
			_applyTarget = getApplyTargetOf(targ);
			super.activate(targ);
			
			
		
			if (_targDispatcher == null) throw new Error("activate() Can't find target dispatcher for:"+behaviourName);	
			
			if (initialState) applyInitialState();
			
		}
		
		protected function applyInitialState():void {
			if (_propApplier!=null) {
				_propApplier.applyProperties(_applyTarget, _properties);
			}
			else throw new Error("No property applier found to apply properties!");
		}
	
		
		/**
		 * This method can be overwritten to return a different target to apply
		 * properties to.
		 * @param	targ	The currently activated target
		 * @return	The returned instance
		 */
		protected function getApplyTargetOf(targ:Object):Object {
			return targ;
		}
		
		
		
		
		/** @private */
		
		override protected function listenEventHandler(e:Event):void {
			if (stopEvent) {
				_targDispatcher.addEventListener(stopEvent, stopEventHandler, false , 1, true);
				if (restoreEvent) _targDispatcher.addEventListener(restoreEvent, restoreEventHandler, false, 1, true);
			}
		
			_propApplier.applyProperties(_applyTarget, _properties);
			
		}
		
		private function stopEventHandler(e:Event):void {
			e.stopImmediatePropagation();
			
		}
		private function restoreEventHandler(e:Event):void {
			_targDispatcher.removeEventListener(stopEvent, stopEventHandler);
			_targDispatcher.removeEventListener(restoreEvent, restoreEventHandler);
		}
		
		override public function destroy():void {
			if (_targDispatcher) {
				if (stopEvent) _targDispatcher.removeEventListener(stopEvent, stopEventHandler);
				if (restoreEvent) _targDispatcher.removeEventListener(restoreEvent, restoreEventHandler);
			}
			super.destroy();
			_applyTarget = null;
		}
		
		// Proxy
		
		override protected function $deleteProperty(name : *) : Boolean
		{
			return delete _properties[name];
		}


		override protected function $getProperty(name : *) : *
		{
			return _properties[name];
		}



		override protected function $setProperty(name : *, value : *) : void
		{ 
			_properties[name] = value;
		}
		
	
	}

}