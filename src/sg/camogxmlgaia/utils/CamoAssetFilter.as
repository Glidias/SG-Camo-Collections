package sg.camogxmlgaia.utils 
{
	import sg.camogxmlgaia.api.ISourceAsset;
	import sg.camogxmlgaia.api.IDisplayRenderAsset;
	import sg.camogxmlgaia.api.IGXMLAsset;
	import sg.camogxmlgaia.api.INodeClassAsset;
	/**
	 * Boiler-plate utility to retrieve specific asset types into an ordered array.
	 * @author Glenn Ko
	 */
	public class CamoAssetFilter
	{
		
		public static function getSourceAssets(assets:Object, list:XMLList):Array
		{
			var arr:Array = [];
			var len:int = list.length();
			var i:int = 0;
			while (i < len) {
				var a:String = list[i].@id;
				if (assets[a] is ISourceAsset) arr.push(assets[a]);
				i++;
			}
			return arr;
		}
		
		public static function getDisplayRenderAssets(assets:Object, list:XMLList):Array
		{
			var arr:Array = [];
			var len:int = list.length();
			var i:int = 0;
			while (i < len) {
				var a:String = list[i].@id;
				if (assets[a] is IDisplayRenderAsset) arr.push(assets[a]);
				i++;
			}
			return arr;
		}
		
		public static function getGXMLAssets(assets:Object, list:XMLList):Array
		{
			var arr:Array = [];
			var len:int = list.length();
			var i:int = 0;
			while (i < len) {
				var a:String = list[i].@id;
				if (assets[a] is IGXMLAsset) arr.push(assets[a]);
				i++;
			}
			return arr;
		}
		
		public static function getNodeClassAssets(assets:Object, list:XMLList):Array
		{
			var arr:Array = [];
			var len:int = list.length();
			var i:int = 0;
			while (i < len) {
				var a:String = list[i].@id;
				if (assets[a] is INodeClassAsset) arr.push(assets[a]);
				i++;
			}
			return arr;
		}
		
	}

}