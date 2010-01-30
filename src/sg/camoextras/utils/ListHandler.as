package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import sg.camo.interfaces.IList;
	
	
	/**
	 * Utility instance to populate an  IList class, keeping track of list items
	 * in it's own internal array list which allows for clearing of specific items
	 * by id or all of it's items.
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
		
		/**
		 * Appends items to the list by an array of labels, and auto-indexes 
		 * an id string if no accompanying id value is provided.
		 * @see sg.camoextras.utils.ListUtil  
		 * See above link for information on auto-indexing
		 * @param	arr		The array of labels to add to each list item for the IList
		 * @param 	idArray	 A matching array of accompanying id values for each list item
		 */
		public function populateByArray(arr:Array, idArray:Array=null):void {
			var len:int = arr.length;
			for (var i:int = 0; i < len; i++) {
				var ider:String = idArray != null ? i < idArray.length ? idArray[i] : null : null;
				addListItem( arr[i], ider );
			}
		}
		
		/**
		 * Appends items to the list with XMLList, and auto-indexes an id string
		 * if no 'id' attribute is supplied for each node in the list.
		 * @see sg.camoextras.utils.ListUtil  
		 * See above for information on auto-indexing
		 * @param	xmlList	 An xml list
		 */
		public function populateByXML(xmlList:XMLList):void {
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var ider:String = xml.@id != undefined ? xml.@id.toString() : String(i);
				_listArr[">"+ider] = _listArr.length;
				_listArr.push(ider);
				xml.@id = ider;
		
				_list.addListItem( xml, ider );
			}
		}
		
		/**
		 * Appends a list item to the IList.
		 * @param	label	The label value to use
		 * @param	ider	A specific id if required, else auto-indexes
		 * an  id  string based on current array's length.
		 */
		public function addListItem(label:String, ider:String=null):void {
			
			ider = ider || String((_list as DisplayObjectContainer).numChildren);
			_listArr[">"+ider] = _listArr.length;
			_listArr.push(ider);
			
		
			_list.addListItem(label , ider );
		}
		
		/**
		 * Clears entire list.
		 * @param	ascending	Whether to clear each list item in ascending order (from the
		 * head of the list).
		 * rather than the default descending order (from the tail).
		 */
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
		
		/**
		 * Clears the latest list item instance being added which belongs to a certain id
		 * @param	id	
		 * @return	The removed display object from the IList container, (if available)
		 */
		public function clearListItemById(id:String):DisplayObject {
			if (_listArr[id] == null) return null;
			var targIndex:int = _listArr[">"+id];
			_listArr.splice(targIndex, 1);
			delete _listArr[">"+id];
			return _list.removeListItem(id);
		}
		
		
		
	}

}