package sg.camo.events 
{
	import flash.events.Event;
	import sg.camo.interfaces.ISelection;
	
	/**
	 * Event that is usually dispatched by some selection-based class (ISelection)/(ISelectioner), etc.
	 * 
	 * @see sg.camo.interfaces.ISelection
	 * @see sg.camo.interfaces.ISelectioner
	 * 
	 * @author Glenn Ko
	 */
	public class SelectionEvent extends Event
	{
		public static const SELECT:String = "GSelect.SELECT";
		/** @private */
		protected var sel:*;
		
		/**
		 * Constructor
		 * @param	type
		 * @param	sel			(Required) The currently selected instance
		 * @param	bubbles		(Boolean) Bubbling by default. Set this to false if required.
		 */
		public function SelectionEvent(type:String, sel:*, bubbles:Boolean=true) 
		{ 
			super (type, bubbles);
			this.sel = sel;
		} 
		
		public override function clone():Event 
		{ 
			return new SelectionEvent(type, sel, bubbles);
		} 
		
		/**
		 * Gets currently selected instance when the event was dispatched
		 */
		public function get curSelected ():* {
			return sel;
		}
		
		public override function toString():String 
		{ 
			return formatToString("SelectionEvent", "type", "bubbles", "sel", "eventPhase"); 
		}
		
	}
	
}