package sg.camogxml.utils 
{

	import flash.utils.Dictionary;
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
			var gotTypedParameters:Boolean = classDesc.method.(@name == 'constructorParams').length() > 0;
			var constructList:XMLList = gotTypedParameters ? classDesc.method.(@name=='constructorParams') : classDesc.hasOwnProperty('factory') ? classDesc.factory[0].constructor : classDesc.constructor;  //factory[0].
			if ( constructList.length() < 1 ) return null;
			var retInfo:ConstructorInfo = new ConstructorInfo(constructList, gotTypedParameters);
			constructorInfoMap[className] = retInfo;
			return retInfo;
		}
		
	}

}
import sg.camogxml.api.IConstructorInfo;

internal class ConstructorInfo implements IConstructorInfo {
	
		private var _requiredLen:int;
		private var _typedParams:Array = null;
		private var _len:int;
	
		public function ConstructorInfo(constructList:XMLList, gotTypedParameters:Boolean) {
			var requiredLen:int = 0;
			var i:int;
			var pNode:XML;
			var paramList:XMLList = constructList[0].parameter
			var len:int = paramList.length();

			
			if (gotTypedParameters) {
				var constructorParams:Array = [];
				for (i = 0; i < len; i++) {
					pNode = paramList[i];
					constructorParams.push(pNode.@type.toString());
					requiredLen += pNode.@optional != "true" ? 1 : 0;
				}
				_typedParams = constructorParams;
			}
			else {
				paramList = constructList[0].parameter;
				for (i = 0; i < len; i++) {
					pNode = paramList[i];
					if (pNode.@optional.toString() === "true") break;
					requiredLen++;
				}
			}
			
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
			return _typedParams ? _typedParams.concat() : null; // clone array to prevent accidental changes
		}
}