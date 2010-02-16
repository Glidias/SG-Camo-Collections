package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.events.Event;
	import camo.core.events.CamoDisplayEvent;
	import camo.core.display.IDisplay;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.IDisplayBase;
	
	/**
	* Performs relative positioning off the parent container's edge or just absolute alignment.
	* <br/><br/>
	* Also listens to CamoDisplayEvent.DRAW events from the parent container to re-update positions.
	* <br/><br/>
	* During activation, it automatically sets CSS positioning "_top/_left" or "_bottom/_right"  values
	* based on the supplied corner value and current activated display object's position from that parent's edge corner.
	* If  alignment in a particular direction is set to <code>AlignToParentBehaviour.NONE</code>,  it'll use
	* these CSS values to always attempt to position the DisplayObject relative off the parent container's edge,
	* otherwise, it'll just perform absolute alignment (align middle/align _bottom) with the parent container's full dimensions.
	* 
	* @see sg.camo.behaviour.AlignBehaviour
	* @author Glenn Ko
	*/
	public class AlignToParentBehaviour implements IBehaviour {
		
		public static const NAME:String = "AlignToParentBehaviour";
		
		/** @private */
		protected var _disp:DisplayObject;
		/** @private */
		protected var _dispCont:DisplayObjectContainer;
		/** @private Casted IDisplayBase interface for container, if available. */
		protected var _dispBase:IDisplayBase;
		
		/** Non-immutable setups */
		public var _alignRatio:Number = AlignValidation.VALUE_NONE;
		public function set align(val:String):void {
			_alignRatio = AlignValidation.toAlignRatio(val);
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public var _vAlignRatio:Number = AlignValidation.VALUE_NONE;
		public function set vAlign(val:String):void {
			_vAlignRatio = AlignValidation.toVAlignRatio(val);
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public static const VALUE_NONE:int = AlignValidation.VALUE_NONE;
		public static const NONE:String = AlignValidation.NONE;
		public static const LEFT:String = AlignValidation.LEFT;
		public static const MIDDLE:String = AlignValidation.MIDDLE;
		public static const RIGHT:String = AlignValidation.RIGHT;
		public static const TOP:String = AlignValidation.TOP;
		public static const BOTTOM:String = AlignValidation.BOTTOM;

		/** @private Immutable setups prior to activation */
		protected var _corner:int;
		/** Corner constant */ public static const NO_CORNER:int = -1;
		/** Corner constant */ public static const TOP_LEFT:int = 0;
		/** Corner constant */ public static const TOP_RIGHT:int = 1;
		/** Corner constant */ public static const BOTTOM_LEFT:int = 2;
		/** Corner constant */ public static const BOTTOM_RIGHT:int = 3;
		
		protected var _left:Number = Number.NaN;
		protected var _top:Number = Number.NaN;
		protected var _bottom:Number = Number.NaN;
		protected var _right:Number = Number.NaN;
		public function set left(num:Number):void {
			_left = num;
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public function get left():Number {
			return _left;
		}
		
		public function set top(num:Number):void {
			_top = num;
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public function get top():Number {
			return _top;
		}
		
		public function set right(num:Number):void {
			_right = num;
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public function get right():Number {
			return _right;
		}
		
		public function set bottom(num:Number):void {
			_bottom = num;
			if (_dispCont) InvalidateDisplay.invalidate(_dispCont);
		}
		public function get bottom():Number {
			return _bottom;
		}
		
		
		/** X offset positioning from current alignment */
		public var xOffset:Number = 0;
		/** Y offset positioning from current alignment */	
		public var yOffset:Number = 0;

		/**
		 * Constructor.
		 * 
		 * @param	corner				 Corner constant. Defaulted to  NO_CORNER . 
		 * 			Set 'corner' value to an appropiate value to take reference from a specific corner in the parent coordinate space
		 * 			when targeted item is on stage. Otherwise, 
		 * @param	horizontalAlign		 Alignment constant. Defaulted to AlignBehaviour.NONE
		 * @param	verticalAlign		 Alignment constant. Defaulted to AlignBehaviour.NONE
		 */
		public function AlignToParentBehaviour(corner:int=NO_CORNER, horizontalAlign:String = null, verticalAlign:String = null) {
			if (horizontalAlign!=null) align = horizontalAlign;
			if (verticalAlign!=null)  vAlign = verticalAlign;
			_corner = corner;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates DisplayObject instance. 
		* 
		 * @param	targ	Requires DisplayObject (with available IDisplay parent or grand-parent) to be supplied.
		 */
		public function activate(targ:*):void {
			
			_disp = targ;
			if (_disp == null) {
				trace("AlignToParentBehaviour activate() halt. targ as DisplayObject is null!");
				return;
			}
			
			_dispCont = _disp.parent ? _disp.parent is IDisplay ? _disp.parent  : _disp.parent.parent is IDisplay ? _disp.parent.parent : _disp.parent : null;
			_dispBase = _dispCont as IDisplayBase;
			
			if (_dispCont == null) {
				//trace("AlignToParentBehaviour activate() halt. targ  has no IDisplay parent/grandparent or parent is null!");
				_disp.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageInit, false, 0, true);
				return;
			}
			
			initAlignToParent();

		}
	
		
		private function onAddedToStageInit(e:Event):void {
			_disp.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStageInit);
			_dispCont = _disp.parent is IDisplay ? _disp.parent  : _disp.parent.parent is IDisplay ? _disp.parent.parent : _disp.parent;
			_dispBase = _dispCont as IDisplayBase;
			initAlignToParent();
		}
		
		protected function initAlignToParent():void {
			var containerWidth:Number = _dispBase ? _dispBase.__width :_dispCont.width;
			var containerHeight:Number = _dispBase ? _dispBase.__height :_dispCont.height;
			switch (_corner) {
				case NO_CORNER: break;
				case TOP_LEFT: _left = _disp.x; _top = _disp.y; break;
				case TOP_RIGHT: _right = containerWidth - (_disp.x + _disp.width); _top = _disp.y; break;
				case BOTTOM_LEFT: _left = _disp.x; _bottom = containerHeight - (_disp.y + _disp.height); break;
				case BOTTOM_RIGHT: _right = containerWidth - (_disp.x + _disp.width); _bottom = containerHeight - (_disp.y + _disp.height); break;
				default:  break;
			}
			alignDisplayHandler();
			AncestorListener.addEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler, -1);
		}
		
		/**
		 * Listens to CamoDisplayEvent.DRAW events to re-update alignment positions on-the-fly.
		 * @param	e
		 */
		protected function alignDisplayHandler(e:Event = null):void {
			if (e != null && !e.bubbles) return;
			
			var containerWidth:Number = _dispBase ? _dispBase.__width :_dispCont.width;
			var containerHeight:Number = _dispBase ? _dispBase.__height :_dispCont.height;
			if ( !isNaN(_left) || !isNaN(_right) ) _disp.x = validateXOffset(containerWidth);
			if ( !isNaN(_top) || !isNaN(_bottom) ) _disp.y = validateYOffset(containerHeight);
			if (_alignRatio != VALUE_NONE ) _disp.x = (containerWidth - _disp.width) * _alignRatio +xOffset;
			if (_vAlignRatio != VALUE_NONE ) _disp.y = (containerHeight - _disp.height) * _vAlignRatio + yOffset;
		}
		
		
		/** @private */
		protected function validateXOffset(containerWidth:Number):Number {
			
			return  !isNaN(_right) ? containerWidth - _right - _disp.width : _left;
		}
		/** @private */
		protected function validateYOffset(containerHeight:Number):Number {
			
			return  !isNaN(_bottom) ? containerHeight - _bottom - _disp.height : _top;
		}
		
		public function destroy():void {
			AncestorListener.removeEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
			_dispCont = null;
			_disp = null;
		}
		
		
		
	}
	
}