package camo.core.utils 
{
	/**
	 * Additional methods to convert inner property strings of converted Objects
	 * or Arrays from TypeHelperUtil to specific data types.
	 * 
	 * @author Glenn Ko
	 */
	public class ArrayObjectTypeHelper
	{
		
		public static function getNumericObject(str:String):Object {
			var val:Object = TypeHelperUtil.stringToObject(str);
			for (var i:String in val) {
				val[i] = Number(val[i]);
			}
			return val;
		}
		
		public static function getNumericArray(str:String):Array {
			var val:Array = TypeHelperUtil.stringToArray(str);
			for (var i:String in val) {
				val[i] = Number(val[i]);
			}
			return val;
		}
		
		public static function getNumberedObjectArray(str:String):Array {
			var val:Array = TypeHelperUtil.stringToArray(str);
			for (var i:String in val) {
				val[i] = getNumericObject(str);
			}
			return val;
		}
		
		public static function  getUintObject(str:String):Object {
			var val:Object = TypeHelperUtil.stringToObject(str);
			for (var i:String in val) {
				val[i] = TypeHelperUtil.stringToUint(val[i]);
			}
			return val;
		}
		
	}

}