package sg.camoextras.utils 
{
	import flash.utils.Dictionary;
	/**
	 * Generic utility to manage singleton references.
	 * @author Glenn Ko
	 */
	public class SingletonManager
	{
		private static var singletons:Dictionary = new Dictionary();
		
		/**
		 * Gets a singleton class instance from the cache
		 * @param	classReference
		 */
		public static function getSingleton(classReference:Class):void {
			return singletons[ classReference ] || ( singletons[ classReference ] = new classReference() );
		}
		
		/**
		 * Maps a generic interface signature reference to a particular class / value, once.
		 * Note:  For the sake of brevity, no type-checking is done. 
		 * @param	interfaceReference	The interface reference to map a singleton to.
		 * @param	value		A Class to be instantiated or an already existing value that implements
		 * 						the above interface.
		 */
		public static function mapSingletonOf(interfaceSignature:Class, value:*):void {
			if (singletons[interfaceSignature] ) {
				trace("SingletonManager Warning:: " + interfaceSignature + " already mapped to:" + value);
				return;
			}
			singletons[interfaceSignature] = value;
		}
		
		/**
		 * Retrieves singleton of a particularly mapped interface signature
		 * Note: For the sake of brevity, no type-checking is done. 
		 * @param	interfaceSignature
		 * @return
		 */
		public static function getSingletonOf(interfaceSignature:Class):* {
			var value:*  = singletons[interfaceSignature];
			return value is Class ? (singletons[interfaceSignature] = new (value as Class)()) : value;
		}
		
	}

}