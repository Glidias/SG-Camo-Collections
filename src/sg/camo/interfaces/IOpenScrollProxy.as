package sg.camo.interfaces {
	
	/**
	* Extended IScrollProxy with extra setters/getters to facilitate scrolling within an 
	* opening/closing context. For implications, see the below concrete implementation:
	* 
	* @see sg.camolite.scrollables.OpenCloseScrollProxy
	* 
	* @author Glenn Ko
	*/
	public interface IOpenScrollProxy extends IScrollProxy {
			
		 function get openReverseDirection():Boolean;
		 function set openReverseDirection(boo:Boolean):void;
		
		
	}
	
}