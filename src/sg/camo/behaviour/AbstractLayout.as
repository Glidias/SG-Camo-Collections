package sg.camo.behaviour 
{
	import camo.core.events.CamoChildEvent;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import sg.camo.interfaces.IBehaviour;
	
	/**
	 * Abstract layout behaviour base class.
	 * @author Glenn Ko
	 */
	public class AbstractLayout implements IBehaviour
	{
		/**
		 * Indicates whether to enable re-draw/re-size listener to reupdate layout
		 */
		protected var _listenDraw:Boolean = false;
		
		[CamoInspectable(description = "Auto-updates layout when child elements, behaviour, or the container resizes / or settings change. This must be set to true to update different layout settings at runtime.")]
		public function set listenDraw(boo:Boolean):void {
			if (_listenDraw == boo) return;
			_listenDraw = boo;
			if (_disp == null) return;
			if (boo) {
				_disp.addEventListener(CamoDisplayEvent.DRAW, reDrawHandler, false, 0, true);
			}
			else {
				_disp.removeEventListener(CamoDisplayEvent.DRAW, reDrawHandler);
			}
		}
		public function get listenDraw():Boolean {
			return _listenDraw;
		}
		
		/**
		 * The activated DisplayObjectContainer reference
		 */
		protected var _disp:DisplayObjectContainer;
		
		
		public function AbstractLayout(self:AbstractLayout) 
		{
			if(self != this)
			{
				throw new IllegalOperationError( "AbstractLayoutBehaviour cannot be instantiated directly." );
			}
		}
		
		public function get behaviourName():String {
			throw new Error("AbstractLayout cannot have a behaviour name. Please override");
		}
	
		public function activate(targ:*):void {
			_disp = (targ as DisplayObjectContainer);
			if (_disp == null) {
				trace(behaviourName+" activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}

			_disp.addEventListener( CamoChildEvent.ADD_CHILD, addChildHandler, false, 0, true);
			_disp.addEventListener( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false, 0, true);
			if (listenDraw) _disp.addEventListener(CamoDisplayEvent.DRAW, reDrawHandler, false , 0, true);
		}
		
		protected function addChildHandler(e:CamoChildEvent):void {
			
		}
		protected function removeChildHandler(e:CamoChildEvent):void {
			
		}
		protected function reDrawHandler(e:Event):void {
			
		}
		

		
		public function destroy():void {
			if (_disp == null) return;
			_disp.removeEventListener( CamoChildEvent.ADD_CHILD, addChildHandler, false);
			_disp.removeEventListener( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false);
			_disp.removeEventListener (CamoDisplayEvent.DRAW, reDrawHandler, false );
			_disp = null;
		}
		
	}

}