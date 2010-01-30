package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IList
	/**
	 * Static utility to inject XMLList contents into an IList, Object, or Array.
	 * <br/><br/>
	 * This utility also performs auto-ID-indexing of all nodes in the XMLList if no id attribute is found
	 * for any node,
	 * thus automatically creating a new id attribute for the node matching the current processing index of the XMLList.
	 * <br/>
	 * 
	 * @example <code>
	 * 				<xml>
	 * 					<item>Item 1</item>
	 * 					<item>Item 2</item>
	 * 					<item id="item3">Item 3</item>
	 * 					<item>Item 4</item>
	 * 				</xml>
	 * 			</code> would result in:
	 * <code>
	 * 		<xml>
	 * 			<item id="0">Item 1</item>
	 * 			<item id="1">Item 2</item>
	 *  		<item id="item3">Item 3</item>
	 * 			<item id="3">Item 4</item>
	 * 		</xml>
	 * </code>
	 * @author Glenn Ko
	 */
	public class ListUtil
	{
		/**
		 * Populates IList with XMLList, and performs auto-ID indexing if id attribute is found per node.
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
		 * Populates IList with XMLList recursively, and performs auto-ID indexing if no id attribute is found per node.
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
		 * Populates generic Object with nodes belonging to an XMLList, assosiating each string id
		 * of each xml node as the key to the object's xml data. If no id attribute is found in the node, 
		 * auto-ID indexing  is performed.
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
		 * Populates an array with nodes belonging to a XMLList in ascending order, 
		 * and auto-ID-indexes XMLList nodes with a new id attribute if no id attribute is found.
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