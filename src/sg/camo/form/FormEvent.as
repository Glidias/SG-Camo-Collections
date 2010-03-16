package sg.camo.form {
	import flash.events.Event;
	
	/**
	* Standard Form Event with a variable Object payload. 
	* 
	* @see sg.camolite.display.form.GForm
	* 
	* @author Glenn Ko
	*/
	public class FormEvent extends Event {
		
		/**
		 * The params Object is normally a hash of URLVariables
		 * being sent from typical form implementations.
		 */
		public var params:Object;
		public static const SUBMIT:String = "FormEvent.SUBMIT";
		
		/**
		 * 
		 * @param	type		
		 * @param	params		
		 * @param	bubbles		(Boolean) Defaulted to true. Bubbling by default.
		 */
		public function FormEvent(type:String, params:Object=null, bubbles:Boolean=true) {
			super(type, bubbles);
			this.params = params;
		}
		override public function clone():Event {
			return new FormEvent(type, params, bubbles);
		}
		
		
	}
	
}