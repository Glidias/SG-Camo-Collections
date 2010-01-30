package sg.camo.interfaces 
{
	
	/**
	 * A scroll container interface that supports setting of IScrollProxy, so as to delegate specific scrolling
	 * implementations to another class to handle.
	 * 
	 * @see sg.camo.interfaces.IScrollProxy
	 * @author Glenn Ko
	 */
	public interface IScrollContainer extends IScrollable
	{
		function set iScroll(val:IScrollProxy):void;
		function get iScroll():IScrollProxy;
	}
	
}