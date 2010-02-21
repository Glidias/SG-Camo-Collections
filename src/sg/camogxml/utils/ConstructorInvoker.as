package sg.camogxml.utils 
{
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IConstructorInfo;
	import flash.system.ApplicationDomain;
	/**
	 * Static utility to invoke classes with IConstructorInfo and accompanying string-based parameters in array format.
	 * @see sg.camogxml.api.IConstructorInfo
	 * 
	 * @author Glenn Ko
	 */
	public class ConstructorInvoker
	{
		
		
		public static function invokeClassWithInfo(classDef:Class, constructInfo:IConstructorInfo, valueParams:Array):* {
			var len:int = constructInfo.constructorParamsLength;
			var requiredLen:int = constructInfo.constructorParamsRequired;
			var typedArray:Array = constructInfo.getTypedConstructorParams();
			var classInstance:* = null;
		
		
			if (valueParams.length < requiredLen || valueParams.length > len) {
				throw new Error("ConstructorInvoker invokeClassWithInfo() failed! Invalid parameters: "+valueParams.length+"/"+requiredLen);
				return null;
			}
			
			if (len > 0) {
				var applyConstructorParams:Array = new Array(len);
	
			
				var typeHelper:ITypeHelper = GXMLGlobals.typeHelper;
				for (var i:int = 0; i < len; i++ ) {
	
					var type:String = typedArray ? typedArray[i] : null;
				
					if (type != null) type = type.toLowerCase();
				
					var value:* = type!=null ? valueParams[i] is String ? typeHelper.getType(valueParams[i],type) : valueParams[i] : valueParams[i];
					if (value == null) {
						trace("ConstructorInvoker :: warning! Resolved constructor value is null for type:"+type);
					}
					applyConstructorParams[i] = value;
				}
				classInstance = ConstructorUtils.instantiateClassConstructor(classDef, applyConstructorParams);
			}
			else  classInstance = new classDef();
			
			return classInstance;
		}
		
		public static function invoke(classe:Class, valueParams:Array):* {
			invokeClassWithInfo(classe, ConstructorInfoCache.getConstructorInfo(classe), valueParams);
		}
		
		public static function invokeWithClassName(className:String, valueParams:Array, domain:ApplicationDomain = null):* {
			var curDomain:ApplicationDomain = ApplicationDomain.currentDomain;
			var classDef:Class = domain ? domain.hasDefinition(className) ? domain.getDefinition(className) as Class : curDomain.hasDefinition(className) ? curDomain.getDefinition(className) as Class : null   : curDomain.hasDefinition(className) ? curDomain.getDefinition(className) as Class : null;
			if (classDef == null) return null;
			invokeClassWithInfo(classDef, ConstructorInfoCache.getConstructorInfoCache(className, classDef), valueParams);
		}
		
	}

}