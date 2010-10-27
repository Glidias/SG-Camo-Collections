package sg.camolite.display 
{
	import flash.display.Sprite;
	import sg.camo.behaviour.SelectionBehaviour;
	import sg.camo.interfaces.ISelectioner;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GListSelection extends GListDisplay implements ISelectioner
	{
		private var _selectionBehaviour:SelectionBehaviour = new SelectionBehaviour();
		
		public function GListSelection(customDisp:Sprite=null) 
		{
			super(customDisp);
			_selectionBehaviour.activate(this);
		}
		
		/* INTERFACE sg.camo.interfaces.ISelectioner */
		
		public function set selection(str:String):void 
		{
			_selectionBehaviour.doSelection(_idHash[str]);
		}
		
		public function get curSelected():* 
		{
			return _selectionBehaviour.curSelected;
		}
		
		public function clearSelection():void 
		{
			_selectionBehaviour.clearSelection();
		}
		
		
	}

}