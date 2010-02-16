package sg.camo.behaviour {
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.events.CamoDisplayEvent;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.IDisplayBase;
	
	/**
	* Performs horizontal and/or vertical aligning of display.
	* <br/><br>
	* AlignBehaviour uses the IDisplay's <code>getDisplay()</code> display object reference  
	* to determine the nested display child's dimensions in relation to the IDisplay container's own actual width and height,
	* from which alignment occurs.
	*  <br/><br/>
	* Also listens to CamoDisplayEvent.DRAW events from the IDisplay instance to re-update positions.
	*
	* 
	* @see camo.core.display.IDisplay
	* @see camo.core.display.AbstractDisplay
	* @see camo.core.display.BoxModelDisplay
	* 
	* @author Glenn Ko
	*/
	public class AlignBehaviour implements IBehaviour {
		
		public static const NAME:String = "AlignBehaviour";
		
		/** @private */
		protected var _dispCont:IDisplay;
		/** @private Casted IDisplayBase interface for container, if available. */
		protected var _dispBase:IDisplayBase;
		

		public var _alignRatio:Number = AlignValidation.VALUE_NONE;
		public function set align(val:String):void {
			_alignRatio = AlignValidation.toAlignRatio(val);
			if (_dispCont) _dispCont.invalidateSize();
		}
		public var _vAlignRatio:Number = AlignValidation.VALUE_NONE;
		public function set vAlign(val:String):void {
			_vAlignRatio = AlignValidation.toVAlignRatio(val);
			if (_dispCont) _dispCont.invalidateSize();
		}
		public static const VALUE_NONE:int = AlignValidation.VALUE_NONE;
		public static const NONE:String = AlignValidation.NONE;
		public static const LEFT:String = AlignValidation.LEFT;
		public static const MIDDLE:String = AlignValidation.MIDDLE;
		public static const RIGHT:String = AlignValidation.RIGHT;
		public static const TOP:String = AlignValidation.TOP;
		public static const BOTTOM:String = AlignValidation.BOTTOM;
		
		/** Y offset positioning from current alignment */
		public var yOffset:Number = 0;
		
		/** X offset positioning from current alignment */
		public var xOffset:Number = 0;
		
		/**
		 * Constructor. 
		 * 
		 * @param	horizontalAlign	  Defaulted to AlignBehaviour.NONE if unspecified
		 * @param	verticalAlign	   Defaulted to  AlignBehaviour.NONE if unspecified
		 */
		public function AlignBehaviour(horizontalAlign:String = null, verticalAlign:String = null) {
			if (horizontalAlign) _alignRatio = AlignValidation.toAlignRatio(horizontalAlign);
			if (verticalAlign) _vAlignRatio = AlignValidation.toVAlignRatio(verticalAlign);
		}
		
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates IDisplay Instance.
		 * @param	targ 	A valid IDisplay instance.
		 */
		public function activate(targ:*):void {
			_dispCont = (targ as IDisplay);
			_dispBase = targ as IDisplayBase;
			if (_dispCont == null) {
				trace("AlignBehaviour activate() halt. targ as IDisplay is null!");
				return;
			}
			AncestorListener.addEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler, -1);
		}
		
	
		protected function alignDisplayHandler(e:Event):void {
			if (!e.bubbles) return;
			
			var disp:DisplayObject = _dispCont.getDisplay();
		
			var containerDimension:Number;
			if (_alignRatio != VALUE_NONE) {
				containerDimension = _dispBase ? _dispBase.__width :_dispCont.width;
				disp.x = (containerDimension - disp.width) * _alignRatio +xOffset;
			}
			if (_vAlignRatio != VALUE_NONE) {
				containerDimension  = _dispBase ? _dispBase.__height :_dispCont.height;
				disp.y = (containerDimension - disp.height) * _vAlignRatio + yOffset;
			}
		}
		
		public function destroy():void {
			AncestorListener.removeEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
			//_dispCont.removeEventListener( CamoDisplayEvent.DRAW, alignDisplayHandler, false);
			_dispCont = null;
		}
		
		
	}
	
}