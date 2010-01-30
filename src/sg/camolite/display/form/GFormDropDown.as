package sg.camolite.display.form {
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.text.TextField;
	import sg.camo.events.SelectionEvent;
	import sg.camo.interfaces.IFormElement;
	import flash.events.MouseEvent;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.behaviour.FormFieldBehaviour;
	import sg.camolite.display.GDropDown;
	
	/**
	* Extended UI dropdown class to include form element implementation.
	* 
	* @author Glenn Ko
	*/
	public class GFormDropDown extends GDropDown implements IFormElement  {
	
		/** @private */
		protected var _key:String = "";
		
		/**
		 * The composed form field behaviour for the dropdown display text label zone.
		 */
		protected var _formFieldBehaviour:FormFieldBehaviour;
		
		
		/**
		 * Constructor. Sets up form field behaviour over dropdown display text label (if found).
		 */
		public function GFormDropDown() {
			super();
			if (_textField != null) {
				_formFieldBehaviour = new FormFieldBehaviour();
			
				_formFieldBehaviour.activate(_textField);
				_textField.mouseEnabled = false;
				//_formFieldBehaviour.defaultMsg = _textField.text;
			}
			
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GFormDropDown;
		}
		

		override public function destroy():void {
			super.destroy();
			if (_formFieldBehaviour) {
				_formFieldBehaviour.destroy();
				_formFieldBehaviour = null;
			}
		}

		
		
		protected function errorHandler (e:Event):void {
			showError (true);
		}
		
		/**
		 * Attached form field behaviour (if any) will show any errors.
		 * <br/> Also dispatches non-bubbling "errorFormat" or "defaultFormat" events
		 * in response to error state.
		 * @param	bool	The error state. True for errors, false for no more errors.
		 */
		public function showError (bool:Boolean = true):void {
			if (_formFieldBehaviour) {
				_formFieldBehaviour.showError(bool);
			}
			
			if (bool) {
				
				dispatchEvent (new Event ("errorFormat"));
			}
			else {

				dispatchEvent (new Event ("defaultFormat"));
			}
		}
	
		/**
		 * Resets current selection and reverts back to default text
		 */
		public function resetValue ():void {
			if (_curSelected != null) {
				(_curSelected as ISelectable).selected = false;
				_curSelected = null;
			}
			_formFieldBehaviour.resetValue();
		}
	
		public function set value (val:String):void {
			text = val;
		}
		public function get value ():String {
			return _curSelected is IFormElement ? (_curSelected as IFormElement).value : _curSelected is IListItem ? (_curSelected as IListItem).id : _curSelected.name;
		}
		public function set key (val:String):void {
			_key = val;
		}
		public function get key ():String {
			return _key ? _key : name;
		}
		
		
		public function isValid ():Boolean {
			return _curSelected != null; 
		}
		
	
		
		
		
		
	}
	
}