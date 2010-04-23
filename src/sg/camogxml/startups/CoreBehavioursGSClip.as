package sg.camogxml.startups 
{
	
	import sg.camo.greensock.behaviour.*;
	
		
	/**
	 * With greensock behaviours...
	 * @author Glenn Ko
	 */
	public class CoreBehavioursGSClip extends CoreBehavioursClip
	{
		
		public function CoreBehavioursGSClip() 
		{
			super();
			
			registerDefinitions(
				// GS Behaviours
				//GSListTransitionBehaviour,
				GSTransitionBehaviour,
				TweenEventBehaviour
				
			)
			
			
				
		}
		
	}

}