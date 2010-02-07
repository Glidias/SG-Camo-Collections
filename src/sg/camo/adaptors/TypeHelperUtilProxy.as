package sg.camo.adaptors 
{
	import sg.camo.interfaces.ITypeHelper;
	import camo.core.utils.TypeHelperUtil;
	
	/**
	 * Proxy on behalf of static PropertyMapCache under Camo core
	 * @author Glenn Ko
	 */
	
	public class TypeHelperUtilProxy implements ITypeHelper
	{
		
		public function TypeHelperUtilProxy() 
		{
			
		}
		
		public function getType(data : String, type : String) : * {
			return TypeHelperUtil.getType(data, type);
		}
		
	}	
	

}