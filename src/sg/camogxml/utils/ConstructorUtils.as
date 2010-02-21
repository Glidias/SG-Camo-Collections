package sg.camogxml.utils 
{
	import flash.utils.Dictionary;
	/**
	 * Basic utility to handle rudimentary constructor-related operations.
	 * 
	 * @author Glenn Ko
	 */
	public class ConstructorUtils
	{
		
		/**
		 * Instantiates a class with supplied constructor parameters in array. 
		 * Only supports up to 9 parameters.
		 * @param	classe		The class to instantiate
		 * @param	params		The array of values for the constructor parameters
		 * @return
		 */
		public static function instantiateClassConstructor(classe:Class, params:Array):* {
			var len:int = params.length;
			switch (len) {
				case 0: return new classe();
				case 1: return new classe(params[0]);
				case 2: return new classe(params[0],params[1]);
				case 3: return new classe(params[0], params[1], params[2]);
				case 4: return new classe(params[0],params[1],params[2],params[3]);
				case 5: return new classe(params[0],params[1],params[2],params[3],params[4]);
				case 6: return new classe(params[0],params[1],params[2],params[3],params[4],params[5]);
				case 7: return new classe(params[0],params[1],params[2],params[3],params[4],params[5],params[6]);
				case 8: return new classe(params[0],params[1],params[2],params[3],params[4],params[5],params[6],params[7]);
				case 9: return new classe(params[0],params[1],params[2],params[3],params[4],params[5],params[6],params[7],params[8]);
				default: break;
			}
			throw new Error("ConstructorUtils.instantiateClassConstructor failed() Doesn't support more than 9 parameters in constructor!");
			return null;
		}
		
		/**
		 * Creates a throw-away instance of a class to facilitate constructor info retrieval
		 * @param	classe
		 * @param	paramLen	The length of null values to supply to the constructor parameters
		 */
		public static function instantiateNullConstructor(classe:Class, paramLen:int):void {
			var arr:Array = new Array(paramLen);
			var i:int = arr.length;
			while (--i > -1) {
				arr[i] = null;
			}
			instantiateClassConstructor(classe, arr);
		}
		
		
		
	}

}