package sg.camo.interfaces 
{
	
	/**
	 * Interface to retrieve current selected instance for classes managing single selections,
	 * including the ability to to clear current selection.
	 * @author Glenn Ko
	 */
	public interface ISelection 
	{
		function get curSelected ():*;
		function clearSelection():void;
	}
	
}