package sg.camoextras.utils 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class StringUtils
	{
		
		public static function splitTypeFromSource(value : String) : Object 
		{
			var obj : Object = new Object( );
			// Pattern to strip out ',", and ) from the string;
			var pattern : RegExp = RegExp( /[\'\)\"]/g );// this fixes a color highlight issue in FDT --> '
			// Fine type and source
			var split : Array = value.split( "(" );
			//
			obj.type = split[0];
			obj.source = split[1].replace( pattern, "" );
			
			return obj;
		}
		
		
		
	}

}