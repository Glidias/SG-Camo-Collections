package sg.camogxml.utils 
{
	import sg.camogxml.api.IFunctionDef;
	import camo.core.utils.TypeHelperUtil;
	/**
	 * Handy utility to execute factory methods / function definitions. 
	 * 
	 * @see sg.camogxml.api.IFunctionDef
	 * 
	 * @author Glenn Ko
	 */
	public class FunctionDefInvoker
	{
		
		/**
		 * Validates, executes and type-checks a function definition given an array of 
		*  parameters. Parameters can be string-based and automatically type-converted with the help Camo's TypeHelperUtil
		 *  for various common Flash data types.
		 * @see camo.core.utils.TypeHelperUtil
		 * 
		 * @param	def		The function definition to execute
		 * @param	params	An array of values/strings to invoke the function
		 * @param 	overwriteCallMethod  Another method to call with the given function definition information
		 * @return	A returned value of the function or null if return type for the function is void or an error
		 * 				occured while vaidating the method and it's parameters to inject
		 */
		public static function invoke(def:IFunctionDef, params:Array, overwriteCallMethod:Function=null ):* {
			if (def == null) return null;
			var defParams:Array = def.getParams();
			var requiredLen:int = def.requiredLength;
			var methodToCall:Function = overwriteCallMethod || def.method;
			if (methodToCall == null) {
				trace("FunctionDefInvoker failed! No method to call for:"+def);
			}
			var isValid:Boolean = def.overload ? params.length >= requiredLen : params.length >= requiredLen && params.length <= defParams.length;
			if (!isValid) {
				trace("FunctionDefInvoker.invoke() Invalid no. of parameters supplied:[", params+"]", ", ["+defParams+"]", params.length+"/"+requiredLen);
				return null;
			}
			var len:int = params.length;
			var arr:Array = new Array(len);
			for (var i:int = 0; i < len; i++) {
				var value:* = params[i];
				arr[i] = value is String ? TypeHelperUtil.getType(value, defParams[i].toLowerCase()) : value;
			}
			var ret:* = methodToCall.apply(null, arr);
			return ret;
		}
		
	}

}