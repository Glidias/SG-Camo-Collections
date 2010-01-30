package sg.camo.interfaces 
{
	
	/**
	 * Base interface for transitable items or classes that can perform transition in/out phases.
	 * @author Glenn Ko
	 */
	public interface ITransitable 
	{
		function transitionIn():void;
		function transitionOut():void;
	}
	
}