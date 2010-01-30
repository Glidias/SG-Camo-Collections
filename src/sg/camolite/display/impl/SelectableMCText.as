package sg.camolite.display.impl {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	import sg.camolite.display.GSelectableMC;
	/**
	* Basic selectable text labeled movieclip.  <br/>
	* Uses frame 1 for unselected state, frame 2 for selected state.
	* @author Glenn Ko
	*/
	public class SelectableMCText extends GSelectableMC implements ISelectable, IText, ITextField {
		
		/** @private */
		protected var _textField:TextField;
		
		/** Flag to determine whether to automatically toggle mouseEnabled status to false when item is selected **/
		public var toggleMouseEnabled:Boolean = true;
		
		public function SelectableMCText(initEventType:String=null) {
			super(initEventType);
			buttonMode = true;
			mouseEnabled = true;
			//mouseChildren = false;
			stop();
			selected = false;
		}
		
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return SelectableMCText;
		}
		
		
		public function get textField():TextField {
			return _textField;
		}
		
			
		public function set txtLabel(val:TextField):void {
			_textField = val;
			_textField.selectable = false;
			_textField.mouseEnabled = false;
	
		}
		public function get txtLabel():TextField {
			return _textField;
		}
		
		public function set text(str:String):void {
			if (_textField != null) _textField.text = str;
		}
		public function get text():String {
			return (_textField != null)  ? _textField.text : "";
		}
		
		override public function set selected(boo:Boolean):void {
			super.selected = boo;
			var tarFrame:Number = boo ? 2 : 1;
			gotoAndStop(tarFrame);		
			
			mouseEnabled = toggleMouseEnabled ? !boo : mouseEnabled;
		}
		
	}
	
}