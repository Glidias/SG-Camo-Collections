package sg.camo.greensock.behaviour 
{
	import com.greensock.core.TweenCore;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import sg.camo.behaviour.AbstractProxyBehaviour;
	import sg.camo.greensock.GSPluginVars;
	import sg.camo.greensock.transitions.GSTransition;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.greensock.EasingMethods;
	import sg.camo.interfaces.IPropertyApplier;
	
	/**
	 * Default hardcoded GSTransition instance that runs over targetted object.
	 * @author Glenn Ko
	 */
	
	[Inject]
	public class GSTransitionBehaviour extends AbstractProxyBehaviour
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
		
		[Inject]
		public var propApplier:IPropertyApplier;
		
		
		public function GSTransitionBehaviour(pluginVars:GSPluginVars = null) 
		{
			super(this);
			gsPluginVars = pluginVars;
		}
		
		public function set gsTransition(val:GSTransition):void {
			myBaseTransition = val;
		}
		
		
		protected function transitionInHandler(e:Event):void {

			var twc:TweenCore = myBaseTransition.transitionInPayload;

			if (twc == null) return;
			
			
			twc.vars.onComplete = dispatchInComplete;
			
			
			twc.restart(true, false);
			

			if (oneShot) {
				(e.currentTarget as IEventDispatcher).removeEventListener( eventIn, transitionInHandler);
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
			
			
			if (twc == null) return;
			
			if (!twc.reversed) {
				
			
				twc.vars.onComplete = dispatchOutComplete;
				twc.restart(true, false);
			}
			else {
				twc.vars.onReverseComplete = dispatchOutComplete;
			}
			
			if (oneShot) (e.currentTarget as IEventDispatcher).removeEventListener(eventOut, transitionOutHandler);
		}
		
		
		override public function get behaviourName():String {
			return NAME;
		}

		override  public function activate(targ:*):void {
			targDispatcher = targ as IEventDispatcher;
			
			myBaseTransition = createGSTransition();
			if (propApplier != null) propApplier.applyProperties(myBaseTransition, propMap)
			else trace("GSTransitionBehaviour! No property applier applied!");
			
			
			targDispatcher.addEventListener(eventIn, transitionInHandler, false, 0, true);
			targDispatcher.addEventListener(eventOut, transitionOutHandler, false, 0, true);
			
			postActivate();
		}
		
		protected function postActivate():void {
			if (renderNow) targDispatcher.dispatchEvent( new Event(eventIn) );
		}
		
		protected function createGSTransition():GSTransition {
			return new GSTransition(targDispatcher, tweenClass, gsPluginVars)
		}
		
		
		// Proxy methods
		override protected function $setProperty(name:*, value:*):void {
			propMap[name] = value;
		}
		
		override protected function $getProperty(name:*):* {
			return propMap[name];
		}
		
		// Destructor
		
		override public function destroy():void  {
			myBaseTransition.destroy();
			targDispatcher.removeEventListener( eventIn, transitionInHandler);
			targDispatcher.removeEventListener( eventOut, transitionOutHandler);
		}
		
	}

}