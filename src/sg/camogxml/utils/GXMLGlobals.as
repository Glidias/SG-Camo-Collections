package sg.camogxml.utils 
{
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * GXML adaptor globals to set before running anything else under CamoGXML's static utlities. 
	 * Technically, such dependencies could be set through some dependency injector
	 * utility, but for simplicity's sake, I decided to provide static setters instead.
	 * 
	 */
	
	[Inject(name='', name='')]
	public class GXMLGlobals
	{
		private static var _typeHelper:ITypeHelper;
		private static var _propertyMapCache:IPropertyMapCache;
		
		/**
		 * Constructor to supply static dependencies through constructor injection.
		 * @param	typeHelper
		 * @param	propertyMapCache
		 */
		public function GXMLGlobals(typeHelper:ITypeHelper, propertyMapCache:IPropertyMapCache) {
		
			if (_typeHelper == null) _typeHelper = typeHelper
			else trace("GXMLGlobals.typeHelper already set:" + _typeHelper + " ,against:"+typeHelper)
			if (_propertyMapCache == null) _propertyMapCache = propertyMapCache;
			else trace("GXMLGlobals.propertyMapCache already set:" + _propertyMapCache + " ,against:"+propertyMapCache)
			
			trace("Currently Set GXMLGlobals:", typeHelper, propertyMapCache);
		}	
	
		public static function get typeHelper():ITypeHelper {
			if (!_typeHelper) trace("GXMLGlobals.typeHelper retrieval failed. Need to set!");
			return _typeHelper;
		}
		
		public static function get propertyMapCache():IPropertyMapCache {
			if (!_propertyMapCache) trace("GXMLGlobals.propertyMapCache retrieval failed. Need to set!");
			return _propertyMapCache;
		}

		
	}

}