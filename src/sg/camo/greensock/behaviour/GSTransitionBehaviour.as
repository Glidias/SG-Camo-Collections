package sg.camo.greensock.behaviour 
{
	import com.greensock.core.TweenCore;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.greensock.GSPluginVars;
	import sg.camo.greensock.transitions.GSTransition;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.greensock.EasingMethods;
	
	/**
	 * Default hardcoded GSTransition instance that runs over targetted object.
	 * @author Glenn Ko
	 */
	
	[Inject]
	public class GSTransitionBehaviour implements IBehaviour 
	{
		public static const NAME:String = "GSTransitionBehaviour";
		
		// constructor parameters
		public var tweenClass:Class;
		public var gsPluginVars:GSPluginVars;
		
		public static const TRANSITION_IN:String = "transitionIn";
		public static const TRANSITION_IN_COMPLETE:String = "transitionInComplete";
		public static const TRANSITION_OUT:String = "transitionOut";
		public static const TRANSITION_OUT_COMPLETE:String = "transitionOutComplete";
		
		// Event parameters and callbacks
		public var eventIn:String = TRANSITION_IN;
		public var eventInComplete:String = TRANSITION_IN_COMPLETE;
		public var eventOut:String = TRANSITION_OUT;
		public var eventOutComplete:String = TRANSITION_OUT_COMPLETE;
		public var bubbleComplete:Boolean = false;
		public var oneShot:Boolean = false;
		
		
		protected var myBaseTransition:GSTransition;
		protected var propMap:Object = { };
		protected var targDispatcher:IEventDispatcher;

		public var renderNow:Boolean = false;
		
		
		public function GSTransitionBehaviour(pluginVars:GSPluginVars = null) 
		{
			gsPluginVars = pluginVars;
		}
		
		public function set gsTransition(val:GSTransition):void {
			myBaseTransition = val;
		}
		
		
		protected function transitionInHandler(e:Event):void {
			
			var twc:TweenCore = myBaseTransition.transitionInPayload;

			twc.vars.onComplete = dispatchInComplete;
			
			
			twc.restart(true, false);
			

			if (oneShot) {
				AncestorListener.removeEventListenerOf(e.currentTarget as IEventDispatcher, eventIn, transitionInHandler);
			}
		}
		
		protected function dispatchInComplete():void {
			targDispatcher.dispatchEvent ( new Event(eventInComplete, bubbleComplete) );
		}
		protected function dispatchOutComplete():void {
			targDispatcher.dispatchEvent ( new Event(eventOutComplete, bubbleComplete) );
		}
		
		protected function transitionOutHandler(e:Event):void {
			var twc:TweenCore = myBaseTransition.transitionOutPayload;
			
			if (!twc.reversed) {
				
			
				twc.vars.onComplete = dispatchOutComplete;
				twc.restart(true, false);
			}
			else {
				twc.vars.onReverseComplete = dispatchOutComplete;
			}
			
			if (oneShot) AncestorListener.removeEventListenerOf(e.currentTarget as IEventDispatcher, eventOut, transitionOutHandler);
		}
		
		
		public function get behaviourName():String {
			return NAME;
		}

		public function activate(targ:*):void {
			targDispatcher = targ as IEventDispatcher;
			
			myBaseTransition = createGSTransition();
			for (var i:String in propMap) {
				myBaseTransition[i] = propMap[i];
			}
			
			AncestorListener.addEventListenerOf(targDispatcher,eventIn, transitionInHandler);
			AncestorListener.addEventListenerOf(targDispatcher, eventOut, transitionOutHandler);
			
			postActivate();
		}
		
		protected function postActivate():void {
			if (renderNow) targDispatcher.dispatchEvent( new Event(eventIn) );
		}
		
		protected function createGSTransition():GSTransition {
			return new GSTransition(targDispatcher, tweenClass, gsPluginVars)
		}
		
		
		// Proxy methods boiler plate grrrrr...
		public function set durationIn(val:Number):void {
			propMap.durationIn = val;
		}
		public function set durationOut(val:Number):void {
			propMap.durationOut = val;
		}
		public function set reverseOnInterrupt(val:Boolean):void {
			propMap.reverseOnInterrupt = val;
		}
		public function set reverseOnOut(val:Boolean):void {
			propMap.reverseOnOut = val;
		}
		
		public function set easeIn(val:String):void {
			propMap.easeIn = EasingMethods.getEasingMethod(val);
		}
		public function set easeOut(val:String):void {
			propMap.easeOut =EasingMethods.getEasingMethod(val);
		}
		
		
		
		public function set initVars(val:Object):void {
			propMap.initVars = val;
		}
		
		public function set setVars(val:Object):void {
			propMap.setVars = val;
		}
		
		public function set restoreVars(val:Object):void {
			propMap.restoreVars = val;
		}
		
		public function set ease(val:String):void {
			propMap.ease = EasingMethods.getEasingMethod(val);
		}
		
		public function set duration(val:Number):void {
			propMap.duration = val;
		}
		
		public function set fromVars(val:Object):void {
			propMap.fromVars = val;
		}
		public function set inVars(val:Object):void {
			propMap.inVars = val;
		}
		
		public function set outVars(val:Object):void {
			propMap.outVars = val;
		}
		
		
		// Destructor
		
		public function destroy():void  {
			myBaseTransition.destroy();
			AncestorListener.removeEventListenerOf(targDispatcher, eventIn, transitionInHandler);
			AncestorListener.removeEventListenerOf(targDispatcher, eventOut, transitionOutHandler);
		}
		
	}

}