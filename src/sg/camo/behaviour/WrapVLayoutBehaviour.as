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
			if (lastChild == null) {
				child.x = 0;
				child.y = 0;
				return null;
			}
			child.x = lastChild.x;
			if (child.y + child.height > _disp.height) {
				child.x  += child.width+spacing;
				child.y = 0;
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
					child.y = prevChild.y + prevChild.height + spacing;
					child.x = prevChild.x;
					if (child.y + child.height > _disp.height) {
						child.x  += child.width+spacing;
						child.y = 0;
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