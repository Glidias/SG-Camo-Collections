package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.ancestor.AncestorListener;
		
	/**
	* Hooks up DisplayObject with button behaviour and dispatches ButtonBehaviour event bubbles during
	* mouse events.
	* @author Glenn Ko
	*/
	public class ButtonBehaviour implements IBehaviour {
		
		/** @private */
		protected var _disp:DisplayObject;
		
		public static const CLICK:String = "ButtonBehaviour.CLICK";
		public static const OVER:String = "ButtonBehaviour.OVER";
		public static const OUT:String = "ButtonBehaviour.OUT";
	//	public static const PRESS:String = "buttonBehavior.press";
		
		public static const NAME:String = "ButtonBehaviour";
	
		public function ButtonBehaviour() {
	
		}
		
		/** * @private
		 */
		public function getTarget():DisplayObject {
			return _disp;
		}
		
		/**
		 * Activates DisplayObject instance.
		 * @param	targ	A DisplayObject instance
		 */
		public function activate(targ:*):void {
			var disp:DisplayObject = targ as DisplayObject;
			if (disp is DisplayObjectContainer) (disp as DisplayObjectContainer).mouseChildren = false;
			if (disp is Sprite) (disp as Sprite).buttonMode = true;
			_disp = disp;
			var func:Function = AncestorListener.getAddListenerMethod(_disp);
			func(MouseEvent.CLICK, clickHandler, false, 0, true);
			func(MouseEvent.ROLL_OVER, overHandler, false, 0, true);
			func(MouseEvent.ROLL_OUT, outHandler, false, 0, true);
			//_disp.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler, false, 0, true);
		}
		
		/**
		 * Dispatches ButtonBehaviour.CLICK upon MouseEvent.CLICK
		 * @param	e	(MouseEvent)
		 */
		protected function clickHandler(e:MouseEvent):void {
			_disp.dispatchEvent( new Event(CLICK, true) );
		}
		/**
		 * Dispatches ButtonBehaviour.OVER upon MouseEvent.ROLL_OVER
		 * @param	e	(MouseEvent)
		 */
		protected function overHandler(e:MouseEvent):void {
			_disp.dispatchEvent( new Event(OVER, true) );
		}
		/**
		 * Dispatches ButtonBehaviour.OUT upon MouseEvent.ROLL_OUT
		 * @param	e	(MouseEvent)
		*/
		protected function outHandler(e:MouseEvent):void {
			_disp.dispatchEvent( new Event(OUT, true) );
		}
		
		
		//protected function pressHandler(e:MouseEvent):void {
		//	_disp.dispatchEvent( new Event(PRESS, true) );
	//	}
		
		public function destroy():void {
			var func:Function = AncestorListener.getRemoveListenerMethod(_disp);
			func(MouseEvent.CLICK, clickHandler);
			func(MouseEvent.ROLL_OVER, overHandler);
			func(MouseEvent.ROLL_OUT, outHandler);
		//	_disp.removeEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
			_disp = null;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
	}
	
}