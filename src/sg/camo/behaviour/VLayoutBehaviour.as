package sg.camo.behaviour {
	import flash.display.DisplayObject;
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
	public class VLayoutBehaviour extends BaseDisplayListLayout {
		
		public static const NAME:String = "VLayoutBehaviour";
	
		public var spacing:Number = 0;
		
		public function VLayoutBehaviour($spacing:Number=0) {
			spacing = $spacing;
			super(this);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			child.y = lastChild!=null ? lastChild.y + lastChild.height + spacing : 0;
		}
		
		protected function $removeChildHandler(e:CamoChildEvent):void {
			super.removeChildHandler(e);
		}
		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
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