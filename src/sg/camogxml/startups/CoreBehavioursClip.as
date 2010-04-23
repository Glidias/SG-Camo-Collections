package sg.camogxml.startups 
{
	
	import sg.camo.behaviour.*;

	/**
	 * Base set of behaviours
	 * @author Glenn Ko
	 */
	public class CoreBehavioursClip extends DefinitionsClip
	{
		
		public function CoreBehavioursClip() 
		{
			registerDefinitions(
	
				SelectionBehaviour,
				DivLayoutBehaviour,
				HLayoutBehaviour,
				VLayoutBehaviour,
				WrapHLayoutBehaviour,
				WrapVLayoutBehaviour,
				AlignBehaviour,
				AlignTextBehaviour,
				AlignToParentBehaviour,

				SkinBehaviour,
				SelectableBehaviour,
				SelectionBehaviour,
				LoadImgBehaviour,
				ScrollableBehaviour,
				
				HrefBehaviour,
			
				
				// Proxy/pseudo behaviours
				ButtonStateBehaviour,
				StateBehaviour,
				StateTextBehaviour,
				TransitionBehaviour,
				PseudoDispatchBehaviour
			
				// FOrm-related behaviours  // not part of core, extend and add your own if required
				//FormFieldBehaviour

			);
		}
		
	}

}