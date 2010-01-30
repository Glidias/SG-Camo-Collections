package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.events.Event;
	import camo.core.events.CamoDisplayEvent;
	import camo.core.display.IDisplay;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	* Performs relative positioning off the parent container's edge or just absolute alignment.
	* <br/><br/>
	* Also listens to CamoDisplayEvent.DRAW events from the parent container to re-update positions.
	* <br/><br/>
	* During activation, it automatically sets CSS positioning "top/left" or "bottom/right"  values
	* based on the supplied corner value and current activated display object's position from that parent's edge corner.
	* If  alignment in a particular direction is set to <code>AlignToParentBehaviour.NONE</code>,  it'll use
	* these CSS values to always attempt to position the DisplayObject relative off the parent container's edge,
	* otherwise, it'll just perform absolute alignment (align middle/align bottom) with the parent container's full dimensions.
	* 
	* @see sg.camo.behaviour.AlignBehaviour
	* @author Glenn Ko
	*/
	public class AlignToParentBehaviour implements IBehaviour {
		
		public static const NAME:String = "AlignToParentBehaviour";
		
		/** @private */
		protected var _disp:DisplayObject;
		/** @private */
		protected var _dispCont:IDisplay;
		
		
		/** Alignment constant */ public static const NONE:int = 0;
		/** Alignment constant */ public static const RIGHT:int = 2;
		/** Alignment constant */ public static const MIDDLE:int = 1;
		/** Alignment constant */ public static const BOTTOM:int = 2;
		
		/** * Set this to any of the alignment constants */  
		public var align:int = NONE;
		/** * Set this to any of the alignment constants */
		public var vAlign:int = NONE;
		
		/** X offset positioning from current alignment */
		public var xOffset:Number = 0;
		/** Y offset positioning from current alignment */	
		public var yOffset:Number = 0;
		

		/** @private */
		protected var _corner:int;
		/** Corner constant */ public static const TOP_LEFT:int = 0;
		/** Corner constant */ public static const TOP_RIGHT:int = 1;
		/** Corner constant */ public static const BOTTOM_LEFT:int = 2;
		/** Corner constant */ public static const BOTTOM_RIGHT:int = 3;
		
		
		public var left:Number = 0;
		public var top:Number = 0;
		public var bottom:Number = Number.POSITIVE_INFINITY;
		public var right:Number = Number.POSITIVE_INFINITY;

		/**
		 * Constructor.
		 * 
		 * @param	corner				 Corner constant. Defaulted to  AlignBehaviour.TOP_LEFT . 
		 * 			Set 'corner' to an appropiate value to take reference from a specific corner in the parent coordinate space
		 * @param	horizontalAlign		 Alignment constant. Defaulted to AlignBehaviour.NONE
		 * @param	verticalAlign		 Alignment constant. Defaulted to AlignBehaviour.NONE
		 */
		public function AlignToParentBehaviour(corner:int=TOP_LEFT, horizontalAlign:int = NONE, verticalAlign:int = NONE) {
			align = horizontalAlign;
			vAlign = verticalAlign;
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
			_dispCont = targ.parent is IDisplay ? targ.parent as IDisplay : targ.parent != null ? targ.parent.parent as IDisplay: null;
			if (_dispCont == null) {
				trace("AlignToParentBehaviour activate() halt. targ  has no IDisplay parent/grandparent or parent is null!");
				// TO DO: perhaps onAddedToStageListener to activate behaviour? 
				return;
			}
			
			
			switch (_corner) {
				case TOP_LEFT: left = _disp.x; top = _disp.y; break;
				case TOP_RIGHT: right = _dispCont.width - (_disp.x + _disp.width); top = _disp.y; break;
				case BOTTOM_LEFT: left = _disp.x; bottom = _dispCont.height - (_disp.y + _disp.height); break;
				case BOTTOM_RIGHT: right = _dispCont.width - (_disp.x + _disp.width); bottom =  _dispCont.height - (_disp.y + _disp.height); break;
				default:  break;
			}
			
			/*
			if (vAlign > 0) {
				top = -1; bottom = Number.NaN;
			}
			if (align > 0) {
				left = -1; right = Number.NaN;
			}*/
			
			AncestorListener.addEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
		}
		
		/**
		 * Listens to CamoDisplayEvent.DRAW events to re-update alignment positions on-the-fly.
		 * @param	e
		 */
		protected function alignDisplayHandler(e:Event):void {
			_disp.x = align > 0 ?  align<2 ?  (_dispCont.width - _disp.width)*.5 +xOffset : 	_dispCont.width - _disp.width + xOffset :    validateXOffset();
			_disp.y = vAlign > 0 ? vAlign < 2 ? ( _dispCont.height - _disp.height) * .5 + yOffset: _dispCont.height - _disp.height	+ yOffset :   validateYOffset();
		}
		
		
		/** @private */
		protected function validateXOffset():Number {
			
			return  right != Number.POSITIVE_INFINITY ? _dispCont.width - right - _disp.width : left;
		}
		/** @private */
		protected function validateYOffset():Number {
			
			return  bottom != Number.POSITIVE_INFINITY ? _dispCont.height - bottom - _disp.height : top;
		}
		
		public function destroy():void {
			AncestorListener.removeEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
			_dispCont = null;
			_disp = null;
		}
		
		
		
	}
	
}