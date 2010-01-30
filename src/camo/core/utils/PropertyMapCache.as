package camo.core.utils 
{
	import camo.core.property.PropertyMap;
	import flash.utils.Dictionary;

	/**
	 * Central class to cache/store and retrieve PropertyMaps 
	 * @author Glenn Ko
	 */
	public class PropertyMapCache
	{
		protected static var cachedPropertyMaps : Dictionary = new Dictionary(true);
		
		/**
		 * Retrieves property map directy from cache if available based on class name, otherwise if target is supplied, 
		 * will attempt to create a new property map of the target
		 * @param	className	The classname to search from the cache
		 * @param	target		Provide a backup target to scan for if cache retrieval fails
		 * @return	An object acting as a propertymap (if available) or null if no named cached retrieval is found 
		 * 			or no backup target is specified.
		 */
		public static function getPropertyMapCache( className:String, target:*= null):PropertyMap {
			// still perform clone on cache regardless for safety
			return cachedPropertyMaps[className] ? cachedPropertyMaps[className].clone() : target!=null ? getPropertyMap(target) : null;
		}

		/**
		 * Retrieves a new property map of a target
		 * @param	target
		 * @return
		 */
		public static function getPropertyMap(target : *) : PropertyMap {
			var propMap:PropertyMap;
			
			// gets qualitifed class name first (so scan()'s describeType is only called once.)
			var className : String = ClassInspect.getClassName( target );
			
			if (!cachedPropertyMaps[className]) {
				propMap = new PropertyMap();
				var classXML : XML = ClassInspect.describe(target);
				//classXML.@name
				var factoryList:XMLList = classXML.factory;  // added support for factory node list, if found.
				var list : XMLList = factoryList.length() > 0 ? factoryList[0].* : classXML.*;
				
				var item : XML;
				for each (item in list) {
					var itemName : String = item.name().toString();
					switch(itemName) {
						case "variable":
							propMap[item.@name.toString()] = item.@type.toString();
							break;
						case "accessor":
							var access : String = item.@access;
							if ((access == "readwrite") || (access == "writeonly")) {
								propMap[item.@name.toString()] = item.@type.toString();
							}
							break;
					}
					
					cachedPropertyMaps[className] = propMap; 
				}
			} else {
				propMap = cachedPropertyMaps[className];
			}
			
			return propMap.clone() as PropertyMap; 
	
		}
		
		/**
		 * Retrieves a dictionary of saved PropertyMap values using the targets themselves as a key
		 * @param	... targets	
		 * @return
		 */
		public static function propertyMapCollection( ... targets ) : Dictionary {
			var collection : Dictionary = new Dictionary(true);
			var total : int = targets.length;
			var i : int;
			
			for (i = 0;i < total; i++) {
				collection[targets[i]] = getPropertyMap(targets[i]);
			}
			
			return collection;
		}
		
	
		
	}

}