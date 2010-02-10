package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class DisplayObjectUtils
	{
		
		public static function reparentTo(child:DisplayObject, dispCont:DisplayObjectContainer):void {
			
			var pt:Point = dispCont.globalToLocal( child.parent.localToGlobal( new Point(child.x, child.y) ) );
			
			child.x = pt.x;
			child.y = pt.y;
			dispCont.addChild(child);
		}
		
	}

}