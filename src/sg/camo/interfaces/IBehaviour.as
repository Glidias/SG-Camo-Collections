package sg.camo.interfaces {
	
	/**
	* Standard interface for all behaviours. Extends from IDestroyable since almost all behaviours normally
	* require garbage collection in some way all the other. (Even if the behaviour doesn't, it still includes
	* the IDestroyable.destroy() method as a convention.)
	* <br/><br/>
	* Behaviours are somewhat like "decorators" which can be applied to directly to displayObjects. 
	* To do this, you instantiate the behaviour and call activate() on the specific target. Certain classes store
	* can store behaviours, (such as <code>sg.camolite.display.GBaseDisplay</code>) which implements
	* <code>IBehaviouralBase</code>, and will automatically activate those behaviours immediately upon
	* adding the behaviour through the IBehaviourbase.addBehaviour() method.
	* 
	* @see sg.camo.interfaces.IBehaviouralBase
	* 
	* @author Glenn Ko
	*/
	public interface IBehaviour extends IDestroyable {
		
		/**
		 * Identifies behaviour by a <b>unique name</b> to allow registering of behaviour.
		 */
		function get behaviourName():String;
		
		/**
		 * Activates behaviour on a particular target
		 * @param	targ	Check concrete behaviour implementations to determine what type of targets are valid.
		 */
		function activate(targ:*):void;
		
	}
	
}