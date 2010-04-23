package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import sg.camo.interfaces.ITextField;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class AlignTextBehaviour extends AlignBehaviour
	{
		protected var _textField:TextField;
		public static const NAME:String = "AlignTextBehaviour";
		
		public function AlignTextBehaviour() 
		{
			
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override public function activate(targ:*):void {
			_textField = targ is ITextField ? (targ as ITextField).textField : targ is DisplayObjectContainer ? (targ as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
			if (_textField == null) throw new Error("Could not find textfield for:" + targ);
			super.activate(targ);
		}
		
		override protected function getDisplay():DisplayObject {
			return _textField;
		}
		
	}

}