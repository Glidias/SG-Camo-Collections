package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IFormElement;
	import sg.camo.interfaces.IForm;
	import flash.display.DisplayObjectContainer;
	import flash.net.URLVariables;
	import flash.text.TextFieldType;
	
	
	/**
	* Standard form behaviour to hook up a  DisplayObjectContainer (such as a Sprite/MovieClip) to act as a form. 
	* <br /> <br />
	* Searches the target DisplayObjectContainer's display list for any possible input fields that can be hooked up as form elements. 
	* <br /><br />
	* All found input textfields are immediately hooked up with FormFieldBehaviours and registered 
	* to the form with various settings using certain naming conventions (see FormFieldBehaviour below). <br />
	* <br />
	* All other instances implementing the IFormElement interfaces are registered to the form as well, using
	* the staged instance name as the key. 
	* <br /><br />
	* (Note: The display list search isn't recursive ).
	* 
	* @see sg.camo.behaviour.FormFieldBehaviour
	* @see sg.camolite.display.form.GForm
	* 
	* @author Glenn Ko
	*/
	public class FormBehaviour implements IBehaviour, IForm {
		
		public static const NAME:String = "FormBehaviour";
		
		/** Flag to determine whether to highlight all errors during validation <br/>
		 * Defaulted to true. <br/><br/>If set to false, FormFieldBehaviour will not perform full validation once a form element is found invalid.
		*/
		public var highlightErrors:Boolean = true;
		
		/** hash of registered IFormElements */
		protected var formHash:Object = { }; 
		
		/**Borrowed from FormFieldBehaviour.FOCUS_IN*/
		public static const FIELD_FOCUS_IN:String = FormFieldBehaviour.FOCUS_IN;
		/**Borrowed from FormFieldBehaviour.FOCUS_OUT*/
		public static const FIELD_FOCUS_OUT:String = FormFieldBehaviour.FOCUS_OUT;
		
		/**
		 * Constructor
		 */
		public function FormBehaviour() {
			
		}
		
		/**
		 * Class-specific public method to retrieve Object hash containing all IFormElement references.
		 * Useful for retrieving form elements by key.
		 * @return	An object hash of [IFormElement.keys] pointing to IFormElement instances. <br /> 
		 * eg.  <br/>
		 * <code>
		 * 	var obj:Object = (getBehaviour(FormBehaviour.NAME) as FormBehaviour).getFormHash();<br />
		 *  var findFormElement:IFormElement =  obj["firstname"] as IFormElement;<br />
		 *  trace(findFormElement);  // traces IFormElement hopefully....<br />
		 *  if (findFormElement!=null) trace(findFormElement.value);<br />
		 *  // assuming form element is DisplayObject
		 *  (findFormElement as DisplayObject).visible = false;
		 * </code>
		 */
		public function getFormHash():Object {
			return formHash;
		}
		
		// -- IBehaviour
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates a sole DisplayObjectContainer instance to run a search of all input fields and IFormElements 
		 * in it's display list to register them.
		 * 
		 * @param	targ	A valid DisplayObjectContainer
		 */
		public function activate(targ:*):void {
			var dispCont:DisplayObjectContainer = targ as DisplayObjectContainer;
			if (dispCont == null) {
				trace("FormBehaviour activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}
			var i:int = -1; 
			var limit:int = dispCont.numChildren;
			var indexCount:int = 0;
			while (++i < limit) {
				var chkChild:DisplayObject = dispCont.getChildAt(i);
				
				var formElement:IFormElement = chkChild as IFormElement;
				var spr:Sprite = chkChild as Sprite;
				if (spr != null) spr.tabEnabled = false;
				
				if (formElement == null) {
					if (chkChild is TextField) {
						if ( (chkChild as TextField).type == TextFieldType.INPUT ) {
							var beh:FormFieldBehaviour = new FormFieldBehaviour();
							beh.activate(chkChild);
							(chkChild as TextField).tabEnabled = true;
							(chkChild as TextField).tabIndex = indexCount;
							indexCount++;
							addFormElement(beh);
						}
					}
					continue;
				}
				addFormElement(formElement);
			}
		}
		
		// -- IForm
		
		/**
		 * Performs validation of form.
		 * @return	(Boolean)  Whether all form values are completely valid.
		 */
		public function validate ():Boolean {
			var gotWrong:Boolean = false;
			for  (var i:String in formHash) {
				var formElement:IFormElement = formHash[i] as IFormElement;
				if ( !formElement.isValid() ) {
					if ( highlightErrors) {
						formElement.showError(true);
					}
					else {
						return false;
					}
					gotWrong = true;
				}
				else {
					formElement.showError(false);
				}
			}
			return !gotWrong;
		}
	
		/**
		 * Resets all form elements back to their default values
		 */
		public function resetAll ():void {
			for  (var i:String in formHash) {
				var formElement:IFormElement = formHash[i] as IFormElement;
				formElement.resetValue();
			}
		}
		/**
		 * Registers a new form element directly into the form.
		 * @param	targ	An IFormElement instance
		 */
		public function addFormElement (targ:IFormElement):void {
			formHash[targ.key] = targ;
		}
		
		/**
		 * Retrieves URL variables from form
		 * @return	(URLVariables)  A URLVariables object containing name-value pairs of all registered form elements in "key:value" format.
		 */
		public function getURLVariables():URLVariables {
			var urlVars:URLVariables = new URLVariables();
			for (var i:String in formHash) {
				urlVars[i] = formHash[i].value;
			}
			return urlVars;
		}
	
		// IBehaviour/Idestroyable
		
		/**
		 * Cleans up all form elements, empties the form hash and sets it to null. 
		 * All form elements (if implementing the IDestroyable interface) are completely destroyed and 
		 * most likely unusable after calling this.
		 */
		public function destroy():void {
			if (formHash == null) return;
			for (var i:String in formHash) {
				var chk:IDestroyable = formHash[i] as IDestroyable;
				if (chk != null) chk.destroy();
			}
			formHash = null;
		}
		
				


		
	}
	
	
}
