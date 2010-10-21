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
		public static const ERROR:String = "error";
		public static const VALID:String = "valid";
		
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
		
		public function traceParams():void {
			if (params == null) trace("FormEvent::" + type + "Empty params");
			else {
				var str:String = "FormEvent::"+type+"\n";
				for (var i:String in params) {
					str+= i+": "+params[i]+"\n";
				}
				trace(str);
			}
		}
		
		
	}
	
}