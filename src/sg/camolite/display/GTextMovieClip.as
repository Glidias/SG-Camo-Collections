package sg.camolite.display {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.IResizable;
	import flash.display.Sprite;
	import sg.camo.interfaces.ITextField;

	
	/**
	* A basic MovieClip with text/textfield support.
	* <br/><br/>
	* Alsi incorporates <code>GBase</code> structure.
	* @see sg.camolite.display.GBase
	* 
	* @author Glenn Ko
	*/
	public class GTextMovieClip extends MovieClip implements IText, IResizable, ITextField, IReflectClass {
		
		protected var _textField:TextField;
		protected var _width:Number = -1;
		protected var _height:Number = -1;
		
		public function GTextMovieClip() {
			super();
		}
		
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GTextMovieClip;
		}
		
		
		public function set text(val:String):void {
			 _textField.text = val;
		}
		
		public function get text():String {
			return _textField.text;
		}
		
		public function get textField():TextField {
			return _textField;
		}
		
		
		public function set spacer(spr:Sprite):void {
			resize(spr.width, spr.height);
			spr.visible = false;
		}
		
		override public function set width(val:Number):void {
			_width = val;
		}
		
		override public function set height(val:Number):void {
			_height = val;
		}
		
		override public function get width():Number {
			return _width > -1 ? _width : super.width;
		}
		override public function get height():Number {
			return _height > -1 ? _height : super.height;
		}
		public function resize(w:Number, h:Number):void {
			_width = w > -1 ? w : _width;
			_height = h > -1 ? h : _height;
		}
		
		/**
		 * [required]<b>[Stage Instance]</b> for text field.
		 */
		public function set txtLabel(txtField:TextField):void {
			_textField = txtField;
		}
		public function get txtLabel():TextField {
			return _textField;
		}
		
	}
	
}