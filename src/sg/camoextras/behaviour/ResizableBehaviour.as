package sg.camoextras.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import sg.camo.ancestor.AncestorChild;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IResizable;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ResizableBehaviour implements IBehaviour
	{
		public static const NAME:String = "ResizableBehaviour";
		private static const LOOKUP_NAME:String = "resizer";

		protected var _disp:DisplayObject;
		protected var _resizable:IResizable;
		protected var _targDispatcher:IEventDispatcher;
		
		protected var startXOffset:Number;
		protected var startYOffset:Number;
		
		public function ResizableBehaviour() 
		{
			
		}

		public function get behaviourName():String {
			return NAME;
		}
		

		protected function findResizeHandler(targ:DisplayObject):IEventDispatcher {
			var retDispatcher:IEventDispatcher;
			if (targ is DisplayObjectContainer) {
				var cont:DisplayObjectContainer = targ as DisplayObjectContainer;
				retDispatcher = AncestorChild.getChildByNameOf(cont, LOOKUP_NAME) || cont.getChildByName(LOOKUP_NAME) || targ;
			}
			else retDispatcher = targ;
			return retDispatcher;
		}
		
		public function activate(targ:*):void {
			_disp = targ as DisplayObject;
			_resizable = _disp as IResizable;
			if (_disp ==null) throw new Error("ResizableBehaviour :: Target must be DisplayObject!")
			_targDispatcher = findResizeHandler(targ);

			_targDispatcher.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false ,0, true);
		}
		
		protected function mouseDownHandler(e:MouseEvent):void {
			_disp.stage.addEventListener(MouseEvent.MOUSE_MOVE, dragHandler, false, 0, true);
			_disp.stage.addEventListener(MouseEvent.MOUSE_UP, releaseStageHandler, false , 0, true);
			startXOffset = _disp.width - _disp.mouseX;
			startYOffset = _disp.height - _disp.mouseY;
		}
		
		protected function releaseStageHandler(e:MouseEvent):void {
			var ev:IEventDispatcher = e.currentTarget as IEventDispatcher; 
			ev.removeEventListener(MouseEvent.MOUSE_MOVE,  dragHandler);
			ev.removeEventListener(MouseEvent.MOUSE_UP,  releaseStageHandler);
		}
		
		protected function dragHandler(e:MouseEvent):void {
			var tarWidth:Number = _disp.mouseX + startXOffset;
			var tarHeight:Number = _disp.mouseY + startYOffset;
			tarWidth = tarWidth < 0 ? 0 : tarWidth;
			tarHeight = tarHeight < 0 ? 0 : tarHeight;
			if (_resizable) _resizable.resize(tarWidth, tarHeight)
			else {
				_disp.width = tarWidth;
				_disp.height = tarHeight;
			}
		}
		
		public function destroy():void {
			_targDispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
		}
		
	}

}