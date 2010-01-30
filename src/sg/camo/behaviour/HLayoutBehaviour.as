package sg.camo.behaviour {
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import sg.camo.interfaces.IAncestorSprite;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.events.CamoChildEvent;
	import sg.camo.ancestor.AncestorListener;
	import camo.core.events.CamoDisplayEvent;
	
	
	/**
	* Arranges items horizontally for newly added child elements.
	* 
	* <p><i>Note:</i><br/>
	* This mainly works for classes extending from  <code>camo.core.display.AbstractDisplay</code> at the moment,
	* since AbstractDisplay dispatches CamoChildEvent.ADDED/REMOVED notifications by default during addChild()/removeChild(). 
	* If you need to, your custom DisplayObjectContainer classes would also have to dispatch those events to notify of 
	* any layout changes as a result of adding/removing children.
	* </p>
	* 
	* @see camo.core.events.CamoChildEvent
	* @see sg.camo.behaviour.WrapHLayoutBehaviour
	* 
	* @author Glenn Ko
	*/
	public class HLayoutBehaviour implements IBehaviour {
		
		public static const NAME:String = "HLayoutBehaviour";
		
		/**
		 * @private
		 */
		protected var _disp:DisplayObjectContainer;
		
		/**
		 * Supply spacing value to behaviour
		 */
		public var spacing:Number = 0;
		public var listenDraw:Boolean = false;
		
		/**
		 * Constructor
		 * @param	$spacing	Supply spacing value to behaviour
		 */
		public function HLayoutBehaviour($spacing:Number=0) {
			spacing = $spacing;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		
		
		/**
		 * Listens DisplayObjectContainer instance
		 * @param	targ
		 */
		public function activate(targ:*):void {
			_disp = (targ as DisplayObjectContainer);
			if (_disp == null) {
				trace("HLayoutBehaviour activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}
			var func:Function = AncestorListener.getAddListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false, 0, true);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false, 0, true);
			if (listenDraw) func(CamoDisplayEvent.DRAW, reDrawHandler, false , 0, true);
		}
		
		public function destroy():void {
			var func:Function  = AncestorListener.getRemoveListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false);
			func (CamoDisplayEvent.DRAW, reDrawHandler, false );
			_disp = null;
			
		}
		
		/**
		 * If the <code>listenDraw</code> flag was set to true prior to activation,
		 * will handle redraw events, re-arraging items if resizing occurs.
		 * 
		 * @param	e
		 */
		protected function reDrawHandler(e:CamoDisplayEvent):void {
			if (!e.bubbles) return;  // non bubbling events assumed no resizing occured
			var lastChild:DisplayObject = e.target as DisplayObject;
			//var gotParent:Boolean = _disp is IDisplay ? lastChild.parent === (_disp as IDisplay).getDisplay() : lastChild.parent === _disp;
			var gotParent:Boolean = lastChild.parent ? lastChild.parent.parent === _disp || lastChild.parent === _disp : false;
			if ( gotParent ) {
				var nextIndex:int = _disp.getChildIndex(lastChild) + 1;
				var len:int = _disp.numChildren;
				var nextChild:DisplayObject =  len > nextIndex ? _disp.getChildAt( nextIndex) : null;

				while (nextChild) {
					nextChild.x = lastChild.x + lastChild.width + spacing;
					lastChild = nextChild;
					nextIndex++;
					nextChild =  len > nextIndex ? _disp.getChildAt(nextIndex) : null;
				}
			}
		}
		
		/**
		 * Listens to CamoChildEvent.ADDED event from target DisplayObjectContainer to update layout
		 * @param	e	(CamoChildEvent)
		 * @return
		 */
		protected function addChildHandler(e:CamoChildEvent):DisplayObject  {
			var lastChild:DisplayObject = _disp.numChildren > 0 ? _disp.getChildAt(_disp.numChildren - 1) : null;
			e.child.x = lastChild != null? lastChild.x + lastChild.width + spacing : 0;
			return lastChild;
		}
		
		/**
		 * Listens to CamoChildEvent.REMOVED event from target DisplayObjectContainer to update layout
		 * @param	e	(CamoChildEvent)
		 * @return
		 */
		protected function removeChildHandler(e:CamoChildEvent):void  {
			var index:int =  _disp.getChildIndex(e.child);
			var w:Number = e.child.width + spacing;  // space occupied by removed chld
			if (index < _disp.numChildren - 1) {
				var i:int = index;
				while (i < _disp.numChildren) {
					_disp.getChildAt(i).x -= w;
					i++;
				}
			}
		}
		
	}
	
}