package sg.camo.greensock 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class EasingMethods
	{
		private static var DICT_METHODS:Dictionary = new Dictionary();
		
		public static function registerEasingMethod(methodName:String, method:Function):void 
		{
			DICT_METHODS[methodName] = method;
		}
		
		public static function getEasingMethod(methodName:String):Function {
			return DICT_METHODS[methodName];
		}
		
	}

}