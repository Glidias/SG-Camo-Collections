﻿package sg.camo.behaviour 
{
	import camo.core.events.CamoChildEvent;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.IBehaviour;
	
	/**
	 * Abstract layout behaviour base class.
	 * @author Glenn Ko
	 */
	public class AbstractLayout implements IBehaviour
	{
		/**
		 * Flag to indicate whether to enable re-draw/re-size listener to reupdate layout
		 */
		public var listenDraw:Boolean = false;
		
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
			return "";
		}
	
		public function activate(targ:*):void {
			_disp = (targ as DisplayObjectContainer);
			if (_disp == null) {
				trace(behaviourName+" activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}
			var func:Function = AncestorListener.getAddListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false, 0, true);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false, 0, true);
			if (listenDraw) func(CamoDisplayEvent.DRAW, reDrawHandler, false , 0, true);
		}
		
		protected function addChildHandler(e:CamoChildEvent):void {
			
		}
		protected function removeChildHandler(e:CamoChildEvent):void {
			
		}
		protected function reDrawHandler(e:CamoDisplayEvent):void {
			
		}
		
		protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			
		}
		
		public function destroy():void {
			if (_disp == null) return;
			var func:Function  = AncestorListener.getRemoveListenerMethod(_disp);
			func( CamoChildEvent.ADD_CHILD, addChildHandler, false);
			func( CamoChildEvent.REMOVE_CHILD, removeChildHandler, false);
			func (CamoDisplayEvent.DRAW, reDrawHandler, false );
			_disp = null;
		}
		
	}

}