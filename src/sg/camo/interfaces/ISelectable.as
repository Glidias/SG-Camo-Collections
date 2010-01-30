package sg.camo.interfaces 
{
	
	/**
	 * Marker interface to identify selectable items which can assume selected/unselected states.
	 * @author Glenn Ko
	 */
	public interface ISelectable 
	{
		function set selected (bool:Boolean):void;
		function get selected ():Boolean;
	}
	
}