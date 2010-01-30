package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.events.CamoChildEvent;
	
	/**
	* Arranges items vertically for newly added child elements.
	* 
	* <p><i>Note:</i><br/>
	* This mainly works for classes extending from  <code>camo.core.display.AbstractDisplay</code> at the moment,
	* since AbstractDisplay dispatches CamoChildEvent.ADDED/REMOVED notifications by default during addChild()/removeChild(). 
	* If you need to, your custom DisplayObjectContainer classes would also have to dispatch those events to notify of 
	* any layout changes as a result of adding/removing children.
	* </p>
	* 
	* @see camo.core.events.CamoChildEvent
	* @see sg.camo.behaviour.WrapVLayoutBehaviour
	* 
	* @author Glenn Ko
	*/
	public class VLayoutBehaviour implements IBehaviour {
		
		public static const NAME:String = "VLayoutBehaviour";
		protected var _disp:DisplayObjectContainer;
		public var spacing:Number = 0;
		
		public function VLayoutBehaviour($spacing:Number=0) {
			spacing = $spacing;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		public function activate(targ:*):void {
			_disp = (targ as DisplayObjectContainer);
			if (_disp == null) {
				trace("VLayoutBehaviour activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}
			var func:Function = AncestorListener.getAddListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false, 0, true);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false, 0, true);
		}
		
		public function destroy():void {
			var func:Function = AncestorListener.getRemoveListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false);
			_disp = null;
			
		}
		
		protected function addChildHandler(e:CamoChildEvent):DisplayObject  {
			var lastChild:DisplayObject = _disp.numChildren > 0 ? _disp.getChildAt(_disp.numChildren - 1) : null;
			e.child.y = lastChild != null? lastChild.y + lastChild.height + spacing : 0;
			return lastChild;
		}
		
		protected function removeChildHandler(e:CamoChildEvent):void  {
			var index:int =  _disp.getChildIndex(e.child);
			var w:Number = e.child.height + spacing;  // space occupied by removed chld
			if (index < _disp.numChildren - 1) {
				var i:int = index;
				while (i < _disp.numChildren) {
					_disp.getChildAt(i).y -= w;
					i++;
				}
			}
		}
		
	}
	
}