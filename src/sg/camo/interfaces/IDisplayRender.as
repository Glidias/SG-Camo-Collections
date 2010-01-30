package sg.camo.interfaces
{
	import flash.display.DisplayObject;
	
	/**
	* Cross-platform interface signature for any composed display instance and any other nested/related display instances 
	* within it.
	* Provides the necessary methods to work with GXML, any other type of display render asset manager, content-injector or object pool.
	* @author Glenn Ko
	*/
	public interface IDisplayRender
	{
		/**  render ID for registering with asset managers. */
		function get renderId():String;			
		
		/** the current main display object instance */
		function get rendered():DisplayObject;			   
		
		/** retrieves any related/nested display object instance */
		function getRenderedById(id:String):DisplayObject; 
		
		
		// -- Currently not exactly used ATM
		
		/**  support for restoring back any default settings that were changed during the course of the application */
		function restore(changedHash:Object = null):void; 
		
		/** flag that shows checked in/out status of display render (ie. transiting in/transitioned in, or transiting out/transitioned out) of pool.
		 * This flag can also be used internally by the class as well to trigger transitionings.
		 * */
		function set isActive(boo:Boolean):void;	
		function get isActive():Boolean;
		
		
	}
	
}