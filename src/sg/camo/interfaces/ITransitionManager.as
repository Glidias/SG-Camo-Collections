package sg.camo.interfaces 
{
	
	/**
	 * Interface for some manager that can add/remove multiple ITransitionModules for
	 * entire transition in/out phases.
	 * 
	 * @see sg.camo.interfaces.ITransitionModule
	 * 
	 * @author Glenn Ko
	 */
	public interface ITransitionManager extends ITransitable
	{
		/**
		 * Adds a transition module
		 * @see sg.camo.interfaces.ITransitionModule
		 * @param	module		The transition in/out module
		 * @param   timeIn		Time offset when transitioning in
		 * @param   timeOut		Time offset when transitioning out
		 */
		function addTransitionModule(module:ITransitionModule, timeIn:Number = 0, timeOut:Number = 0 ):void;
		
		/**
		 * Removes a transition module
		 * @see sg.camo.interfaces.ITransitionModule
		 * @param	module 		The transition in/out module
		 */
		function removeTransitionModule(module:ITransitionModule):void;
		
		/**
		 * Sets callback function to call when entire transition-in phase is complete
		 */
		function set transitionInComplete(func:Function):void;
		
		/**
		 * Sets callback function to call when entire transition-out phase is complete
		 */
		function set transitionOutComplete(func:Function):void;
	}
	
}