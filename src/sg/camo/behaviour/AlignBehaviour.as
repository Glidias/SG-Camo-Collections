package sg.camo.behaviour {
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import camo.core.events.CamoDisplayEvent;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	* Performs horizontal and/or vertical aligning of display.
	* <br/><br>
	* AlignBehaviour uses the IDisplay's <code>displayWidth</code> and <code>displayHeight</code> properties 
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
		
		public static const LEFT:int = 0;
		public static const RIGHT:int = 2;
		
		public static const MIDDLE:int = 1;
		
		public static const TOP:int = 0;
		public static const BOTTOM:int = 2;
		
		public static const NONE:int = -1;
		

		public var align:int = AlignBehaviour.LEFT;
		public var vAlign:int = AlignBehaviour.TOP;
		
		/** Y offset positioning from current alignment */
		public var yOffset:Number = 0;
		
		/** X offset positioning from current alignment */
		public var xOffset:Number = 0;
		
		/**
		 * Constructor. 
		 * 
		 * @param	horizontalAlign	  Defaulted to AlignBehaviour.LEFT 
		 * @param	verticalAlign	   Defaulted to  AlignBehaviour.TOP
		 */
		public function AlignBehaviour(horizontalAlign:int = AlignBehaviour.LEFT, verticalAlign:int = AlignBehaviour.TOP) {
			align = horizontalAlign;
			vAlign = verticalAlign;
		}
		
		public function set horizontalAlign(str:String):void {
			var aligner:int;
			switch (str) {
				case "left": aligner = AlignBehaviour.LEFT;  break;
				case "middle": aligner = AlignBehaviour.MIDDLE;break;
				case "right":aligner = AlignBehaviour.RIGHT; break;
				case "none":aligner = AlignBehaviour.NONE; break;
				default:return;
			}
			align = aligner;
		}
		public function set verticalAlign(str:String):void {
			var aligner:int;
			switch (str) {
				case "top": aligner = AlignBehaviour.TOP; break;
				case "middle": aligner = AlignBehaviour.MIDDLE;break;
				case "bottom": aligner = AlignBehaviour.BOTTOM; break;
				case "none":aligner = AlignBehaviour.NONE; break;
				default:return;
			}
			vAlign = aligner;
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
			if (_dispCont == null) {
				trace("AlignBehaviour activate() halt. targ as IDisplay is null!");
				return;
			}
			AncestorListener.addEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
			//_dispCont.addEventListener( CamoDisplayEvent.DRAW, alignDisplayHandler, false, 0, true);
		}
		
	
		protected function alignDisplayHandler(e:Event):void {

			var disp:DisplayObject = _dispCont.getDisplay();
			
			if (align != AlignBehaviour.NONE) disp.x = align > 0 ?  align<2 ?  (_dispCont.width - _dispCont.displayWidth)*.5 +xOffset : 	_dispCont.width - _dispCont.displayWidth + xOffset :    disp.x + xOffset;
			if (vAlign != AlignBehaviour.NONE) disp.y = vAlign > 0 ? vAlign < 2 ? ( _dispCont.height - _dispCont.displayHeight) * .5 + yOffset: _dispCont.height - _dispCont.displayHeight	+ yOffset :    disp.y + yOffset;
		}
		
		public function destroy():void {
			AncestorListener.removeEventListenerOf(_dispCont as IEventDispatcher, CamoDisplayEvent.DRAW, alignDisplayHandler);
			//_dispCont.removeEventListener( CamoDisplayEvent.DRAW, alignDisplayHandler, false);
			_dispCont = null;
		}
		
		
	}
	
}