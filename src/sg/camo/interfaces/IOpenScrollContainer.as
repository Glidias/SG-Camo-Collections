package sg.camo.interfaces 
{
	
	/**
	 * Interface for OpenScroll containers
	 * @author Glenn Ko
	 */
	public interface IOpenScrollContainer extends IScrollable
	{
		function set iScroll(val:IOpenScrollProxy):void;
		function get iScroll():IOpenScrollProxy;
	}
	
}