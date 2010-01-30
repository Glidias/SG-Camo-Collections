package sg.camo.interfaces 
{
	/**
	 * Basic interface to hook up a scroller to a scroll target, which supports both directions
	 * (horizontal or vertical).
	 * <br/><br/>
	 * It is assumed scrollers are also IDestroyable by default, since they usually contain listeners.
	 * <br/><br/>
	 * This interface is not just limited to scrollbars, but also stuffs like joysticks/knobs, etc.
	 * can use this interface to target a IScroll instance.
	 * 
	 * @see sg.camo.interfaces.IScroll
	 * 
	 * @author Glenn Ko
	 */
	public interface IScroller extends IDestroyable
	{
		function set scrollTarget(scr:IScroll):void;
		
	}
	
}