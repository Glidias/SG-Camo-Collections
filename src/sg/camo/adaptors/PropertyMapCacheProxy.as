package sg.camo.adaptors 
{
	import sg.camo.interfaces.IPropertyMapCache;
	import camo.core.utils.PropertyMapCache;
	/**
	 * Proxy on behalf of static PropertyMapCache under Camo core
	 * @author Glenn Ko
	 */
	public class PropertyMapCacheProxy implements IPropertyMapCache
	{
		
		public function PropertyMapCacheProxy() 
		{
			
		}
		
		public function getPropertyMapCache(className:String):Object {
			return PropertyMapCache.getPropertyMapCache(className);
		}
		public function getPropertyMap(target : * ) : Object {
			return PropertyMapCache.getPropertyMap(target);
		}
		
	}

}