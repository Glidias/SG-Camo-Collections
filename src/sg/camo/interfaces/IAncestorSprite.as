package sg.camo.interfaces 
{
	import flash.display.DisplayObject;
	
	/**
	* Public interface for classes requiring access to commonly used ancestor sprite methods 
	* (via "$" prefixed methods ), which refer to the methods that should be left unchanged in extended
	* classes. 
	* <br/><br>
	* By casting a valid reference to an IAncestorSprite, this allows one to fall-back to any "old" non-overwritten implementation
	* that was originally used by the original Sprite class itself.<br>
	* 
	* @see sg.camo.ancestor.AncestorListener
	* 
	* @author Glenn Ko
	*/
	public interface IAncestorSprite 
	{
		function $addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void;
		function $removeEventListener(type : String, listener:Function, useCapture:Boolean = false):void;

		function $addChild(child : DisplayObject) : DisplayObject;
		function $addChildAt(child : DisplayObject, index:int) : DisplayObject;
		function $removeChild(child:DisplayObject):DisplayObject;
		function $contains(child:DisplayObject):Boolean;
		function get $numChildren():int;
		function $getChildIndex(child : DisplayObject) : int;
		function $getChildByName(name : String) : DisplayObject;
		function $getChildAt(index : int) : DisplayObject;
		function $removeChildAt(index : int) : DisplayObject
		
		function get $width():Number;
		function get $height():Number;
	}
	
}