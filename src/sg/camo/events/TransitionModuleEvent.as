package sg.camo.events 
{
	import flash.events.Event;
	import sg.camo.interfaces.ITransitionModule;
	
	/**
	 * Cross-platform transition module event for requesting transition modules
	 * that can be remotel executed over given listener instances. 
	 * 
	 * @see sg.camo.behaviour.TransitionBehaviour
	 * @author Glenn Ko
	 */
	public class TransitionModuleEvent extends Event 
	{
		/**
		 * To consider whether to provide for a transition in payload request
		 */
		public static const REQUEST_IN:String = "TransitionModuleEvent.REQUEST_IN";
		
		/**
		 * To consider whether to provide for a transition out payload request.
		 */
		public static const REQUEST_OUT:String = "TransitionModuleEvent.REQUEST_OUT";
		
		/**
		 * To immediately request for transition module over targetted instance
		 */
		public static const REQUEST:String = "TransitionModuleEvent.REQUEST";
		
		/** A supplied transition module payload, if available within requested context */
		public var transitionModule:ITransitionModule;
		
		public function TransitionModuleEvent(type:String, bubbles:Boolean=false, module:ITransitionModule=null) 
		{ 
			super(type, bubbles);
			transitionModule = module;
		} 
		
		public override function clone():Event 
		{ 
			return new TransitionModuleEvent(type, bubbles, transitionModule);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TransitionModuleEvent", "type", "bubbles", "transitionModule"); 
		}
		
	}
	
}