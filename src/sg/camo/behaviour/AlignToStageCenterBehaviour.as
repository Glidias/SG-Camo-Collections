package sg.camo.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class AlignToStageCenterBehaviour extends AbstractStageResizeBehaviour
	{
		public static const NAME:String = "AlignToStageCenterBehaviour";
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public var pin:Boolean;
		
		/**
		 * 
		 * @param	pin		Whether to ignore the width and height values of targetted display object,
		 * 					assuming it's registration point is placed at it's "center" instead of it's top-left
		 * 				    corner.
		 */
		public function AlignToStageCenterBehaviour(pin:Boolean=false) 
		{
			super(this);
			this.pin = pin;
		}
		

		override public function activate(targ:*):void {
			super.activate(targ);
			_disp.addEventListener("draw", checkDraw,false,0,true);
		}
		
		public function checkDraw(e:Event=null):void {
			if (_pStage != null) onStageResize();
		}
		
		override public function destroy():void {
			_disp.removeEventListener("draw", checkDraw);
			super.destroy();
		
		}
		
		override public function get behaviourName():String {
			return NAME;
		}

		override protected function onStageResize(e:Event = null):void {
			
			_disp.x = !pin ?  (_pStage.stageWidth - _disp.width) * .5 + offsetX : _pStage.stageWidth * .5 + offsetX; 
			_disp.y = !pin ? (_pStage.stageHeight - _disp.height) * .5 + offsetY : _pStage.stageHeight * .5 + offsetY;
	
		}
	}

}