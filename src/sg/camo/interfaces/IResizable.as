package sg.camo.interfaces {
	
	/**
	* Marker interface for resizable items. 
	* @author Glenn Ko
	*/
	public interface IResizable {
		
		/**
		 * Note: The implications of resizing an item through the IResizable interface may vary across different implementations.
		 * @param	w	A valid width value to affect the display's dimension.
		 * @param	h	A valid height value to affect the display's dimension.
		 */
		function resize(w:Number, h:Number):void;
		
	}
	
}