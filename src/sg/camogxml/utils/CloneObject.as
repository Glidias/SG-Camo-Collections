package sg.camogxml.utils 
{
	
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CloneObject
	{
		
		public static function deepClone(source:Object):*
		{
			var myBA:ByteArray = new ByteArray();
			myBA.writeObject(source);
			myBA.position = 0;
			return(myBA.readObject());
		}
		
		public static function cloneObj(source:Object):Object {
			var retObj:Object = { };
			for (var i:String in source) {
				retObj[i] = source[i];
			}
			
			return retObj;
		}
		
		public static function cloneArr(source:Array):Array {
			var retArr:Array = new Array( source.length );
			for (var i:String in source) {
				
				retArr[i] = source[i];
			}
			
			
			return retArr;
		}
		


		
	}

}