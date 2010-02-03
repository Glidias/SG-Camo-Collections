package sg.camo.greensock 
{
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class EasingMethodsUtils
	{
		
		public static function registerEasingMethods(classe:Class):void {
			var classDesc:XML = describeType(classe);
			var baseClassName:String = getQualifiedClassName(classe).split("::").pop();
			var methodList:XMLList = classDesc.method;
			for each(var methodXML:XML in methodList) {
				var methodName:String = methodXML.@name;
				trace(baseClassName + "." + methodName );
				EasingMethods.registerEasingMethod(baseClassName + "." + methodName , classe[methodName]);
			}
		}
		
	}

}