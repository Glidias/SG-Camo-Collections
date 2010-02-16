package sg.camogxml.display.form 
{
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IFormElement;
	import sg.camogxml.display.ui.CamoDivField;
	import flash.events.Event;
	
	/**
	 * Extended CamoDivField with boiler-plate IFormElement implementation to support some injectable 
	 * form element behaviour.
	 * 
	 * @author Glenn Ko
	 */
	public class CamoDivFormField extends CamoDivField implements IFormElement
	{
		/** @private This reference must also implement the IBehaviour interface */
		protected var _formElementBehaviour:IFormElement;
		
		 /** @private
		 * Flag to indicate behaviour is already activated.
		 */
		protected var _behActivated:Boolean = false;
		
		/**
		 * Constructor. Sets up an input textfield.
		 */
		public function CamoDivFormField() 
		{
			super();
			
			// Conventions for form field
			_textField.type = "input";
		}
		
		override public function get reflectClass():Class {
			return CamoDivFormField;
		}
		
		/**
		 * Important note: Some behaviour implementing the IFormElement interface must be injected
		 * into the CamoDivFormField first at the very beginning before anything else is set.
		 * <br/><br/>
		 * An example of such a behaviour can be found below:
		 * @see sg.camo.behaviour.SimpleFormFieldBehaviour
		 */
		[Inject(name='CamoDivFormField.behaviour')]
		public function setBehaviour(beh:IBehaviour=null):void {
			if (beh is IFormElement) behaviour = beh
			else if (beh!=null) throw new Error("CamoDivFormField setBehaviour() failed! Behaviour isn't IFormElement:"+beh ); 
		}
		
		public function set behaviour(beh:IBehaviour):void {
			var tryBeh:IFormElement = beh as IFormElement;
			if (tryBeh == null) {
				throw new Error("CamoDivFormField set behaviour failed! Behaviour isn't IFormElement or null:"+beh );
			}
			_formElementBehaviour = tryBeh;
			if (stage) {
				beh.activate(this);
				_behActivated = true;
			}
		}
		
		
		/**
		 * Activates form element behaviour if required once added to stage.
		 * @param	e
		 */
		override protected function onAddedToStage(e:Event):void {
			super.onAddedToStage(e);
			if (!_behActivated && _formElementBehaviour) {
				(_formElementBehaviour as IBehaviour).activate(this);
				_behActivated = true;
			}
		}
		


		
		public function set value(val:String):void {
			_formElementBehaviour.value = val;
		}
		public function get value():String {
			return _formElementBehaviour.value;
		}
		public function set key(val:String):void {
			_formElementBehaviour.key = val;
		}
		public function get key ():String {
			return _formElementBehaviour.key;
		}
		
		public function isValid ():Boolean {
			return _formElementBehaviour.isValid();
		}
		public function showError(bool:Boolean = true):void {
			_formElementBehaviour.showError();
		}
		public function resetValue():void {
			_formElementBehaviour.resetValue();
		}
		
		override public function destroy():void {
			super.destroy();
			if (_formElementBehaviour) (_formElementBehaviour as IBehaviour).destroy();
		}
		
		
		
		
	}

}