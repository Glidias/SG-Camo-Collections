package sg.camolite.display.impl 
{
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IListItem;
	/**
	 * Extended SelectableTextMC with the ability to set/get id and index.
	 * @author Glenn Ko
	 */
	public class SelectableMCTextItem extends SelectableMCText implements IListItem, IIndexable
	{
		
		/** @private */
		protected var _id:String;
		/** @private */
		protected var _index:int = -1;
				
		
		public function SelectableMCTextItem() 
		{
			super();
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return SelectableMCTextItem;
		}
		
		
		public function getIndex():int {
			return _index;
		}
		public function setIndex(id:int):void {
			_index  = id;
		}
		
		public function set id(str:String):void {
			_id  = str;
		}
		public function get id():String {
			return _id;
		}
		
	}

}