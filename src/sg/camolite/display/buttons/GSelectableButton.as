package sg.camolite.display.buttons 
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.notifications.GDisplayNotifications;
	/**
	 * A SimpleButton that keeps locks to it's <code>downState</i> while being selected.
	 * @author Glenn Ko
	 */
	public class GSelectableButton extends SimpleButton implements ISelectable, IDestroyable, IReflectClass
	{
		
		protected var _upState:DisplayObject;
		protected var _downState:DisplayObject;
		protected var _overState:DisplayObject;
		protected var _selected:Boolean;
		
		protected var _disabledState:DisplayObject;
		protected var _disabled:Boolean = false;
	
		
		public function GSelectableButton() 
		{
			super();
			refreshDefaultStates();
			addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
		}
		
		protected function refreshDefaultStates():void {
			_upState = upState;
			_downState = downState;
			_overState = overState;
		}
		
		 public function set disabledState(val:DisplayObject):void {
			 _disabledState  = val;
		 }
		  public function get disabledState():DisplayObject {
			  return _disabledState
		  }
		
		public function set disabled(boo:Boolean):void {
			_disabled = boo;
			mouseEnabled = !_selected;
			if (_disabledState==null) return;
			if (boo) {
				upState = _disabledState;
				downState = _disabledState;
				overState = _disabledState;
				
			}
			else {
				selected = _selected;
			}
		}
		public function get disabled():Boolean {
			 return _disabled;
		}
		
		
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GSelectableButton;
		}
		
		protected function clickHandler(e:MouseEvent):void {
			dispatchEvent( new Event(GDisplayNotifications.SELECT, true ) );
		}
		
		public function destroy():void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function set selected (bool:Boolean):void {
			_selected = bool;
			if (bool) {
				upState = _downState;
				downState = _downState;
				overState = _downState;
			}
			else {
				upState = _upState;
				downState = _downState;
				overState = _overState;
			}
			mouseEnabled = !bool;
		}
		
		
		public function get selected ():Boolean {
			return _selected;
		}
		
	}

}