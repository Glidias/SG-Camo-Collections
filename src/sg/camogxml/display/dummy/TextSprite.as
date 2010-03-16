package sg.camogxml.display.dummy 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	/**
	 * Dummy text sprite holder reference
	 * @author Glenn Ko
	 */
	public class TextSprite extends Sprite implements ITextField, IText
	{
		private var _textField:TextField = new TextField();
		
		public function TextSprite() 
		{
	
			_textField.autoSize = "left";
			addChild(_textField);
		}
		public function get textField():TextField {
			return _textField;
		}
		public function set text (str:String):void {
			_textField.text = str;
		}
		public function get text ():String {
			return _textField.text;
		}
		
		/*
		override public function get width():Number {
			return _textField.textWidth * scaleX;
		}
		override public function get height():Number {
			return _textField.textHeight * scaleY;
		}
		*/
		
	}

}