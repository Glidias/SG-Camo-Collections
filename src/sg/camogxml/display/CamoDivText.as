package sg.camogxml.display 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	
	/**
	 * This is the base class for all CSS/AS3-skinnable div containers that contain a nested textfield,
	 * where the div container's dimensions resizes to fit the current textfield's contents, 
	 * and line break support is provided by default.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivText extends CamoDiv implements ITextField, IText
	{
		protected var _textField:TextField;
		
		/**
		 * CamoDivText constructor. Automatically adds/set sup an autosizing-from-left 
		 * textfield with multi-line (line-break) support.
		 *
		 */
		public function CamoDivText() 
		{
			super();
			
			if (!_textField) _textField = new TextField();
			
			// Conventions for textfields inside div under CamoDivText
			_textField.autoSize = "left";   
			_textField.multiline = true; 
	
			addChild(_textField);
		}
		
		override public function get reflectClass():Class {
			return CamoDivText;
		}
		
		/**
		 * Stage/generic instance setter to set/add a textfield-based sprite that implements the ITextField interface
		 */
		public function set textSprite(spr:Sprite):void {
			var findField:TextField = spr is ITextField ? (spr as ITextField).textField : spr.getChildByName("txtLabel") as TextField;
			if ( findField ) {
				if (_textField && _textField.parent === display) {
					removeChild(_textField);
				}
				_textField = findField;
			}
			else throw new Error("CamoDivText set textSprite() failed.  Can't find textfield in sprite!");
			super.displaySprite = spr;
		}

		
		/**
		 * Stage instance setter. Considers an already-staged textfield instance (usually 
		 * with embed fonts).
		 * The staged position of the textfield is ignored and resetted to zero.
		 * If you wish to position the textfield, you need to do it manually by code
		 * or CSS through the varied padding/border settings.
		 */
		public function set txtLabel(txtField:TextField):void {
			_textField = txtField;
			txtField.x = 0;
			txtField.y = 0;
		}
		
		
		/**
		 * Turns on word wrapping to ensure text break down to next line if text exceeds
		 * width. Ensure a suitable width of the div is set for this to work well.
		 */		
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