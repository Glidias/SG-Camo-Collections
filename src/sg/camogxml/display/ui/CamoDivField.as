package sg.camogxml.display.ui
{
	import flash.text.TextField;
	import sg.camogxml.display.CamoDivText;
	
	/**
	 * This is the base class for form fields, or textfields with fixed boundary dimensions.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivField extends CamoDivText 
	{
		
		/**
		 * CamoDivField constructor. Textfield starts WITHOUT multi-line support by default.
		 * and doesn't use autosize as text contents are restricted within the "box"'s
		 * textfield's fixed boundaries.
		 */
		public function CamoDivField() 
		{
			super();
			
			// Different conventions for CamoDivField over CamoDivText
			_textField.autoSize = "none";   
			_textField.multiline = false;   
		}
		
		override public function get reflectClass():Class {
			return CamoDivText;
		}
		
		
		
		/**
		 * Stage Instance setter that works similar to superclass implementation, but 
		 * also enforces the main camo div's width and height to match the staged textfield instance
		 * dimensions. If staged txtLabel is multiline, word wrap is automatically turned on.
		 */
		override public function set txtLabel(txtField:TextField):void {
			super.txtLabel = txtField;
			_width = txtField.width;
			_height = txtField.height;
			if (txtField.multiline) {
				super.wordWrap = true;
			}
		}
		
		
		/**
		 * Indicates whether form field requires multiline wrapping support (for message boxes and such..)
		 * Setting this to true would also automatically turn on multi-line support for the textfield. 
		 */
		override public function set wordWrap(boo:Boolean):void {
			super.wordWrap = boo;
			_textField.multiline = boo;
		}
	
		

	}

}