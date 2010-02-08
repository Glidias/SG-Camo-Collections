package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import camo.core.events.CamoChildEvent;
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
	public class HLayoutBehaviour extends BaseDisplayListLayout {
		
		public static const NAME:String = "HLayoutBehaviour";
		
		/**
		 * Supply spacing value to behaviour
		 */
		public var spacing:Number = 0;

		
		/**
		 * Constructor
		 * @param	$spacing	Supply spacing value to behaviour
		 */
		public function HLayoutBehaviour($spacing:Number=0) {
			spacing = $spacing;
			super(this);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}

		
		override protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			child.x = lastChild!=null ? lastChild.x + lastChild.width + spacing : 0;
		}
		
		protected function $removeChildHandler(e:CamoChildEvent):void {
			super.removeChildHandler(e);	
		}
		
		/**
		 * Listens to CamoChildEvent.REMOVED event from target DisplayObjectContainer to update layout
		 * @param	e	(CamoChildEvent)
		 * @return
		 */
		override protected function removeChildHandler(e:CamoChildEvent):void  {
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