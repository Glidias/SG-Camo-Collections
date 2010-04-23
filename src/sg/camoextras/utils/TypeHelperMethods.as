package sg.camoextras.utils 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TypeHelperMethods
	{
		
		public static function stringToObject(data : String, dataDelimiter : String = "," ,propDelimiter : String = ":") : * 
		{
			var dataContainer : Object = {};

			var list : Array = data.split( dataDelimiter );

			var total : Number = list.length;

			for (var i : Number = 0; i < total ; i ++) 
			{
				var prop : Array = list[i].split( propDelimiter );
				
				dataContainer[prop[0]] = prop[1];
			}
			
			return dataContainer;
		}
		
	}

}