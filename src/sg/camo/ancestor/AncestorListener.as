package sg.camo.ancestor {
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IAncestorSprite;
	
	/**
	* Utility to retreive original add/remove listener implementations for Ancestor sprites.
	* <br/><br/>
	* Instead of using this utility, you can also manually check for the right "original" implementation to use.
	* @example
	* <code>
	* var targ:Sprite = someSpriteOnStage;<br/>
	* var func:Function = AncestorListener.getRemoveListenerMethod(targ);<br/>
	* // var func:Function = targ is IAncestorSprite ? (targ as IAncestorSprite).$removeEventListener : targ.removeEventListener;
	* <br/>func(MouseEvent.CLICK, clickHandler);<br/>
	* func(MouseEvent.ROLL_OVER, overHandler);<br/>
	* </code>
	* 
	* @see sg.camo.interfaces.IAncestorSprite
	* 
	* @author Glenn Ko
	*/
	public class AncestorListener {
		
		public static function addEventListenerOf(targ:IEventDispatcher, type:String, handler:Function, priority:int=0, useWeakListener:Boolean = true):void {
			var func:Function = targ is IAncestorSprite ? (targ as IAncestorSprite).$addEventListener : targ.addEventListener;
			func(type, handler, false, priority, useWeakListener);
			
		}
		public static function removeEventListenerOf(targ:IEventDispatcher, type:String, handler:Function):void {
			var func:Function = targ is IAncestorSprite ? (targ as IAncestorSprite).$removeEventListener : targ.removeEventListener;
			func(type, handler, false);
		
		}
		
		public static function getAddListenerMethod(targ:IEventDispatcher):Function {
			return targ is IAncestorSprite ? (targ as IAncestorSprite).$addEventListener : targ.addEventListener;
		}
		public static function getRemoveListenerMethod(targ:IEventDispatcher):Function {
			return targ is IAncestorSprite ? (targ as IAncestorSprite).$removeEventListener : targ.removeEventListener;
		}
		
	}
	
}