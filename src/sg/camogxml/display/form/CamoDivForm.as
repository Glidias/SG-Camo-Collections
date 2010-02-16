package sg.camogxml.display.form 
{
	import flash.events.Event;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IForm;
	import sg.camo.interfaces.IFormElement;
	import sg.camogxml.display.CamoDiv;
	/**
	 * Basic CamoDivForm to manage nested IFormElements.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivForm extends CamoDiv implements IForm
	{
		
		protected var _dictFormElements:Dictionary = new Dictionary();
		
		public var highlightErrors:Boolean = true;
		
		public function CamoDivForm() 
		{
			super();
			$addEventListener( Event.ADDED, addChildHandler, false , 0, true);
			$addEventListener( Event.REMOVED, removeChildHandler, false , 0, true);
		}
		
		override public function get reflectClass():Class {
			return CamoDivForm;
		}
		
		
		override public function destroy():void {
			super.destroy();
			$removeEventListener(Event.ADDED, addChildHandler);
			$removeEventListener( Event.REMOVED, removeChildHandler);
			for (var i:* in _dictFormElements) {
				var chk:IDestroyable = i as IDestroyable;
				if (chk != null) chk.destroy();
			}
			_dictFormElements = null;
		}
		
		protected function addChildHandler(e:Event):void {
			if (e.target is IFormElement) addFormElement(e.target as IFormElement);
		}
		protected function removeChildHandler(e:Event):void {
			if (_dictFormElements[e.target]) delete _dictFormElements[e.target];
		}
		
		public function validate ():Boolean {
			var gotWrong:Boolean = false;
			for  (var i:* in _dictFormElements) {
				var formElement:IFormElement = i;
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
		
		public function resetAll ():void {
			for  (var i:* in _dictFormElements) {
				var formElement:IFormElement = i;
				formElement.resetValue();
			}
		}
		
		public function addFormElement (targ:IFormElement):void {
			_dictFormElements[targ] = true;
		}
		
		public function getURLVariables():URLVariables {	
			var urlVars:URLVariables = new URLVariables();
			for (var i:* in _dictFormElements) {
				urlVars[i] = i.value;
			}
			return urlVars;
		}
		
		
		
	}

}