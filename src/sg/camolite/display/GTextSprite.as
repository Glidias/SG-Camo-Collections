package sg.camolite.display {
	import flash.display.Sprite;
	import flash.text.TextField;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.IResizable;
	import sg.camo.interfaces.ITextField;
	
	/**
	* A basic sprite with text/textfield support.
	* @author Glenn Ko
	*/
	public class GTextSprite extends GBase implements IText, ITextField{
		
		protected var _textField:TextField;

		
		public function GTextSprite() {
			_textField = _textField || addChild(new TextField()) as TextField;
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GTextSprite;
		}
		
		
		public function set text(str:String):void {
			_textField.text = str;
		}
		public function get text():String {
			return _textField.text;
		}
		
		public function get textField():TextField {
			return _textField;
		}
		
		/**
		 * [required]<b>[Stage Instance]</b> for text field.
		 */
		public function set txtLabel(txtField:TextField):void {
			_textField = txtField;
			txtField.mouseEnabled = false;
		}
		public function get txtLabel():TextField {
			return _textField;
		}
		
	}
	
}