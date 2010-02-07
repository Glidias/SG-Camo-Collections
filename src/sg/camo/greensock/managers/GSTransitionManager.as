package sg.camo.greensock.managers 
{
	import com.greensock.TimelineLite;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.ITransitionManager;
	import sg.camo.interfaces.ITransitionModule;
	/**
	 * Utility to support asynchrounous transtioning in/out of various ITransitionModules for a 
	 * complete per-page transition phase. 
	 * 
	 * @author Glenn Ko
	 */

	public class GSTransitionManager implements ITransitionManager, IDestroyable
	{
		/** @private */ protected var _mainTimeline:TimelineLite;
		/** @private */ protected var _modules:Dictionary = new Dictionary();
		
		/** @private */ protected var _transitionInComplete:Function;
		/** @private */ protected var _transitionOutComplete:Function;
		
		public function GSTransitionManager(timelineClass:Class=null) 
		{
			_mainTimeline = timelineClass ? new timelineClass() as TimelineLite : new TimelineLite();
			_mainTimeline.vars.paused = true;
		}
		
		// -- ITransitable
		public function transitionIn():void {
			_mainTimeline.clear();
			_mainTimeline.vars.onComplete = _transitionInComplete;
			for (var i:* in _modules) {
				var module:ITransitionModule = i;
				var inOutTiming:InOutTiming = _modules[i];
				var payload:* = module.transitionInPayload;
				trace(inOutTiming.timeIn, payload);
				if (payload) _mainTimeline.insert( payload, inOutTiming.timeIn);
			}
			if (_mainTimeline.totalTime == 0 ) {
				_mainTimeline.complete();
				//if (_transitionInComplete!=null) _transitionInComplete();
				return;
			}
			_mainTimeline.restart();
		}
		public function transitionOut():void {
			_mainTimeline.clear();
			_mainTimeline.vars.onComplete = _transitionOutComplete;
			for (var i:* in _modules) {
				var module:ITransitionModule = i;
				var inOutTiming:InOutTiming = _modules[i];
				var payload:* = module.transitionOutPayload;
				if (payload) _mainTimeline.insert( payload, inOutTiming.timeOut);
			}
			if (_mainTimeline.totalTime == 0 ) {
				//trace("Total time 0:"+_transitionOutComplete);
				//_mainTimeline.complete();
				if (_transitionOutComplete!=null) _transitionOutComplete();
				return;
			}
			_mainTimeline.restart();
			
		}
		
		// -- ITransitionManager

		public function addTransitionModule(module:ITransitionModule, timeIn:Number = 0, timeOut:Number = 0):void {
			// note: Code doesn't check if module type is a TweenCore. It assumes it's a TweenCore.
			_modules[module] = new InOutTiming(timeIn, timeOut);
			trace(timeIn, timeOut);
		}

		
		public function removeTransitionModule(module:ITransitionModule):void {
			var inOutTiming:InOutTiming = _modules[module];
			if (!inOutTiming) return;
			// consider asynchronous removal of module even after transitionOut is called
			// currently not supported.
			delete _modules[module];
		}

		public function set transitionInComplete(func:Function):void {
			_transitionInComplete = func;
			//trace("Setting transition in complete callback:");
		}
		
	
		public function set transitionOutComplete(func:Function):void {
			_transitionOutComplete = func;
		}
		
		// -- IDestroyable
		
		/**
		 * Resets entire transition manager
		 */
		public function destroy():void {
			_mainTimeline.stop();
			_mainTimeline.clear();
			if (_mainTimeline.vars.onComplete) _mainTimeline.vars.onComplete = null;
			_transitionInComplete = null;
			_transitionOutComplete = null;
			for (var i:* in _modules) {
				if (i is IDestroyable) (i as IDestroyable).destroy();
				delete _modules[i];
			}
		}
		
	}

}

internal class InOutTiming {
	
	public var timeIn:Number;
	public var timeOut:Number;
	
	public function InOutTiming(timeIn:Number, timeOut:Number) {
		this.timeIn = timeIn;
		this.timeOut = timeOut;
	}
	
}