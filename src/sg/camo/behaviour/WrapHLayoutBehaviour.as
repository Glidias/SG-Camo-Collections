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
			if (lastChild == null) {
				child.x = 0;
				child.y = 0;
				return null;
			}
			child.y = lastChild.y;
			if (child.x + child.width > _disp.width) {
				child.x  = 0;
				child.y += child.height + spacing;
			}
			return lastChild;
		}
		
		
		

		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
			var index:int =  _disp.getChildIndex(e.child);
		
			var i:int = index + 1;
			
			while (i < _disp.numChildren) {
				var prevChild:DisplayObject = prevChild ? prevChild : index - 1 > -1 ? _disp.getChildAt(index - 1) : null;
				var child:DisplayObject = _disp.getChildAt(i);
				
				if (prevChild) {
					child.x = prevChild.x + prevChild.width + spacing;
					child.y = prevChild.y;
					if (child.x + child.width > _disp.width) {
						child.x  = 0;
						child.y += child.height + spacing;
					}
				}
				else {
					child.x = 0;
					child.y = 0;
				}
				
				prevChild = child;
				i++;
				
			}
		}
		
		
		
	}

}