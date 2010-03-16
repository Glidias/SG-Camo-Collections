package sg.camogxml.api 
{
	
	/**
	 * Interface for utility classes that can invoke functions remotely with parameters.
	 * @author Glenn Ko
	 */
	public interface IFunctionInvoker 
	{
		/**
		 * 
		 * @param	host		The object that hosts the method
		 * @param	methodName	The method name
		 * @param	params		A set of parameters to apply to method.
		 * @return	The returned value of the function if available.
		 */
		function invoke(host:Object, methodName:String, params:Array):*;
	}
	
}