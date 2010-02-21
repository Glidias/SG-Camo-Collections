package sg.camogxml.utils 
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IConstructorInfo;
	
	
	
	/**
	 * Handy utility to instantiate classes and inject dependencies with ValueMap.
	 * Also uses a ITypeHelper/IPropertyMapCache implementation to attempt to convert 
	 * any string-based values from a ValueMap to the required type per application.
	 * 
	 * @see camo.core.utils.TypeHelperUtil
	 * 
	 * @author Glenn Ko
	 */
	public class ValueMapInstantiator
	{
		
		
		/**
		 * 
		 * @param	classe
		 * @param	valueMap
		 * @param	bindingMethod
		 */
		public static function instantiate(classe:Class, valueMap:ValueMap, bindingMethod:Function = null):* {
			var typeHelper:ITypeHelper = GXMLGlobals.typeHelper;
			var retTarg:*;
			var constructor:Array = valueMap.constructor;
			var setter:Object = valueMap.setter;
			
			var className:String =  getQualifiedClassName(classe);
			var constructInfo:IConstructorInfo =  ConstructorInfoCache.getConstructorInfoCache(className, classe);
			var requiredLen:int = constructInfo.constructorParamsRequired;
			
			if (constructor.length < requiredLen) {
				trace("ValueMapInstantiator.instantiate() Invalid no. of constructor parameters valueMap:[", constructor+"]", "Expected:"+requiredLen);
				return null;
			}
			var typedArray:Array = constructInfo.getTypedConstructorParams();
			var len:int = constructInfo.constructorParamsLength;
	
			if (len > 0) {
				var newArr:Array = new Array(len);
				for (var i:int = 0; i < len; i++) {
					var type:String = typedArray ?  typedArray[i] : constructor["*"+i];
					var value:* = typedArray ? constructor[type] ? constructor[constructor[type]] : getValAtIndex(constructor,i) : getValAtIndex(constructor,i);
					if (bindingMethod != null && value is String) value = bindingMethod(value);
					value = type != null? value is String ? typeHelper.getType( value, type.toLowerCase() ) : value :   value;
					newArr[i] = value;
				}
				retTarg = ConstructorUtils.instantiateClassConstructor(classe, newArr);
			}
			else retTarg = new classe();
			
			var propMapCache:IPropertyMapCache = GXMLGlobals.propertyMapCache;
			var propertyMap:Object = propMapCache.getPropertyMapCache(className) || propMapCache.getPropertyMap(classe);
			for (var prop:String in setter) {
				type = propertyMap[prop];
				if (type) {
					value = setter[prop];
					if (bindingMethod != null && value is String) value = bindingMethod(value);
					value =  value is String ? typeHelper.getType( value, type ) : value;
					retTarg[prop] = value;
				}
			}
			
			return retTarg;
		}

	
		private static function getValAtIndex(arr:Array, index:int):* {
			return index < arr.length ? arr[index] : undefined;
		}
		

		
		/**
		 * 
		 * @param	xml
		 * @return
		 */
		public static function instantiateFromXML(xml:XML, bindingMethod:Function = null):* {
			var classe:Class = xml['@class'] != undefined ? getDefinitionByName( xml['@class'].toString() ) as Class : null;
			if (classe == null) return null;
			return instantiate(classe, ValueMap.fromXML(xml), bindingMethod );
		}
		
	}

}