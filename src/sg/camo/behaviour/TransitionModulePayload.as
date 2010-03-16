package sg.camo.behaviour 
{
	import sg.camo.interfaces.ITransitionModule;
	/**
	 * Wrapper class for transition modules to be payloaded to managers and such, without
	 * implementing additional interfaces. Also supports one/two-way transitions.
	 * 
	 * @author Glenn Ko
	 */
	public class TransitionModulePayload implements ITransitionModule
	{
		
		public var gotIn:Boolean;
		public var gotOut:Boolean;
		public var transModule:ITransitionModule;
		
		public function TransitionModulePayload(mod:ITransitionModule, gotIn:Boolean=true, gotOut:Boolean=true) {
			transModule = mod;
			this.gotIn = gotIn;
			this.gotOut = gotOut;
		}
	
		public function get transitionInPayload():* {
			return gotIn ? transModule.transitionOutPayload : null;
		}
		

		public function get transitionOutPayload():* {
			return gotOut ? transModule.transitionOutPayload : null;
		}
		

		public function get transitionType():* {
			return transModule.transitionType;
		}
		
	}

}