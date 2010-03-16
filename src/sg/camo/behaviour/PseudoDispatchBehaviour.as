package sg.camo.behaviour 
{
	import flash.events.Event;
	import sg.camo.interfaces.INodeClassSpawner;
	/**
	 * Listens to a particular event and dispatches multiple generic bubbling/non-bubbling native Flash Events in response to 
	 * the listened event.
	 * 
	 * @usage In CSS/GXML, this is done through a IPropertyApplier that allows applying ALL properties over dynamic Proxy classes.
	 * 			Boolean values indicate whether the event is bubbling or not.
	 * <code>
	 * 		.someBtnSprite>click!dispatch { // In response to a click, dispatch the following...
	 * 			completePhase:true;		
	 *			GDisplay.SELECT:true;
	 * 			flyUp:false;
	 * 		}
	 * 
	 * </code>
	 * 
	 * @usage In As3, you can do this standalone, setting any properties you wish.
	 * <code>
	 * 		 private var _pseudoDispatches:PseudoDispatchBehaviour = new PseudoDispatchBehaviour();
	 *		 _pseudoDispatches.pseudoState = "click";	// In response to a click, dispatch the following...
	 *		_pseudoDispatches.completePhase = true; 
	 * 		_pseudoDispatches["GDisplay.SELECT"] = false; 
	 * 		_pseudoDispatches.flyUp = false;
	 * 		_pseudoDispatches.activate(someBtnSprite);
	 * </code>
	 * 
	 * Make sure that the event handlers that processes such events through this behaviour 
	 * uses the basic "Event" class in the handler, else type coercion problems might occur.
	 * 
	 * .
	 * @author Glenn Ko
	 */
	public class PseudoDispatchBehaviour extends AbstractEventBehaviour
	{

		
		protected var _eventHash:Object = { };
		
		public static const NAME:String = "PseudoDispatchBehaviour";
		
		[Inject]
		public var nodeClassSpawner:INodeClassSpawner;
		

		public function PseudoDispatchBehaviour() 
		{
			super(this);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override protected function listenEventHandler(e:Event):void {
			for (var i:String in _eventHash) {
				_targDispatcher.dispatchEvent( _eventHash[i] );	
			}
		}
		

		override protected function $deleteProperty(name:*):Boolean {
			return delete _eventHash[name];
		}

		override protected function $getProperty(name:*):* {
			return _eventHash[name];
		}


		override protected function $setProperty(name:*, value:*):void {
			_eventHash[name] = value.charAt(0) === "<" ? nodeClassSpawner.parseNode(XML(value)) : value is Boolean ? new Event(name, value) : new Event(name, value == "true");
		}
		
	}

}