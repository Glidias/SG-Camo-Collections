package sg.camo.interfaces 
{
	
	/**
	 * Extended IDestroyable interface to allow for recursive/non-recursion assertion
	 * options during disposal.
	 * 
	 * @author Glenn Ko
	 */
	public interface IRecursableDestroyable extends IDestroyable
	{
		function destroyRecurse(recurse:Boolean=false):void;
	}
	
}