package sg.camogxml.display 
{
	import flash.text.TextField;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CamoDivText extends CamoDiv implements ITextField, IText
	{
		protected var _textField:TextField;
		
		public function CamoDivText() 
		{
			super();
			_textField = new TextField();
			
			// Conventions for Textfields inside a DIV
			_textField.autoSize = "left";   
			_textField.multiline = true;   
	
			addChild(_textField);
		}
		
				
		public function set wordWrap(boo:Boolean):void {
			_textField.wordWrap = boo;
		}
		public function get wordWrap():Boolean {
			return _textField.wordWrap;
		}
		
		public function set text (str:String):void {
			_textField.text = str;
			if ( !maskShape && !_overflowVisible)  _bubblingDraw = true;  //
			invalidate();
		}
		public function get text ():String {
			return _textField.text;
		}
		
		override public function set width(val:Number):void {
			super.width = val;
			_textField.width  = val;
		}
		override public function set height(val:Number):void {
			super.height = val;
			textField.height = val;
		}
		
		
		public function get textField():TextField {
			return _textField;
		}
		
	}

}