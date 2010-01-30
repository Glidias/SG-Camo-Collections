package sg.camogxml.api 
{
	
	/**
	 * Interface for function definitions, which contains the necessary information to execute a function
	 * correctly with the correct parameters.
	 * 
	 * @author Glenn Ko
	 */
	public interface IFunctionDef 
	{
		function get method():Function;
		function get overload():Boolean;
		function get requiredLength():int;
		function getParams():Array;
		function get delimiter():String;
	}
	
}