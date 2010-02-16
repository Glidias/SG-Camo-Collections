package sg.camogxml.display.ui 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	import sg.camogxml.display.CamoDivOpener;
	/**
	 * This is the basic list implementation of a CamoDivOpener, providing a composite
	 * IList/ITextField/IText base for menus and such, with optional text labeling.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivOpenerList extends CamoDivOpener implements IList, ITextField, IText
	{
		
		/** @private */ protected var _list:IList;
		
		/** @private  Dummy/off-stage textfield cache if required to support ITextField interface,
		 *  which holds settings to be applied to newly added textfield label on ancestor level (if available).
		 * */
		protected var _dummyField:TextField;
		
		/** @private Currently active on-stage textfield being used (if available) */
		protected var _textField:TextField;
		
		/** @private */
		protected static const NO_FORMATTING:String = "NO_FORMATTING";
		
		/** @private Text that was set earlier through IText interface 
		 * @see sg.camo.interfaces.IText
		 * */
		protected var _pendingText:String;
		
		
		public function CamoDivOpenerList() 
		{
			super();
		}
		
		override public function get reflectClass():Class {
			return CamoDivOpenerList;
		}
		
		// -- Construct
		
		/** @private */
		override protected function setDisplaySprite(spr:Sprite):Boolean {
			if ( super.setDisplaySprite(spr) ) {
				_list = spr as IList;
				//if (_list == null) throw new Error('CamoDivDropdown :: No [IList] found for display sprite:'+spr);	
				return true;
			}
			return false;
		}
		
		/** @private */
		override protected function setAncestorDisplay(disp:DisplayObject):Boolean {
			if ( super.setAncestorDisplay(disp) ) {
				var tryField:TextField  = disp is TextField ? disp as TextField : disp is ITextField ? (disp as ITextField).textField : disp is DisplayObjectContainer ? (disp as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
				
				if (tryField == null) return true;
				_textField = tryField;
				if (_dummyField) {
					// map default textformat/stylesheet/htmlText of dummy textfield over new field 
					// if required .
					if (_dummyField.defaultTextFormat.font != NO_FORMATTING) {
						tryField.defaultTextFormat = _dummyField.defaultTextFormat;
						tryField.setTextFormat(tryField.defaultTextFormat);
						//trace(tryField.defaultTextFormat.font);
					}
					if (_dummyField.styleSheet != null) {  // assume htmlText was set on dummy field
						tryField.htmlText = _dummyField.htmlText;
						tryField.styleSheet = _dummyField.styleSheet;
					}
					else if (_dummyField.text) { // assume htmlText was set on dummy field
						tryField.htmlText = _dummyField.text;
						tryField.setTextFormat( _dummyField.getTextFormat() );
					}
					_dummyField = null;
				}
				if (_pendingText) _textField.text = _pendingText;
				return true;
			}
			return false;
		}
		
		/** @private */
		protected static function createDummyField():TextField {
			var dummy:TextField = new TextField();
			dummy.defaultTextFormat = new TextFormat(NO_FORMATTING);
			return dummy;
		}
		
				
		// -- IList
		public function addListItem (label:String, id:String):DisplayObject {
			return _list.addListItem( label, id );
		}

		public function removeListItem (id:String):DisplayObject {
			return _list.removeListItem(id);
		}
		
		// -- IText
		
		/**
		 * It is assumed when setting non-htmlText over a target from external agents,
		 * this interface method is always used.
		 */
		public function set text (str:String):void {
			_pendingText = str;
			if (!_textField || _textField === _dummyField) return;
			_textField.text = str;
			_bubblingDraw = true;
			invalidate();
		}
		public function get text ():String {
			return _textField ? _textField.text : "";
		}
		
		// -- ITextField
		
		/**
		 * Retrives active textfield or dummy text field for applying htmlText, text formats, or
		 * a native Flash stylesheet reference.
		 */
		public function get textField():TextField {
			return _textField || _dummyField || ( _dummyField = createDummyField() );
		}

	
	}

}
