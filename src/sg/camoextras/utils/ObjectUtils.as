package sg.camoextras.utils 
{
	
	/**
	 * Basic tracing/merging/cloning object variable utility.
	 * @author Glenn Ko
	 */
	public class ObjectUtils 
	{
		
		public static function traceObj (obj:Object):void {
			for (var i:String in obj) {
				trace (i + ": " + obj[i]);
			}
		}
		
		public static function cloneObj (toClone:Object):Object {
			var obj:Object = { };
			for (var i:String in toClone) {
				obj[i] = toClone[i];
			}
			return obj;
		}
		
		public static function mergeObj (objA:Object, objB:Object):Object {
			for (var i:String in objB) {
				objA[i] = objB[i];
			}
			return objA;
		}
		
	
		
	}
	
}