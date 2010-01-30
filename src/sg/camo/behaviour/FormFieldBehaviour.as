package sg.camo.behaviour {
	import sg.camo.form.FormValidator;
	import flash.text.TextField;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IFormElement;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import sg.camo.interfaces.ITextField;

	
	
	/**
	* Decorates a TextField (or ITextField) with FormFieldBehaviour to be able to receive form-field focus events and be hooked up with various form-field settings to support individual form-field validation.
	* <br/><br/>
	* The FormFieldBehaviour implements the IFormElement interface and acts as the form element himself
	* on behalf of the Textfield instance, and is useful for hooking itself up to IForm instances. 
	* <br/><br/>
	* Note, however, that the behaviour doesn't change the text field's type or it's selectable/mouseEnabled/singleLine status. 
	* You still have to manually set such properties beforehand on the Flash stage or by code since certain form fields 
	* might be hidden or non-selectable (ie. locked) in real-life situations.
	* <br/><br/>
	* A useful time-saving feature with FormFieldBehaviour includes using the staged instance name and delimiters/prefixes within
	* your textfield's text content to automatically set up various common settings that may come with form fields.
	* By default, it uses the current text content found in the textfield during activation as the default message
	* text. However, if you wish to set another error text message to display as well, you can do so using the following format.
	* <br/><br/>eg.<br/>
	* <code>
	* // Hooks up a text field with a key of "sender_email", a fieldType of "email", including default text and error text<br/>
	* var senderEmailField:TextField = new TextField(); <br/>
	* senderEmailField.type = TextFieldType.INPUT;<br/>
	* senderEmailField.name = "sender_email$email";  // "$" splits key with fieldType.<br/>
	* senderEmailField.text =  "!--Please enter your email&--You must enter a valid email!"<br/>
	* var formFieldBehaviour:FormFieldBehaviour = new FormFieldBehaviour();<br/>
	*  formFieldBehaviour.activate( senderEmailField ); <br/>
	* </code>
	* <br/><br/>
	* On a sidenote, an OPTIONAL_PREFIX can be used "&#126;&#126;&#126;" as well on the textfield to explictly mark it as an optional field.
	* <br/>eg.<br/>
	* <code>
	* senderEmailField.text = "&#126;&#126;&#126;!--Please enter email if you wish&--The email format you entered is invalid!";
	* </code>
	* <br/>
	*  In many cases for Flash design, designers can easily set up the forms by already placing in the input fields' text and IFormElements
	* with the correct naming/labeling conventions. This allows common form functionality to be hooked up automatically through such shortcut notations.
	* 
	* @see sg.camo.interfaces.IForm
	* @see sg.camo.behaviour.FormBehaviour
	* @see sg.camolite.display.form.GForm
	* 
	* @author Glenn Ko
	*/
	public class FormFieldBehaviour implements IBehaviour, IFormElement, ITextField {
		
		protected var _targField:TextField;
		
		protected var _key:String = "";
		
		
		/** @private */protected var _activated:Boolean = false;
		private var prevInput			:String;						//-- the string that was previously in the input field
		private var initialTxt			:String;						//-- initial display txt
		private var _defaultTxtFormat	:TextFormat;
		private var _errorTxtFormat		:TextFormat;
		private var isPassword:Boolean = false;
		/** @private */protected var _type:String;
		private var _optional:Boolean = false;
		
		/** Default text to display in textfield when left empty */
		public var defaultMsg			:String = "Enter field";		
		/** Default text to display in textfield when error occurs during validation */
		public var errorMsg		:String = "Error msg";				
		
		
		public static const FOCUS_IN:String = "formFieldBeh_focusIn";
		public static const FOCUS_OUT:String = "formFieldBeh_focusOut";
		
		/**
		 *  Default instantiation value. Sets default error textformat to use for all textfields.
		 */
		public static var DEFAULT_ERROR_FORMAT:TextFormat = new TextFormat(null, null, 0xFF0000);
		/**
		 * Default instantiation value. Flag to determine if FormFieldBehaviour automatically sets maximum characters when "fieldType" is set.
		 */
		public static var AUTO_SET_MAXCHARS:Boolean = false;
		
		// Delimiters to identify settings (quick notation for Flash-based staged textfields)
		public static const OPTIONAL_PREFIX:String = "~~~";
		public static const DEFAULT_MSG_DELIMITER:String = "!--";
		public static const ERROR_MSG_DELIMITER:String = "&--";
		
		/** @private */
		protected var _autoSetMaxChars:Boolean;
		
		
		public function FormFieldBehaviour() {
			_autoSetMaxChars = AUTO_SET_MAXCHARS;
			_errorTxtFormat = DEFAULT_ERROR_FORMAT != null  ? DEFAULT_ERROR_FORMAT : null;
		}
		
		/**
		 * Overwrites default setting of AUTO_SET_MAX_CHARS.
		 */
		public function set autoSetMaxChars(boo:Boolean):void {
			_autoSetMaxChars = boo;
		}
		public function get autoSetMaxChars():Boolean {
			return _autoSetMaxChars;
		}
		
		/**
		 * ITextField method to retreive targetted textfield instance.
		 */
		public function get textField():TextField {
			return _targField;
		}
		
		
		public function get behaviourName():String {
			var suffix:String = _targField != null ? "_" + _targField.name : "";
			return "FormFieldBehaviour"+suffix;
		}
		
		/**
		 * Activates TextField or ITextField instance
		 * @param	targ	A valid TextField or ITextField instance.
		 */
		public function activate(targ:*):void {
			if (_activated) {
				return;
			}
			var target:TextField = targ is TextField ? targ as TextField : targ is ITextField ? (targ as ITextField).textField : null;
			if (target == null) {
				trace("FormFieldBehaviour activate() halt. targ as TextField is null!");
			}
			_activated = true;
			_targField = target;
			
			//trace("Activating new:"+_targField.name);
			
			_targField.addEventListener(FocusEvent.FOCUS_IN, focusInHandler, false, 0, true);
			_targField.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, false, 0, true);
			
			errorMsg = "Error Msg"; 
			prevInput = "";	// to restore back prev inputted value after error message is shown
			
			// can be set manually if you wish via setDefaultSettings()  or through delimiters
			defaultMsg = "Default Msg";
			initialTxt = _targField.text;
			_defaultTxtFormat = _defaultTxtFormat == null ? _targField.getTextFormat() : _defaultTxtFormat;
			
			

			// prefixes to identify settings
			_optional = ( initialTxt.substr(0, 3) == OPTIONAL_PREFIX );
			// through delimiters
			var searchIndex:int;
			searchIndex = initialTxt.search(DEFAULT_MSG_DELIMITER);
			defaultMsg = (searchIndex > -1) ? initialTxt.substr(searchIndex+3).split(ERROR_MSG_DELIMITER)[0] : _targField.text;
			searchIndex = initialTxt.search(ERROR_MSG_DELIMITER);
			errorMsg = (searchIndex > -1) ? initialTxt.substr(searchIndex+3) : defaultMsg;
			
			initialTxt = (_optional ) ? initialTxt.substr(3): initialTxt;	
			initialTxt = (defaultMsg != "" ) ? initialTxt.substr(3): initialTxt;
			initialTxt = (initialTxt.search(ERROR_MSG_DELIMITER) > -1) ? initialTxt.split(ERROR_MSG_DELIMITER)[0] : initialTxt;
			_targField.text = initialTxt;
	
			if (!Boolean(_key) ) {
				var nameSplit:Array = target.name.split("$");
				_key = nameSplit[0];
				if (nameSplit.length < 1) return;
				fieldType = nameSplit[1];
			}
			
			reset();
		}
		

		
		private function focusInHandler(e:FocusEvent):void {
			if (_targField.text == defaultMsg) _targField.text = "";
			if (_targField.text== errorMsg) _targField.text = prevInput;
			_targField.displayAsPassword = isPassword;
			_targField.dispatchEvent(new Event(FOCUS_IN, true, false) );
		}
		
		private function focusOutHandler(e:FocusEvent):void {
			if (_targField.text == "") reset();
			_targField.dispatchEvent(new Event(FOCUS_OUT, true, false) );
		}
		
		public function destroy():void {
			if (_targField == null ) return;
		
			_targField.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler, false);
			_targField.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, false);

		}
		
		protected function resetTextField():void {
			if (_defaultTxtFormat!=null) _targField.setTextFormat(_defaultTxtFormat);
			if (defaultMsg != "") {
				_targField.text = defaultMsg;
				_targField.displayAsPassword = false;
			}
		}
		
		/**
		 * Re-sets default text format to use  for textfield to a new value.
		 */
		public function set defaultTxtFormat(txtFormat:TextFormat):void {
			_defaultTxtFormat = txtFormat;
		}
		
		/**
		 * Re-sets text format to use when for textfield when errors occur during validation.
		 */
		public function set errorTxtFormat(txtFormat:TextFormat):void {
			_errorTxtFormat = txtFormat;
		}
		
		
			
		public function set key(val:String):void {
			_key = val;
		}
		
		public function get key():String {
			return _key;
		}
		
		public function reset():void {
			resetValue();
		}
		

		public function showError(bool:Boolean=true):void {
			var chkTxt:String;
			if (bool) {
				if (errorMsg != "") {
					chkTxt = _targField.text;
					_targField.text = errorMsg;
				}
				if (_errorTxtFormat != null) {
					_targField.setTextFormat(_errorTxtFormat);
					//_targField.defaultTextFormat = _errorTxtFormat;
				}
				
			}
			else {
				if (prevInput != "" && prevInput != defaultMsg)  {
					_targField.text = prevInput; 
				}
				if (_defaultTxtFormat != null) {
					_targField.setTextFormat(_defaultTxtFormat);
					_targField.defaultTextFormat = _defaultTxtFormat;
					
				}
			}
		}
		
		public function isValid():Boolean {
			if (_targField.text == errorMsg && errorMsg!=defaultMsg ) return false;
			if (_targField.text == initialTxt && !_optional ) return false;
			if (_targField.text == defaultMsg && !_optional ) return false;
			if (_targField.text == "" && !_optional ) return false;
			
			switch(_type){
				case "email":
					if  ( value =="" && _optional) return true;
					return FormValidator.isValidEmail(_targField.text);
					
				case "url":
					if  ( value =="" && _optional) return true;
					return FormValidator.isValidURL(_targField.text);
				case "name":
					return true; // assume restrict solves it
				
					
				case "number":
					if (value == "" && _optional) return true;
					return FormValidator.isValidNumber(_targField.text);
					
					
				case "password":
					return true;	// assume restrict solves it
					
					
				default:		
					break;
			}

			return true;
			
		}
		
		public function set value(val:String):void {
			_targField.text = val;
		}
		public function get value():String {
			return  _targField.text != defaultMsg ?  _targField.text : "";
		}



		public function resetValue():void {
			resetTextField();
			showError(false);
		}
		
		
		private function getRestrictType(charTypeNum:int):String{
			var eString:String = "";
			
			switch(charTypeNum){
				case 1:
					eString = "a-z";
					break;
				case 2:
					eString = "A-Z";
					break;
				case 3:
					eString = "0-9";
					break;
				case 4:
					eString = "/'~`!@#$%\\^&*()_+\\-=\\\"<>?:;,.{}[]|\\\\";
					break;
				default:
			}
			
			return eString;
		}
		
		/** @private */
		protected function setRestrict(toInclude:Boolean, sAlphabet:Boolean, bAlphabets:Boolean, numerics:Boolean, symbols:Boolean, chars:String=""):void{
			var restrictString:String = "";
			var argumentNum:int = arguments.length;
			if (chars == "") argumentNum--;
			
			if(!toInclude) restrictString = "^";
			for(var i:int=1; i<argumentNum; i++){
				if(i != 5){
					restrictString +=  ( arguments[i] ) ?  getRestrictType(i) : "";
				}
				else {
					restrictString += chars;
				}
			}
			
			_targField.restrict = restrictString;
		}
		
		/**
		 * Sets field type to determine textfield charset restrictions.
		 * <br/>(And possibly maximum characters if AUTO_SET_MAX/autoSetMaxChars is set to true.). 
		 * <br/><br/>
		 * Accepted values are: <br/>
		 * - <code>"email"</code> : valid email characters without spaces, 60 chars <br/>
		 * - <code>"url"</code> : valid url characters without spaces, 80 chars <br/>
		 * - <code>"name"</code> : single word name format without spaces, numbers, or symbols, 30 chars <br/>
		 * - <code>"nameUpper"</code> : single word name format as above allowing only upper-case letters, 30 chars <br/>
		 * - <code>"number"</code> : email characters, 20 chars <br/>
		 * - <code>"fullname"</code> :  full name format allowing spaces, 40 chars <br/>
		 * - <code>"fullnameUpper"</code> : full name format allowing spaces and only upper-case letters, 40 chars <br/>
		 * - <code>"msg"</code> : All sorts of characters and spaces allowed here, 150 chars <br/>
		 */
		public function set fieldType(str:String):void {
			if (_targField == null) {
				_type = str;
				return;
			}
			setType(str);
		}
		
		
		/**
		 * @private
		 * @param	type
		 * @param	maxChar
		 */
		protected function setType(type:String, maxChar:int = 0):void {
			_type = type;
			var setMaxChar:int;
			switch(type){
				case "email":
					setRestrict(true, true, false, true, false, "@.\\-_");
					setMaxChar = 60;
					break;
				case "url":
					setRestrict(true, true, true, true, false, "//.:-_");
					setMaxChar = 80;
					break;
				case "name":
					setRestrict(true, true, true, false, false);
					setMaxChar = 30;
					break;
				case "nameUpper":
					setRestrict(true, false, true, false, false);
					setMaxChar = 30;
					break;
				case "number":
					setRestrict(true, false, false, true, false);
					setMaxChar = 20;
					break;
				case "password":
					setRestrict(true, true, true, true, false, " .\\-_");
					setMaxChar = 25;
					isPassword = true;
					break;
				case "fullname":
					setRestrict(true, true, true, false, false, " ");
					setMaxChar = 40;
					break;
				case "fullnameUpper":
					setRestrict(true, false, true, false, false, " ");
					setMaxChar = 40;
					break;
				case "msg":
					setRestrict(true, true, true, true, true, " ");
					setMaxChar = 150;
					break;
				default:
					setMaxChar = 40;
					break;
				}
				if (!_autoSetMaxChars) return;
				_targField.maxChars = (maxChar < 1) ? setMaxChar : maxChar;
		}
		
	}
	
}