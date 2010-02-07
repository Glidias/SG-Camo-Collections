package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IList;
	

	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ListHandler
	{
		private var _list:IList;
		private var _listArr:Array = [];
		
		public function ListHandler(list:IList) 
		{
			_list = list;
		}
		
		public function clearList(ascending:Boolean = false):void {
			var i:int;
			var arr:Array = _listArr;
			var len:int = arr.length;
			if (ascending) {
				for (i = 0; i < len ; i++) {
					_list.removeListItem( arr[i]);
				}
			}
			else {
				i = len;
				while (--i > -1) {
					_list.removeListItem( arr[i] );
				}
			}
			_listArr = [];
		}
		
		public function get length():int {
			return _listArr.length;
		}
		
		public function clearListItemById(id:String):DisplayObject {
	
			var targIndex:int = _listArr.indexOf(id);
			if (targIndex < 0) {
				trace("ListHandler clearListItemById: No assosiated id:"+id);
				return null;
			}
			_listArr.splice(targIndex, 1);
			return _list.removeListItem(id);
		}
		
		
		/**
		 * Populates list with XMLList and stores own hash of ids for removal later
		 * @param	xmlList	 An xml list
		 */
		public function populateByXML(xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = xml.@id != undefined ? xml.@id.toString() : String(i);
				_listArr.push(ider);
				xml.@id = ider;
		
				_list.addListItem( xml, ider );
			}
		}
		
		
	}

}