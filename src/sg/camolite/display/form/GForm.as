package sg.camolite.display.form {
	import flash.display.DisplayObject;
	import sg.camolite.display.GBase;
	import sg.camo.form.FormEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.behaviour.FormBehaviour;
	import sg.camo.interfaces.IForm;
	import sg.camo.interfaces.IFormElement;
	import flash.net.URLVariables;
	import flash.events.MouseEvent;
	

	/**
	* GForm container that composes a FormBehaviour class. <br/>
	* Comes with various setters (eg.  a "fields" stage instance setter) to automatically hook up a FormBehaviour
	* there at that location, including a "submit" button. If no "fields" are found, the FormBehaviour targets the GForm class instance itself and searches for any form elements on itself.
	* 
	* @see sg.camo.behaviour.FormBehaviour
	* 
	* @author Glenn Ko
	*/
	public class GForm extends GBase implements IDestroyable, IForm {
		
		/** The composed form behaviour */
		protected var _beh:FormBehaviour; 
		/** Protected stage variable of submit button (if available) */
		protected var _submitBtn:DisplayObject;
		
		public static const FIELD_FOCUS_IN:String = FormBehaviour.FIELD_FOCUS_IN;
		public static const FIELD_FOCUS_OUT:String = FormBehaviour.FIELD_FOCUS_OUT;
		
		
		public function GForm() {
			super();
			if (_beh == null) setDefaultFormBehaviour();
			
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GForm;
		}
		
		// if no custom form behaviuor is specified, assert one.
		/**
		 * @private
		 */
		protected function setDefaultFormBehaviour():void {
			_beh = new FormBehaviour();
			_beh.activate(this);
		}
		
		
		/**
		 * [optional] <b>[Staged instance]</b> to automatically set up submit button.
		 */
		public function set submit(disp:DisplayObject):void {
			if (disp is Sprite) (disp as Sprite).buttonMode = true;
			_submitBtn = disp;
			disp.addEventListener(MouseEvent.CLICK, submitClickHandler, false , 0, true);
			
		}
		/**
		 * [optional] <b>[Staged instance]</b> to automatically set up FormBehaviour over a specific target container.
		 */
		public function set fields(cont:DisplayObjectContainer):void {
			_beh = new FormBehaviour();
			_beh.activate(cont);
		}
		
		
		/**

		 * Validates form when submit button is clicked, and dispatches <code>new FormEvent(FormEvent.SUBMIT,...)</code> with accompanying URLVariables in "params" if 
		 * validation was successful.
		 * @see sg.camo.form.FormEvent
		 * @param	e	(Event)		Happens in response to a  MouseEvent.CLICK on the submit button (if available).
		 */
		protected function submitClickHandler(e:Event):void {
		
			e.stopPropagation();
			var success:Boolean = validate();
			
			if (success) {	
		
				dispatchEvent(new FormEvent(FormEvent.SUBMIT, getURLVariables(), true) );
			}
		}
		

		public function destroy():void {
			
			if (_beh != null) {
				_beh.destroy();
			}
			if (_submitBtn != null) {
				_submitBtn.removeEventListener(MouseEvent.CLICK, submitClickHandler);
			}
		}
		
		
		public function  getFormHash():Object {
			return _beh.getFormHash();
		}

		public function validate ():Boolean {
			return _beh.validate();
		}

		public function resetAll ():void {
			_beh.resetAll();
		}

		public function addFormElement (targ:IFormElement):void {
			_beh.addFormElement(targ);
		}
	
		public function getURLVariables():URLVariables {
			return _beh.getURLVariables();
		}
		
		
		
		
		
		
		
	}
	
}