package sg.camolite.display {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import sg.camo.events.SelectionEvent;
	import flash.events.TextEvent;
	import sg.camo.behaviour.SelectionBehaviour;
	/**
	* Extended GListDisplay with added selection behaviour for dispatching TextEvent.LINK events with text values
	* based off list item id.
	* 
	* @author Glenn Ko
	*/
	public class GNavListDisplay extends GListDisplay {
		
		public function GNavListDisplay(customDisp:Sprite=null) {
			super(customDisp);
			addBehaviour( new SelectionBehaviour() );
			$addEventListener( SelectionEvent.SELECT, navSelectionHandler, false , 0, true);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GNavListDisplay;
		}
		
		/**
		 * Triggers when a selection is made. Dispatches TextEvent.LINK event bubble, using the id of the selected item as the text value.
		 * @param	e	
		 */
		protected function navSelectionHandler(e:SelectionEvent):void {
			e.stopImmediatePropagation();
			dispatchEvent (new TextEvent(TextEvent.LINK, true, false, getIdOfItem(e.curSelected as DisplayObject) ) );
		}
		
		override public function destroy():void {
			super.destroy();
			$removeEventListener( SelectionEvent.SELECT, navSelectionHandler, false);
		}
		
		
		
	}
	
}