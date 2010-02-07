package sg.camo.greensock.behaviour 
{
	import sg.camo.interfaces.IBehaviour;
	import flash.utils.Proxy;
	import sg.camo.greensock.GSGlobals;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITransitionModule;
	import sg.camo.interfaces.ITypeHelper;
	
	/**
	 * Not implement at the moment. An abstract generic behaviour class to instantiate
	 * a ITransitionModule arbituarily, and supply the assosiated dependencies
	 * based on the given properties being applied.
	 * 
	 * Requires ITypeHelper and IPropertyMapCache interfaces from GSGlobals to be able to support 
	 * applying properties over activated object.
	 * 
	 * THe instantiated transitionClass must implement the ITransitionModule interface from which
	 * transitionOut and transitionInPayloads can be received.
	 * 
	 * Might consider brining this over to camogxml branch or scrapping completely as it's 
	 * too abstract.
	 * 
	 * 
	 * @author Glenn Ko
	 */
	public class TransitionBehaviour implements IBehaviour  extends Proxy
	{
		public static const NAME:String = "TransitionBehaviour";
		
		protected var properties:Object = {};
		
		
		[Inject(name="TransitionBehaviour.transitionClass")]
		public var transitionClass:Class;
		
		[Inject]
		public var propMapCache:IPropertyMapCache = GSGlobals.propertyMapCache;
		[Inject]
		public var typeHelper:ITypeHelper = GSGlobals.typeHelper;
		
		protected var transitionModule:ITransitionModule;
		
		public function TransitionBehaviour() 
		{
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		

		public function activate(targ:*):void {
			if (transitionClass == null) {
			
				return null;
			}
		
			
		}
		
		public function destroy():void  {
			if (transitionModule is IDestroyable) (transitionModule as IDestroyable).destroy();
		}
		
	}

}