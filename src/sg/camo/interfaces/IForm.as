package sg.camo.interfaces 
{
	import flash.net.URLVariables;

	/**
	 * Standard form interface.
	 * @author Glenn Ko
	 */
	public interface IForm 
	{
		function validate ():Boolean;
		function resetAll ():void;
		function addFormElement (targ:IFormElement):void;
		function getURLVariables():URLVariables;
		
	}
	
}