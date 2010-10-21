package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import sg.camo.events.SelectionEvent;
	import sg.camo.form.FormEvent;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IFormElement;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.interfaces.ISelection;
	import sg.camo.interfaces.ISelectioner;
	
	/**
	 * A form selection that must have a selected value by default (else it'll try to get
	 * the first child selected.)
	 * 
	 * This behaviour works on classes like: sg.camolite.display.GSelection , 
	 * which involves maintaining/setting a single selection.
	 * 
	 * @see sg.camolite.display.GSelection
	 * 
	 * @author Glenn Ko
	 */
	public class FormSelectionBehaviour implements IBehaviour, IFormElement
	{
		protected var _targSelection:ISelectioner;
		protected var _targDispatcher:DisplayObjectContainer;

	
		public static const NAME:String = "FormSelectionBehaviour";
		
		private var _defaultSelected:DisplayObject;
		private var _key:String = "";
		
		
		public function FormSelectionBehaviour() 
		{
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * 
		 * @param	targ	An ISelectioner + DisplayObjectContainer instance.
		 * @see sg.camo.interfaces.ISelectioner
		 */
		public function activate(targ:*):void {
			_targSelection  = targ as ISelectioner;
			if (_targSelection == null) throw new Error("Target isn't ISelectioner or null: " + targ);
			_targDispatcher = targ as DisplayObjectContainer;
			if (_targDispatcher == null) throw new Error("Target isn't DisplayObjectContainer! " + targ);
			
			var delim:int = _targDispatcher.name.indexOf("$");
			_key = delim < 0 ?  _targDispatcher.name : _targDispatcher.name.slice(0, delim);

			
			// assert first selection to be made if current selection is empty 
			_defaultSelected = _targSelection.curSelected as DisplayObject;
			if (_defaultSelected == null && _targDispatcher.numChildren > 0) {
				// try selection by first child's name
				_targSelection.selection  = _targDispatcher.getChildAt(0).name;
			}
			// test value (must have a currently selected value as a DIsplayObject!)
			value;
			
		}
		
		public function get target():* {
			return _targSelection;
		}
		
		public function destroy():void {
			_targSelection = null;
			_targDispatcher = null;
		}
		
		private function errorNoValue():* {
			throw new Error("No current selected value found for:" + _targSelection +" on (should be DisplayObject): "+_targSelection.curSelected);
			return null;
		}
		
		public function set value(val:String):void {
			_targSelection.selection = val;
		}
		public function get value():String {
			return _targSelection.curSelected is DisplayObject ? (_targSelection.curSelected as DisplayObject).name : errorNoValue();
		}
		public function set key(val:String):void {
			_key = val;
		}
		public function get key ():String {
			return _key;
		}
		public function isValid ():Boolean {
			return _targSelection.curSelected != null;
		}
		public function showError(bool:Boolean = true):void {
			_targDispatcher.dispatchEvent( new FormEvent( (bool ? FormEvent.ERROR : FormEvent.VALID), null, false ) );
		}
		public function resetValue():void {
			// assumed using displayObject name as the "key"
			if (_defaultSelected != null) _targSelection.selection = _defaultSelected.name;	
		}
	}

}