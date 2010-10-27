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
		
		override protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			if (lastChild == null) {
				child.x = 0;
				child.y = 0;
				return;
			}
			child.y = lastChild.y + lastChild.height + spacing;
			child.x = lastChild.x;
			if (child.y + child.height > _disp.height) {
				child.y  = 0;
				child.x += child.width;
			}
		}
		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
			$removeChildHandler(e);	
		}
		
		
		
	}

}