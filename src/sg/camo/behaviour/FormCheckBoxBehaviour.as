package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import sg.camo.form.FormEvent;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IFormElement;
	import sg.camo.interfaces.ISelectable;
	
	/**
	 * @author Glenn Ko
	 */
	public class FormCheckBoxBehaviour implements IBehaviour, IFormElement
	{
		protected var _targSelectable:ISelectable;
		protected var _targDispatcher:DisplayObject;
		/**
		 * Event to listen to to trigger selection toggle
		 */
		public var listen_event:String = MouseEvent.CLICK;
	
		public static const NAME:String = "FormCheckBoxBehaviour";
		
		private var _defaultSelected:Boolean = false;
		private var _key:String = "";
		private var _optional:Boolean = true;
		

		
		public function FormCheckBoxBehaviour() 
		{
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		public function get target():* {
			return _targSelectable;
		}
		
		public function set optional(val:Boolean):void {
			_optional = val;
		}
		public function get optional():Boolean {
			return _optional;
		}
		
		/**
		 * 
		 * @param	targ	An ISelectable + DisplayObject instance.
		 * @see sg.camo.interfaces.ISelectable
		 */
		public function activate(targ:*):void {
			_targSelectable  = targ as ISelectable;
			if (_targSelectable == null) throw new Error("Target isn't ISelectable or null: " + targ);
			_targDispatcher = targ as DisplayObject;
			if (_targDispatcher == null) throw new Error("Target isn't DisplayObject! " + targ);
			_targDispatcher.addEventListener(listen_event, onCheck, false, 0, true);
			
			var delim:int = _targDispatcher.name.indexOf("$");
			_key = delim < 0 ?  _targDispatcher.name : _targDispatcher.name.slice(0, delim);
			_optional = delim < 0 ? true : _targDispatcher.name.slice(delim) === "required";
			
			_defaultSelected = _targSelectable.selected;
		}
		
		private function onCheck(e:Event):void {
			_targSelectable.selected = !_targSelectable.selected;
		}
		
		public function destroy():void {
			_targSelectable = null;
			if (_targDispatcher) {
				_targDispatcher.removeEventListener(listen_event, onCheck);
				_targDispatcher = null;
			}
		}
		
		public function set value(val:String):void {
			_targSelectable.selected = val != "0";
		}
		public function get value():String {
			return _targSelectable.selected ? "1" : "0";
		}
		public function set key(val:String):void {
			_key = val;
		}
		public function get key ():String {
			return _key;
		}
		public function isValid ():Boolean {
			return _optional || _targSelectable.selected;
		}
		public function showError(bool:Boolean = true):void {
			_targDispatcher.dispatchEvent( new FormEvent( (bool ? FormEvent.ERROR : FormEvent.VALID) , null, false ) );
		}
		public function resetValue():void {
			_targSelectable.selected = _defaultSelected;
		}
	}

}