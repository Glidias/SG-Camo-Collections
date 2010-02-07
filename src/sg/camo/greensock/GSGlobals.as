package sg.camo.greensock 
{
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * GS adaptor globals to set before running anything else under Greensock. This is only meant
	 * for injecting into Greensock package, since Greensock tends to rely more on
	 * statics, I felt this would be convenient where the end-user could use this
	 * to supply the assosiated interface dependencies for Greensock to perform
	 * property type conversion.
	 * 
	 */
	
	[Inject(name='', name='')]
	public class GSGlobals
	{
		private static var _typeHelper:ITypeHelper;
		private static var _propertyMapCache:IPropertyMapCache;
		
		/**
		 * Constructor to supply static dependencies through constructor injection.
		 * @param	typeHelper
		 * @param	propertyMapCache
		 */
		public function GSGlobals(typeHelper:ITypeHelper, propertyMapCache:IPropertyMapCache) {
		
			if (_typeHelper == null) _typeHelper = typeHelper
			else trace("GSGlobals.typeHelper already set:" + _typeHelper + " ,against:"+typeHelper)
			if (_propertyMapCache == null) _propertyMapCache = propertyMapCache;
			else trace("GSGlobals.propertyMapCache already set:" + _propertyMapCache + " ,against:"+propertyMapCache)
			
			trace("Currently Set GSGlobals:", typeHelper, propertyMapCache);
		}	
	
		public static function get typeHelper():ITypeHelper {
			if (!_typeHelper) throw new Error("GSGlobals.typeHelper retrieval failed. Need to set!");
			return _typeHelper;
		}
		
		public static function get propertyMapCache():IPropertyMapCache {
			if (!_propertyMapCache) throw new Error("GSGlobals.propertyMapCache retrieval failed. Need to set!");
			return _propertyMapCache;
		}

		
	}

}