package sg.camo.behaviour 
{
	import camo.core.events.CamoChildEvent;
	import flash.display.DisplayObject;
	import sg.camo.behaviour.VLayoutBehaviour;
	/**
	 * Extended VLayoutBehaviour with wrapping functionality.
	 * 
	 * @author Glenn Ko
	 */
	public class WrapVLayoutBehaviour extends VLayoutBehaviour
	{
		public static const NAME:String = "WrapVLayoutBehaviour";
		
		public function WrapVLayoutBehaviour($spacing:Number=0) 
		{
			super($spacing);	
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * 	If the item's current bounds overflow below the stipulated DisplayObjectContainer's height, it flows up 
		 * to the "next column" ahead.
		 * @param	e
		 * @return
		 */
		override protected function addChildHandler(e:CamoChildEvent):DisplayObject  {
			var lastChild:DisplayObject = super.addChildHandler(e);
			var child:DisplayObject = e.child;
			if (lastChild == null) return null;
			child.x = lastChild.x;
			if (child.y + child.height > _disp.height) {
				child.x  += child.width+spacing;
				child.y = 0;
			}
			return lastChild;
		}
		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
			var index:int =  _disp.getChildIndex(e.child);
			var w:Number = e.child.height + spacing;  // space occupied by removed chld
			var lastChild:DisplayObject;
			if (index < _disp.numChildren - 1) {
				var i:int = index;
				while (i < _disp.numChildren) {
					var child:DisplayObject = _disp.getChildAt(i);
					var tar:Number = child.y - w - child.height;
					child.y = tar < 0 ? _disp.height - w : child.y - w ;
					if (tar < 0) child.x -= child.width + spacing;
					i++;
					lastChild = child;
				}
			}
		}
		
		
		
	}

}