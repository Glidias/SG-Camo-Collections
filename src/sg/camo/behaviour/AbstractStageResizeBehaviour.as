package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.IBehaviour;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class AbstractStageResizeBehaviour implements IBehaviour
	{
		
		protected var _disp:DisplayObject;
		protected var _pStage:Stage;
		
		public function AbstractStageResizeBehaviour(self:AbstractStageResizeBehaviour) 
		{
			if (self !== this) throw new Error("AbstractStageResizeBehaviour cannot be instantiated directly!");
		}
		

		public function get behaviourName():String {
			throw new Error("AbstractStageResizeBehaviour has no behaviourName! Please overwrite in:"+getQualifiedClassName(this))
		}
		

		public function activate(targ:*):void {
			var disp:DisplayObject = targ as DisplayObject;
			if (!disp) throw new Error("Target isn't display object!");
			_disp = disp;
			if (!disp.stage) {
				disp.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false , -1, true);
			}
			else {
				_pStage = _disp.stage;
				_pStage.addEventListener(Event.RESIZE, onStageResize, false , 0, true);
				_disp.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false , 0, true);
				onStageResize();
			}
		}
		
		protected function onAddedToStage(e:Event = null):void {
			_disp.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_disp.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false , 0, true);
			_pStage = _disp.stage;
			_pStage.addEventListener(Event.RESIZE, onStageResize, false , 0, true);
			onStageResize();
		}
		
		protected function onRemovedFromStage(e:Event):void {
			_disp.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			_disp.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false , 0, true);
		}
		
		protected function onStageResize(e:Event=null):void {
			// to ovverride
			
		}
		
		public function destroy():void {
			if (_pStage) {
				_pStage.removeEventListener(Event.RESIZE, onStageResize);
			}
			if (_disp) {
				_disp.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				_disp.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			}
			
			_pStage = null;
			_disp = null;
		}
		
	}

}