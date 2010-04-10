package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.behaviour.AbstractProxyBehaviour;
	import sg.camo.events.TransitionModuleEvent;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPseudoBehaviour;
	import sg.camo.interfaces.ITransitionManager;
	import sg.camo.interfaces.ITransitionModule;
	import sg.camo.interfaces.INodeClassSpawner;
	
	/**
	 * The transition behaviour, when activated over a display object/IEventDispatcher instance,  wraps over an existing
	 * (dynamically instantiated) transition module and acts on behalf of it, keeps in/out state information of current
	 * intended transition over targetted instance during eventIn/eventOut triggers,
	 * provides a bridge to register that transition module to a transition manager if provided,
	 * and also provides a base for remotely requesting transition modules through TransitionModuleEvent.
	 * 
	 * @see sg.camo.events.TransitionModuleEvent
	 * 
	 * @author Glenn Ko
	 */
	public class TransitionBehaviour extends AbstractProxyBehaviour implements ITransitionModule, IPseudoBehaviour
	{
		public static const NAME:String = "TransitionBehaviour";
		
		protected var targDispatcher:Object;
		protected var _tweenTarget:Object;
		
		public var eventIn:String = "transitionIn";
		public var eventOut:String = "transitionOut";

		// -- Optional Transition Manager stuff
		
		protected var _transitionManager:ITransitionManager;
		public var registerIn:Boolean = false;
		public var registerOut:Boolean = false;
		[PostConstruct]
		public function setTransitionManager(manager:ITransitionManager=null):void {
			_transitionManager = manager;
		}
		
		// -- IPseudoState dummy
		
		protected var _pseudoState:String;
		public  function set pseudoState(str:String):void {
			_pseudoState = str;
		};
		
		
		// -- Injections / Dynamic instantiation over transition module class
		
		/** A ITransitionModule-based class to instantiated arbituarily */
		public var transitionClass:Class;
		
				
		[Inject]
		public var nodeClassSpawner:INodeClassSpawner;
		protected var _node:XML;
		/** Create custom node settings for node class spawner */
		public function set node(val:String):void {
			_node  = XML(val);
		}
		
		[Inject]
		public var propApplier:IPropertyApplier;
		/**
		 * An extra set of setter properties that you'd want to remotely apply to transition module
		 * through property applier. This is set through Proxy namespace.
		 */
		protected var properties:Object = { };
		
		// --Flags
		
		protected var _isIn:Boolean = false;
		protected var transitionModule:ITransitionModule;
		protected var _curTransition:*;
		
		
		public var oneShot:Boolean = false;
		public var renderNow:Boolean = false;
		
		/** Flag to provide search target string from which to perform transition on current target.
		 */
		public var searchTarget:String;
		
		
		public function TransitionBehaviour() 
		{
			super(this);
		}
		
	
		protected function myBinding(str:String):* {
			if (str === "{target}") { 
				return _tweenTarget;
			}
			return null;
		}
		
		override public function get behaviourName():String {
			return NAME;
		}

		
		protected function transitionInHandler(e:Event):void {
			
			_curTransition = transitionModule.transitionInPayload;
			if (_curTransition == null) {
				throw new Error("No transition-in payload found for transitionInHandler");	
			}
			
			_isIn = true;
			
			
			_curTransition.restart(true);  // this is GS specific and shouldn't be done...
			
			
			if (oneShot) (e.currentTarget as IEventDispatcher).removeEventListener( eventIn, transitionInHandler);
		}
		
		protected function getNewTransitionModule():ITransitionModule  {
			return nodeClassSpawner ? nodeClassSpawner.spawnClassWithNode(transitionClass, $node, null, myBinding)  as ITransitionModule :  new transitionClass() as ITransitionModule
		}	
		/** @private Returns default node if no custom node is specified */
		protected function get $node():XML {
			return _node || XML(<transition />);
		}
	
		
		protected function transitionOutHandler(e:Event):void {
			_curTransition = transitionModule.transitionOutPayload;
			_isIn = false;
			if (oneShot) (e.currentTarget as IEventDispatcher).removeEventListener(eventOut, transitionOutHandler);
		}

		public function get transitionInPayload():* {
			return transitionModule.transitionInPayload;
		}
		

		public function get transitionOutPayload():* {
			return transitionModule.transitionOutPayload;
		}
		

		public function get transitionType():* {
			return transitionModule.transitionType;
		}

		
		public function getTweenTarget(val:Object):Object {
			return searchTarget ? FindTarget.find(val, searchTarget) : FindTarget.getPseudoTarget( val, _pseudoState);
		}
		

		override public function activate(targ:*):void {
			targDispatcher = targ as IEventDispatcher;
			
			_tweenTarget = getTweenTarget(targDispatcher); 
			
			if (nodeClassSpawner) nodeClassSpawner.injectInto(this);
			
			transitionModule  = getNewTransitionModule();
			if (transitionModule == null) throw new Error("Can't spawn transition module!");
			
			//if (propApplier && transitionModule) { 
			trace(propApplier);
				propApplier.applyProperties(transitionModule, properties);
			//}
		
			
			targDispatcher.addEventListener(eventIn, transitionInHandler, false, 0, true);
			targDispatcher.addEventListener(eventOut, transitionOutHandler, false, 0, true);
			targDispatcher.addEventListener(TransitionModuleEvent.REQUEST, provideTransitionModule, false, 0, true);
			targDispatcher.addEventListener(TransitionModuleEvent.REQUEST_IN, considerTransitionInRequest, false, 0, true);
			targDispatcher.addEventListener(TransitionModuleEvent.REQUEST_OUT, considerTransitionOutRequest, false, 0, true);
			
			
			if (_transitionManager) {
				var payloadToManager:ITransitionModule;
				if (registerIn && registerOut) {  // could optimise these ifs..
					payloadToManager = new TransitionModulePayload(this, true, true);
				}
				else if (registerIn) {
					
					payloadToManager = new TransitionModulePayload(this, true, false);
				}
				else if (registerOut) {
					payloadToManager = new TransitionModulePayload(this, false, true);
				}
				if (payloadToManager) _transitionManager.addTransitionModule( payloadToManager);
			}
			

			if (renderNow) {
				if (targDispatcher is DisplayObject) {
					var disp:DisplayObject = targDispatcher as DisplayObject;
					if (disp.stage) {
						disp.dispatchEvent(new Event(eventIn));
					}
					else disp.addEventListener(Event.ADDED_TO_STAGE, deferRenderNow, false, 0, true);
				}
				else targDispatcher.dispatchEvent( new Event(eventIn) );
			}
		}
		
		private function deferRenderNow(e:Event):void {
			targDispatcher.dispatchEvent( new Event(eventIn) );
		}
		
		protected function provideTransitionModule(e:TransitionModuleEvent):void {
			e.transitionModule = this;
		}
		
		protected function considerTransitionInRequest(e:TransitionModuleEvent):void {
			e.transitionModule = _isIn ? e.transitionModule : this;
		}
		protected function considerTransitionOutRequest(e:TransitionModuleEvent):void {
			e.transitionModule = _isIn ? this : e.transitionModule;
		}

		

		override public function destroy():void  {
			if (transitionModule is IDestroyable) (transitionModule as IDestroyable).destroy();
			if (targDispatcher != null) {
				targDispatcher.removeEventListener( eventIn, transitionInHandler);
				targDispatcher.removeEventListener( eventOut, transitionOutHandler);
				targDispatcher.removeEventListener(TransitionModuleEvent.REQUEST, provideTransitionModule);
				targDispatcher.removeEventListener(TransitionModuleEvent.REQUEST_IN, considerTransitionInRequest);
				targDispatcher.removeEventListener(TransitionModuleEvent.REQUEST_OUT, considerTransitionOutRequest);
				targDispatcher = null;
			}
		}
		
		// -- Proxy
		
		override protected function $setProperty(name : * , value : * ):void {
		
			properties[name] = value;
			
		}
		
		override protected function $getProperty(name : *):* {
			return properties[name];
		}
		
	}

}