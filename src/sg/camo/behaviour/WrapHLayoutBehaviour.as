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
		

		override protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			if (lastChild == null) {
				child.x = 0;
				child.y = 0;
				return;
			}
			child.x = lastChild.x + lastChild.width + spacing;
			child.y = lastChild.y;
			if (child.x + child.width > _disp.width) {
				child.x  = 0;
				child.y += child.height;
			}
		}
		
		override protected function removeChildHandler(e:CamoChildEvent):void  {
			$removeChildHandler(e);
		}
		

		
		
		
	}

}