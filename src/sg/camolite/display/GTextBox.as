package sg.camolite.display 
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;
	/**
	 * Multiline Textbox with fixed width size and dispatches draw bubble when content size changes.
	 * @author Glenn Ko
	 */
	public class GTextBox extends GBaseDisplayText
	{
		private var _autoSize:String;
		
		public function GTextBox() 
		{
			super();
		
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GTextBox;
		}
		
		
		override public function set text(str:String):void {

			super.text = str;
			

			_bubblingDraw = true;
			invalidate();
			draw();
		}

		
		public function set autoSize(str:String):void {
			_autoSize = str;
			if (_textField != null) _textField.autoSize = str;
		}
		
		override public function set txtLabel(txtField:TextField):void {
			super.txtLabel = txtField;
			_width = txtField.width;
			
			txtField.autoSize = txtField.getTextFormat().align; //TextFieldAutoSize.CENTER;
			_autoSize = txtField.autoSize;
			_textField.multiline = true;
				_textField.wordWrap = true;
			txtField.text = txtField.text;
			
		}
		
	}

}