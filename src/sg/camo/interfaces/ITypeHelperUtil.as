package sg.camo.interfaces 
{
	
	/**
	 * Write specific interface (not just read-only) for ITypeHelper to
	 * be able to register new data types to functions.
	 * @author Glenn Ko
	 */
	public interface ITypeHelperUtil extends ITypeHelper
	{
		function registerFunction(type:String, method:Function):void;
	}
	
}