package sg.camo.behaviour 
{
	import camo.core.events.CamoChildEvent;
	import flash.display.DisplayObject;
	import sg.camo.behaviour.HLayoutBehaviour;
	/**
	 * Extended HLayoutBehaviour with wrapping functionality.
	 * 
	 * 
	 * @author Glenn Ko
	 */
	public class WrapHLayoutBehaviour extends HLayoutBehaviour
	{
		public static const NAME:String = "WrapHLayoutBehaviour";
		
		public function WrapHLayoutBehaviour($spacing:Number=0) 
		{
			super($spacing);	
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * 	If the item's current bounds overflow beyond the stipulated DisplayObjectContainer's width, it flows down 
		 * to the "next row".
		 * @param	e
		 * @return
		 */
		override protected function addChildHandler(e:CamoChildEvent):DisplayObject  {
			var lastChild:DisplayObject = super.addChildHandler(e);
			var child:DisplayObject = e.child;
			if (lastChild == null) return null;
			child.y = lastChild.y;
			if (child.x + child.width > _disp.width) {
				child.x  = 0;
				child.y += child.height + spacing;
			}
			return lastChild;
		}
		

		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
			var index:int =  _disp.getChildIndex(e.child);
			var w:Number = e.child.width + spacing;  // space occupied by removed chld
			var lastChild:DisplayObject;
			if (index < _disp.numChildren - 1) {
				var i:int = index;
				while (i < _disp.numChildren) {
					var child:DisplayObject = _disp.getChildAt(i);
					var tar:Number = child.x - w - child.width;
					child.x = tar < 0 ? _disp.width - w : child.x - w ;
					if (tar < 0) child.y -= child.height + spacing;
					i++;
					lastChild = child;
				}
			}
		}
		
		
		
	}

}