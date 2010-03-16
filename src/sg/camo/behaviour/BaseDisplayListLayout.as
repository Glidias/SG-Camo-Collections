package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import camo.core.events.CamoChildEvent;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import sg.camo.interfaces.IAncestorSprite;
	
	/**
	 * Abstract Base layout behaviour implementation using the target container's display-list 
	 * to determine the flow of objects.
	 * 
	 * @author Glenn Ko
	 */
	public class BaseDisplayListLayout extends AbstractLayout
	{
		/**
		 * Enforce a fixed depth index for adding children.
		 * Negative values indicate the default topmost depth.
		 */
		protected var _addChildDepth:int = -1;
		
		[CamoInspectable(description = "Attempts to add any children at a particular fixed child index value. This also affects the flow of the layout.", defaultValue = "-1", immutable="redo", type="pint")]
		public function set addChildDepth(val:Number):void {
			if (_disp ) {
				if ( _addChildDepth >= 0) _disp.removeEventListener( CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler)
				if (val >= 0) _disp.addEventListener( CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler, false, 1, true);
			}
			_addChildDepth = int(val);
		}
		public function get addChildDepth():Number {
			return _addChildDepth;
		}
		
		
		
		protected static function validateDepth(cont:DisplayObjectContainer, val:int):int {
			return val > cont.numChildren-1 ? cont.numChildren-1 : val;
		}
		
		public function BaseDisplayListLayout(self:BaseDisplayListLayout=null) 
		{
			super(self);
		}
		
		override public function activate(targ:*):void {
			super.activate(targ);
			if (_disp && _addChildDepth >=0 ) _disp.addEventListener(CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler,false, 1, true);
		}
		
		override public function destroy():void {
			if (_disp) _disp.removeEventListener(CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler);
			super.destroy();
		}
		
		protected function addChildInterruptDepthHandler(e:CamoChildEvent):void {
			_disp.setChildIndex(e.child, validateDepth(_disp, _addChildDepth) );
		}
		
		override protected function addChildHandler(e:CamoChildEvent):void {
			
			var child:DisplayObject = e.child;
			var curIndex:int = _disp.getChildIndex(child);
			var numChildren:int = _disp.numChildren;

			var lastChild:DisplayObject =  curIndex > 0 ? _disp.getChildAt(curIndex - 1) : null;
			arrangeFromLastChild(child, lastChild);
			
			curIndex++;
			while ( curIndex < numChildren ) {
				child = _disp.getChildAt(curIndex);
				arrangeFromLastChild(child, lastChild);
				lastChild = child;
				curIndex++;
			}
		}
		
		protected function arrangeFromLastChild(child:DisplayObject, lastChild:DisplayObject=null):void {
			// to implement in extended classes
		}


		override protected function removeChildHandler(e:CamoChildEvent):void {
			var child:DisplayObject = e.child;
			
			var spliceIndex:int = _disp.getChildIndex(child);
			var prevChild:DisplayObject = spliceIndex - 1 > -1 ? _disp.getChildAt(spliceIndex - 1) : null;
			
			var i:int =  spliceIndex + 1;
			var len:int = _disp.numChildren;

			while (i < len) {
				child = _disp.getChildAt(i);
				arrangeFromLastChild(child, prevChild);
				prevChild = child;
				i++;
			}
		}

		override protected function reDrawHandler(e:CamoDisplayEvent):void {
			if (!e.bubbles) return;  // non bubbling events assumed no resizing occured
			
		
			
			var child:DisplayObject = e.target as DisplayObject;
			//var gotParent:Boolean = _disp is IDisplay ? lastChild.parent === (_disp as IDisplay).getDisplay() : lastChild.parent === _disp;
			var gotParent:Boolean =  _disp is IDisplay ? child.parent ? child.parent.parent === _disp  :  false :child.parent === _disp;

				
			if ( gotParent ) {
					//trace("Aligning from:" +child.width);
				var getChildIndex:Function;
				var getChildAt:Function;
				
				var curIndex:int =  _disp.getChildIndex(child);
				var lastChild:DisplayObject  = curIndex - 1 > -1 ? _disp.getChildAt(curIndex - 1) : null;
			
				arrangeFromLastChild(child, lastChild);
			
				lastChild = child;
				
				curIndex++;
				var len:int = _disp.numChildren;

				while (curIndex < len) {
					child = _disp.getChildAt(curIndex);
					arrangeFromLastChild(child, lastChild);
					lastChild = child;
					curIndex++;
				}
				_disp.dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW, true) );
			}
			
		}
		
	}

}