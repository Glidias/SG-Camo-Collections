package sg.camoextras.services 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import sg.camo.events.TransitionModuleEvent;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.ITransitionModule;
	import sg.camogxml.api.IBinder;
	/**
	 * A proxy that allows setting of watched properties over a target instance only when
	 * a target has finished tweening out it's transition payload. After a transition out
	 * payload is finished, properties are than set thereafter and it will attempt to re-tween the target back in.
	 * This allows you to bind target properties to model data/vos but only apply the changes only
	 * such targets have fully transitioned out.
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject(name="gxml",name="gxml")]
	public class TransitionBindingService extends Proxy 
	{
		private var _binder:IBinder;
		private var _target:*;
		public var toSetTarget:*;
		
	
		private var _watchedProps:Dictionary = new Dictionary();
		private var _toSetProperties:Object = { };
		private var _watchCount:int = 0;
		private var _totalWatchCount:int = 0;
		private var _isWatching:Boolean = false;
		
		private var _transModule:ITransitionModule;
		private var _displayRender:IDisplayRender;
		
	
		public function TransitionBindingService(binder:IBinder, displayRender:IDisplayRender=null) 
		{
			_binder = binder;
			_displayRender = displayRender;
		}
		
		public function set target(targ:IEventDispatcher):void {
			if (targ == null) return;
		
			_target = targ;
			toSetTarget = targ;
			var req:TransitionModuleEvent = new TransitionModuleEvent(TransitionModuleEvent.REQUEST);
			targ.dispatchEvent(req  );
			_transModule = req.transitionModule;
		}
		

		public function set targetId(id:String):void {
			if ( _displayRender == null) {
				trace (  new Error("TransitionBindingService :: No display render dependency found for id lookup:" + id) );
				return;
			}
			var tryTarg:DisplayObject =  _displayRender.getRenderedById(id);
			if (tryTarg) target = tryTarg;
			else trace (  new Error("TransitionBindingService:: Could not find target by id:" + id) );
		}
		

		
		public function set watchProperties(obj:Object):void {
			
			for (var i:String in obj) {
				_binder.addBinding(this, i, obj[i]);
	
				_watchedProps[i] = true;	
				_watchCount++;
			}
			_totalWatchCount = _watchCount;
			_isWatching = true;
		}
		
		
		// -- Proxy
		
		override flash_proxy function callProperty (name:*, ...rest) : * {
			return null;
		}
		
		
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			return false; // _target[name];
		}


		override flash_proxy function getProperty(name : *) : *
		{
			return _target[name];
		}


		override flash_proxy function setProperty(name : *, value : *) : void
		{ 
			

			var transPayload:*;
	
			if (_watchedProps[name] != null) _toSetProperties[name] = value
			else return;
			
			if (_isWatching && toSetTarget != null ) {
				
				_watchCount--;
				_watchedProps[name] = false;
				if (_watchCount == 0) {
					
					transPayload  = _transModule ? _transModule.transitionOutPayload : null;
					if (transPayload) {
						transPayload.vars.onComplete = outComplete;
						transPayload.restart(true);
						
					}
					else {
						outComplete();
					}
					
				}
				
			}
			
		}
		
		private function outComplete():void {
			
			if (toSetTarget == null) return;
			for (var i:* in _watchedProps) {
				toSetTarget[i] = _toSetProperties[i];
				_watchedProps[i] = true;		
			}
			_watchCount = _totalWatchCount;
			if (_transModule == null) {
				var req:TransitionModuleEvent = new TransitionModuleEvent(TransitionModuleEvent.REQUEST);
				_target.dispatchEvent(req  );
				_transModule = req.transitionModule;
			}
			var payload:* = _transModule ?  _transModule.transitionInPayload : null;
			if (payload) {
			
				payload.restart(true);
			}
		}

		
		// -- Object
		
		public function toString():String {
			return "[TransitionPropertyService]";
		}
		
	}

}