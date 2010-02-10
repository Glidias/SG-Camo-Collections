package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import camo.core.events.CamoChildEvent;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
		
	/**
	 * Abstract Base layout behaviour implementation using the target container's display-list 
	 * to determine the flow of objects.
	 * 
	 * @author Glenn Ko
	 */
	public class BaseDisplayListLayout extends AbstractLayout
	{
		
		public function BaseDisplayListLayout(self:BaseDisplayListLayout=null) 
		{
			super(self);
		}
		
		override protected function addChildHandler(e:CamoChildEvent):void {
			
			var child:DisplayObject = e.child;
			var curIndex:int = _disp.getChildIndex(child);
			var numChildren:int = _disp.numChildren;
		
			var lastChild:DisplayObject =  curIndex > 0 ? _disp.getChildAt(curIndex - 1) : null;
			arrangeFromLastChild(child, lastChild);
			
			curIndex++;
			while ( curIndex < numChildren ) {
				child = _disp.getChildAt(curIndex);
				arrangeFromLastChild(child, lastChild);
				lastChild = child;
				curIndex++;
			}
		}
		


		override protected function removeChildHandler(e:CamoChildEvent):void {
			var child:DisplayObject = e.child;
			
			var spliceIndex:int = _disp.getChildIndex(child);
			var prevChild:DisplayObject = spliceIndex - 1 > -1 ? _disp.getChildAt(spliceIndex - 1) : null;
			
			var i:int =  spliceIndex + 1;
			var len:int = _disp.numChildren;

			while (i < len) {
				child = _disp.getChildAt(i);
				arrangeFromLastChild(child, prevChild);
				prevChild = child;
				i++;
			}
		}

		override protected function reDrawHandler(e:CamoDisplayEvent):void {
			if (!e.bubbles) return;  // non bubbling events assumed no resizing occured
			var child:DisplayObject = e.target as DisplayObject;
			//var gotParent:Boolean = _disp is IDisplay ? lastChild.parent === (_disp as IDisplay).getDisplay() : lastChild.parent === _disp;
			var gotParent:Boolean =  _disp is IDisplay ? child.parent ? child.parent.parent === _disp  :  false :child.parent === _disp;

			
			if ( gotParent ) {
				
				var getChildIndex:Function;
				var getChildAt:Function;
				
				var curIndex:int =  _disp.getChildIndex(child);
				var lastChild:DisplayObject  = curIndex - 1 > -1 ? _disp.getChildAt(curIndex - 1) : null;
			
				arrangeFromLastChild(child, lastChild);
			
				lastChild = child;
				
				curIndex++;
				var len:int = _disp.numChildren;

				while (curIndex < len) {
					child = _disp.getChildAt(curIndex);
					arrangeFromLastChild(child, lastChild);
					lastChild = child;
					curIndex++;
				}
			}
		}
		
	}

}