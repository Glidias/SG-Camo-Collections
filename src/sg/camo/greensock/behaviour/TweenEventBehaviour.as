package sg.camo.greensock.behaviour 
{
	import camo.core.events.CamoDisplayEvent;
	import com.greensock.core.TweenCore;
	import com.greensock.TweenLite;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.greensock.EasingMethods;
	import flash.events.Event;
	import sg.camo.greensock.CreateGSTweenVars;
	import sg.camo.interfaces.IPseudoBehaviour;
	
	/**
	 * A tween behaviour execution with initial starting values and destination values
	 * along a linear reversible tween. Also allows setting of restore variables
	 * when destroy() is being called. You need to set the 'eventTo' and 'eventReturn'
	 * event types to determine what events trigger a tween to the "toVars" and "initVars"
	 * respectively. Also provides flags for one shot tweens or immediately executing
	 * the tween upon activation even if no event triggers are specified.
	 * 
	 * @author Glenn Ko
	 */
	public class TweenEventBehaviour implements IPseudoBehaviour
	{
		
		public static const NAME:String = "TweenEventBehaviour";
		public var duration:Number = .6;
		
		public var tweenClass:Class = TweenLite;
		
		/**
		 * Whether to manually dispatch CamoDisplayEvent.DRAW event bubble upon every tween update.
		 * Normally, if the activated component doesn't dispatch a "draw" event, than
		 * you need to set this to true to indicate resize changes which require updating  
		 * of layouts in the parent container.
		 */
		public var dispatchDraw:Boolean = false;
		
		protected var _initVars:Object;
		public function set initVars(vars:Object):void {
			_initVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		
		
		protected var _toVars:Object;
		protected var _initToVars:Object;
		
		public function set initToVars(vars:Object):void {
			_initToVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		public function set toVars(vars:Object):void {
			_toVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		
		// Set restore variables to perform restore tween/action upon destroy()
		protected var _restoreVars:Object;
		public function set restoreVars(vars:Object):void {
			_restoreVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		public var restoreDuration:Number = 0;  // specify a number to perform a restore tween
		
		public static const ONESHOT_NONE:int = 0 ;
		public static const ONESHOT_ONCE:int = 1;
		public static const ONESHOT_RECOVER:int = 2;
		
		public var oneShot:int = ONESHOT_NONE;
		
		public var renderNow:Boolean = false;
		
		// -- IPseudoState dummy
		public function set pseudoState(str:String):void { 
		
		}
		
		// Event info and easing
		public var eventTo:String;
		public var eventReturn:String;
		public var easeTo:Function = null;
		public var easeReturn:Function = null;
		public function set ease(func:Function):void {
			easeTo = func;
			easeReturn = func;
		}
	

		private var _tweenCore:TweenCore;
		private var _targDispatcher:IEventDispatcher;
		
		
		public function TweenEventBehaviour() 
		{
			
		}
		
		
		public function get behaviourName():String {
			return NAME;
		}
		
		
		
		public function activate(targ:*):void {
		/*	if (_initVars == null || _toVars == null) {
				throw new Error("TweenEventBehaviour activate() failed! No from/to variables specified");
				return;
			}*/
			var evDisp:IEventDispatcher = targ as IEventDispatcher;
			_targDispatcher = evDisp;
			if (_initVars) new tweenClass(targ, .1, _initVars ).complete();
			if (_toVars) {
				_tweenCore = new tweenClass(targ, duration, _toVars );
				if (dispatchDraw) _tweenCore.vars.onUpdate = dispatchDrawBubble;
				_tweenCore.pause();
				if (eventTo) evDisp.addEventListener( eventTo, tweenToHandler, false, 0, true);
				if (eventReturn) evDisp.addEventListener( eventReturn, tweenBackHandler, false, 0, true);
				if (renderNow) _targDispatcher.dispatchEvent( new Event(eventTo) );
			}
		
		}
		
		protected function dispatchDrawBubble():void {
			_targDispatcher.dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW, true) );
		}
		
		
		
		
		
		private var _tweenedTo:Boolean = false;
		
		protected function tweenToHandler(e:Event):void {
			
			if (_eventToFromRecover) {
				recoverEventFrom();
			}
			
			
		
			//var twc:TweenCore = new tweenClass(e.currentTarget, duration, _toVars );
			//if (dispatchDraw) twc.vars.onUpdate = dispatchDrawBubble;
			
			
			if (oneShot > ONESHOT_NONE) {
				(e.currentTarget as IEventDispatcher).removeEventListener(eventTo, tweenToHandler);

				if (oneShot > ONESHOT_ONCE) {
					_tweenCore.vars.onComplete = recoverEventTo;
					_eventToRecover = true;
				}
			}
			
			/*
			if (_tweenCore.currentTime > 0) {
				//_tweenCore.complete(true, true);
				_tweenCore.reverse();
			}
			*/
			//else
			_tweenCore.restart();
		}
		
		protected function tweenBackHandler(e:Event):void {
			if (_tweenCore == null) return;
			
			_tweenCore.reverse();
			
			if (_eventToRecover) {
				recoverEventTo();
			}
			
			if (oneShot > ONESHOT_NONE) {
				(e.currentTarget as IEventDispatcher).removeEventListener(eventReturn, tweenToHandler);
				if (oneShot > ONESHOT_ONCE) {
					_tweenCore.vars.onComplete = recoverEventFrom;
					_eventToFromRecover = true;
				}
			}
			
		}
		
		protected var _eventToRecover:Boolean = false;
		protected var _eventToFromRecover:Boolean = false;
		
		protected function recoverEventTo():void {
			_targDispatcher.addEventListener(eventTo, tweenToHandler, false, 0, true);
			_eventToRecover =false;
			
		}
		protected function recoverEventFrom():void {
			_targDispatcher.addEventListener(eventReturn, tweenBackHandler, false, 0, true);
			_eventToFromRecover = false;
		}
		
		public function destroy():void {
			if (_targDispatcher == null) return;

			if (eventTo) _targDispatcher.removeEventListener( eventTo, tweenToHandler);
			if (eventReturn) _targDispatcher.removeEventListener( eventReturn, tweenBackHandler);
			if (_restoreVars) {
				if (restoreDuration == 0)  new tweenClass(_targDispatcher, .1, _restoreVars ).complete();
				else new tweenClass(_targDispatcher, restoreDuration, _restoreVars );
				
			}
		}
		
	}

}