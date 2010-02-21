package sg.camogxml.utils 
{

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import sg.camogxml.api.IConstructorInfo;
	import camo.core.utils.ClassInspect;
	
	/**
	 * Basic utility to store and retrieve constructor information on classes/instances.
	 * @author Glenn Ko
	 */
	public class ConstructorInfoCache
	{
		private static var constructorInfoMap:Dictionary = new Dictionary();	
		public static const REQUIRED_LENGTH:String = "requiredLength";
		public static const IS_TYPED_PARAMS:String = "typedParams";
		
		/**
		 * Returns a IConstructorInfo instance of a given target
		 * @param	targ	The target to scan to retrieve IConstructorInfo on the target
		 * @return	A IConstructorInfo instance or null if target has no constructor
		 * 		
		 */
		public static function getConstructorInfo(targ:*):IConstructorInfo {
			var className:String = ClassInspect.getClassName(targ); 
			return constructorInfoMap[className] || getNewConstructorInfo(className, targ);
		}
		
		/**
		 * Returns a IConstructorInfo instance, also considering className from cache if available
		 * @param	className		The	className key to retrieve from the cache
		 * @param	targ		    A backup class to scan if cached retreival fails
		 * @return
		 */
		public static function getConstructorInfoCache(className:String, targ:*):IConstructorInfo {
			return constructorInfoMap[className] || getNewConstructorInfo(ClassInspect.getClassName(targ), targ);
		}


		private static function getNewConstructorInfo(className:String, targ:*):IConstructorInfo {
			var classDesc:XML =  ClassInspect.describe(targ);
			var classe:Class = targ as Class || getDefinitionByName(classDesc.@name) as Class;
			var constructList:XMLList = classDesc.hasOwnProperty('factory') ? classDesc.factory[0].constructor : classDesc.constructor; 
			var paramList:XMLList = constructList[0].parameter
			var len:int = paramList.length();
			if (len > 0 && paramList[0].@type.toString() === "*") {
				if (classe != null) {
					ConstructorUtils.instantiateNullConstructor(classe, len )
				}
				else throw new Error("Failed to create constructor info for non-Class object. Please instantiate first:"+targ);
				classDesc = ClassInspect.describe(targ);
				constructList = classDesc.hasOwnProperty('factory') ? classDesc.factory[0].constructor : classDesc.constructor; 
				paramList = constructList[0].parameter;
			}
			var retInfo:ConstructorInfo = new ConstructorInfo(paramList);
			constructorInfoMap[className] = retInfo;
			return retInfo;
		}
		
	
		
	}

}
import sg.camogxml.api.IConstructorInfo;

internal class ConstructorInfo implements IConstructorInfo {
	
		private var _requiredLen:int;
		private var _typedParams:Array;
		private var _len:int;
	
		public function ConstructorInfo(paramList:XMLList) {
			var requiredLen:int = 0;
			var i:int;
			var pNode:XML;

			var len:int = paramList.length();

			
			var constructorParams:Array = [];
			for (i = 0; i < len; i++) {
				pNode = paramList[i];
				var type:String = pNode.@type.toString();
				constructorParams.push(type);
				requiredLen += pNode.@optional != "true" ? 1 : 0;
			}
			_typedParams = constructorParams;
			
			_len = len;
			_requiredLen = requiredLen;
		}
	
		public function get constructorParamsRequired():int {
			return _requiredLen;
		}
		public function get constructorParamsLength():int {
			return _len;
		}

		public function getTypedConstructorParams():Array {
			return _typedParams.concat(); // clone array to prevent accidental changes
		}
}