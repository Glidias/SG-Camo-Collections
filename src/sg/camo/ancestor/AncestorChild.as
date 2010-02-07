package sg.camo.ancestor 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import sg.camo.interfaces.IAncestorSprite;
	/**
	 * Utility to retreive original DisplayObjectContainer implementations if container is an Ancestor sprite.
	 * 
	 * @see sg.camo.interfaces.IAncestorSprite
	 * 
	 * @author Glenn Ko
	 */
	public class AncestorChild 
	{
		
		public static function getChildByNameOf(dispCont:DisplayObjectContainer, name:String):DisplayObject {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$getChildByName(name) : dispCont.getChildByName(name);
		}
		
		public static function getChildAtOf(dispCont:DisplayObjectContainer, index:int):DisplayObject {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$getChildAt(index) : dispCont.getChildAt(index);
		}
		
		public static function getChildIndexOf(dispCont:DisplayObjectContainer, child:DisplayObject):int {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$getChildIndex(child) : dispCont.getChildIndex(child);
		}
		
		public static function containsOf(dispCont:DisplayObjectContainer, child:DisplayObject):Boolean {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$contains(child) : dispCont.contains(child);
		}
		
		public static function addChildOf(dispCont:DisplayObjectContainer, child:DisplayObject):DisplayObject {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$addChild(child) : dispCont.addChild(child);
		}
		
		public static function removeChildOf(dispCont:DisplayObjectContainer, child:DisplayObject):DisplayObject {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$removeChild(child) : dispCont.removeChild(child);
		}
		
		public static function numChildrenOf(dispCont:DisplayObjectContainer):int {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$numChildren : dispCont.numChildren;
		}
		public static function getContains(dispCont:DisplayObjectContainer, disp:DisplayObject):Boolean {
			return dispCont is IAncestorSprite  ? (dispCont as IAncestorSprite).$contains(disp) : dispCont.contains(disp);
		}

		
	}

}