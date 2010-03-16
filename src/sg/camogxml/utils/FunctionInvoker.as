package sg.camogxml.utils 
{
	import sg.camogxml.api.IFunctionDef;
	import sg.camogxml.api.IFunctionInvoker;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FunctionInvoker implements IFunctionInvoker
	{
		/**
		 * Standalone class to invoke functions remotely from a host with given parameters
		 * which can be string-based and automatically type-converted.
		 */
		public function FunctionInvoker() 
		{
			
		}
		
		public function invoke(host:Object, methodName:String, params:Array):* {
			return FunctionDefInvoker.invoke(FunctionDefCreator.get(host, methodName), params);
		}
		
	}

}