package sg.camo.interfaces 
{
	
	/**
	 * Generic cross-platform interface containing transitioning in/out info of a 
	 * particular instance module.
	 * 
	 * @author Glenn Ko
	 */
	public interface ITransitionModule 
	{
		/*  The tween/transition/object or array instance from which single or multiple tweens are derived for the
		 * transition-in phase of the module. Returns null if unavailable. */
		function get transitionInPayload():*;
		
		/* The tween/transition/object or array instance from which single or multiple tweens are derived for the
		 * transition-out phase of the module. Returns null if unavailable. */
		function get transitionOutPayload():*;
		
		/**
		 * Reflects a string or class indicating the type of payload for strict-typing or type-matching.
		 */
		function get transitionType():*;
		
	}
	
}