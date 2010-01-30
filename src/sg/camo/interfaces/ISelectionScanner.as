package sg.camo.interfaces 
{
	import flash.display.Sprite;
	
	/**
	 * Used by selections to scan a display sprite for child ISelectable instances.
	 * <br/><br/>
	 * <i>
	 * (NOTE: This might be renamed to something else not necessarily restricted to the "selection" context, since
	 * a form can also scan for form elements in various locations.)
	 * </i>
	 * 
	 * @author Glenn Ko
	 */
	public interface ISelectionScanner 
	{
		function scan(disp:Sprite):void;
	}
	
}