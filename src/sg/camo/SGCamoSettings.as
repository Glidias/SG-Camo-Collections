package sg.camo {
	
	/**
	* Display settings for SG Camo
	* 
	* 
	* @author Glenn Ko
	*/
	public class SGCamoSettings {
		
		/** 
		 * Default global settings to recursively search for and destroy all children of AbstractDisplay(s) during
		 * disposal.
		 * 
		 * @see sg.camo.interfaces.IDestroyable
		 * @see sg.camo.interfaces.IRecursableDestroyable 
		 */
		public static var DESTROY_CHILDREN:Boolean = false;
		
	}
	
}