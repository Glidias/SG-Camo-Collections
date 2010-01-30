package sg.camolite.display
{
	import flash.events.Event;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.notifications.GDisplayNotifications;
	import flash.events.MouseEvent;
	
	import sg.camo.interfaces.ISelectable;
	import flash.display.Sprite;

	
	/**
	 *  A basic GBase sprite that stores it's own selected state.
	 * @author Glenn Ko
	 */
	public class GSelectable extends GBase implements ISelectable, IDestroyable
	{
		/** @private */
		protected var _selected:Boolean = false;
		private var _selectEventType:String;
		

		/**
		 * Constructor
		 * @param	initEventType	Defaulted to MouseEvent.CLICK. The type of event to listen to which triggers a selection notification
		 */
		public function GSelectable(initEventType:String=null) 
		{
			super ();
			_selectEventType = initEventType  ? initEventType : MouseEvent.CLICK;
			addEventListener (_selectEventType, selectionClickHandler, false, 0, true);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GSelectable;
		}
		
		
		/**
		 * Resets listener to a new type to trigger a selection click
		 */
		public function set selectEventType(type:String):void {
			removeEventListener(_selectEventType, selectionClickHandler);
			addEventListener(type, selectionClickHandler, false, 0, true);
		}
		
		
		
		public function destroy ():void {
			removeEventListener (_selectEventType, selectionClickHandler, false);
		}
		
		/**
		 * Dispatches DisplayNotifications.SELECT event in response to a some "selection click".
		 * @param	e	
		 */
		protected function selectionClickHandler (e:MouseEvent):void {
			dispatchEvent ( new Event (GDisplayNotifications.SELECT, true) );
		}
		
		public function set selected (bool:Boolean):void {
			_selected = bool;
		}
		public function get selected ():Boolean {
			return _selected;
		}
		
		
	}
	
}