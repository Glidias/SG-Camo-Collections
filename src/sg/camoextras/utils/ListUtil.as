package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IList
	/**
	 * Utility to inject an XMLList into IList implementations, objects, or array.
	 * <br/><br/>
	*
	 * @author Glenn Ko
	 */
	public class ListUtil
	{
		/**
		 * Populates IList with XMLList. 
		 * @param	list
		 * @param	xmlList	 An xml list
		 */
		public static function populateByXML(list:IList, xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = Boolean(String(xml.@id)) ? String(xml.@id) : String(i);
				xml.@id = ider;
				
				list.addListItem( xml, ider );
			}
		}
		
		/**
		 * Populates IList with XMLList recursively
		 * @param	list
		 * @param	xmlList
		 */
		public static function populateByXMLRecurse(list:IList, xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = Boolean(String(xml.@id)) ? String(xml.@id) : String(i);
				xml.@id = ider;
				
				var lister:IList = list.addListItem( xml, ider ) as IList;
				if (lister != null) populateByXMLRecurse(list, xml.*);
			}
		}
		
		/**
		 * Populates generic Object with XMLList
		 * @param	obj
		 * @param	xmlList
		 */
		public static function populateObjByXML(obj:Object, xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = Boolean(String(xml.@id)) ? String(xml.@id) : String(i);
				xml.@id = ider;
				obj[ider] = xml;
			}
		}
		
		/**
		 * 
		 * @param	arr
		 * @param	xmlList
		 */
		public static function populateArrayByXML(arr:Array, xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = Boolean(String(xml.@id)) ? String(xml.@id) : String(i);
				xml.@['id'] = ider;
			
				arr[i] = xml;
			}
		}
		
	}

}