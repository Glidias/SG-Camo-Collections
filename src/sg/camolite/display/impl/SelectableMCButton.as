package sg.camolite.display.impl
{
	import sg.camo.interfaces.IIndexable;
	import sg.camo.interfaces.IListItem;
	import sg.camolite.display.GSelectableMC;
	/**
	 * Basic (non- labeled) selectable button with indexing and listItem id support.
	 * <br/>
	 * Uses frame 1 for non-selected state and frame 2 for selected state.
	 * 
	 * @author Glenn Ko
	 */
	public class SelectableMCButton extends GSelectableMC implements IListItem, IIndexable
	{
					
		/** @private */
		protected var _id:String;
		/** @private */
		protected var _index:int = -1;
		
		/** Flag to determine whether to automatically toggle mouseEnabled status to false when item is selected **/
		public var toggleMouseEnabled:Boolean = true;
		
		
		public function SelectableMCButton(initEventType:String=null) 
		{
			super(initEventType);
			buttonMode = true;
			stop();
		}
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return SelectableMCButton;
		}
		
		public function getIndex():int {
			return _index;
		}
		public function setIndex(id:int):void {
			_index  = id;
		}
		
		
		
		override public function set selected (bool:Boolean):void {
			super.selected = bool;
			var tarFrame:Number = bool ? 2 : 1;
			gotoAndStop(tarFrame);
			
			mouseEnabled = toggleMouseEnabled ? !bool : mouseEnabled;
		}
		
	
		
		public function set id(str:String):void {
			_id  = str;
		}
		public function get id():String {
			return _id;
		}
		
		
		
	}

}