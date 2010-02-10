package sg.camo.greensock.behaviour 
{
	import camo.core.events.CamoDisplayEvent;
	import com.greensock.core.TweenCore;
	import com.greensock.TweenLite;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.greensock.EasingMethods;
	import flash.events.Event;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.greensock.CreateGSTweenVars;
	
	/**
	 * A tween behaviour execution with initial starting values and destination values
	 * along a linear reversible tween. Also allows setting of restore variables
	 * when destroy() is being called. You need to set the 'eventTo' and 'eventReturn'
	 * event types to determine what events trigger a tween to the "toVars" and "fromVars"
	 * respectively. Also provides flags for one shot tweens or immediately executing
	 * the tween upon activation even if no event triggers are specified.
	 * 
	 * @author Glenn Ko
	 */
	public class TweenEventBehaviour implements IBehaviour
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
		
		//public var toTimeScale:Number = 1;
		//public var fromTimeScale:Number = -1;
		
		protected var _fromVars:Object;
		public function set fromVars(vars:Object):void {
			_fromVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		protected var _toVars:Object;
		public function set toVars(vars:Object):void {
			_toVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		
		// Set restore variables to perform restore tween/action upon destroy()
		protected var _restoreVars:Object;
		public function set restoreVars(vars:Object):void {
			_restoreVars = CreateGSTweenVars.createVarsFromObject(vars);
		}
		public var restoreDuration:Number = 0;  // specify a number to perform a restore tween
		
		public var oneShot:Boolean = false;
		public var renderNow:Boolean = false;
		
		
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
			if (_fromVars == null || _toVars == null) {
				throw new Error("TweenEventBehaviour activate() failed! No from/to variables specified");
				return;
			}
			new tweenClass(targ, .1, _fromVars ).complete();
			_tweenCore = new tweenClass(targ, duration, _toVars );
			_tweenCore.pause();
			if (dispatchDraw) _tweenCore.vars.onUpdate = dispatchDrawBubble;
			var evDisp:IEventDispatcher = targ as IEventDispatcher;
			if (eventTo) AncestorListener.addEventListenerOf(evDisp, eventTo, tweenToHandler);
			if (eventReturn) AncestorListener.addEventListenerOf(evDisp, eventReturn, tweenBackHandler);
			if (renderNow) _tweenCore.restart();
			_targDispatcher = evDisp;
		}
		
		protected function dispatchDrawBubble():void {
			_targDispatcher.dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW, true) );
		}
		

		
		protected function tweenToHandler(e:Event):void {
		
			_tweenCore.restart();
			if (oneShot) AncestorListener.removeEventListenerOf(e.currentTarget as IEventDispatcher, eventTo, tweenToHandler);
		}
		
		protected function tweenBackHandler(e:Event):void {
			_tweenCore.reverse();
			if (oneShot) AncestorListener.removeEventListenerOf(e.currentTarget as IEventDispatcher, eventReturn, tweenToHandler);
		}
		
		public function destroy():void {
			if (_targDispatcher == null) return;

			if (eventTo) AncestorListener.removeEventListenerOf(_targDispatcher, eventTo, tweenToHandler);
			if (eventReturn) AncestorListener.removeEventListenerOf(_targDispatcher, eventReturn, tweenBackHandler);
			if (_restoreVars) {
				if (restoreDuration == 0)  new tweenClass(_targDispatcher, .1, _restoreVars ).complete();
				else new tweenClass(_targDispatcher, restoreDuration, _restoreVars );
				
			}
		}
		
	}

}