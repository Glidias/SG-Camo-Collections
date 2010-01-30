package sg.camo.interfaces 
{
	
	/**
	 * Standard form element interface to hook up to forms
	 * @author Glenn Ko
	 */
	public interface IFormElement 
	{
		function set value(val:String):void;
		function get value():String;
		function set key(val:String):void;
		function get key ():String;
		function isValid ():Boolean;
		function showError(bool:Boolean = true):void;
		function resetValue():void;
		//function set optional(boo:Boolean):void;  // will add this as well..
		//function get optional():Boolean;
	}
	
}