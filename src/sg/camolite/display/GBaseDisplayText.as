package sg.camolite.display 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	/**
	 * Extended GBaseDisplay with textfield/text support.
	 * @author Glenn Ko
	 */
	public class GBaseDisplayText extends GBaseDisplay implements IText, ITextField
	{
		/** @private */
		protected var _textField:TextField;
		
		public function GBaseDisplayText(customDisp:Sprite = null) 
		{
			super(customDisp);
			if (_textField != null && !_textField.parent) addChild(_textField);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GBaseDisplayText;
		}
		
		public function set txtLabel(txtField:TextField):void {
			_textField = txtField;
		}
		
		public function  get textField():TextField {
			return _textField;
		}
		
		public function set text (str:String):void {
			_textField.text = str;
		}
		public function get text ():String {
			return _textField.text;
		}
		
	}

}