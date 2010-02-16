/*
 Copyright (c) 2009 Paulius Uza  <paulius@uza.lt>
 http://www.uza.lt
 All rights reserved.
  
 Permission is hereby granted, free of charge, to any person obtaining a copy 
 of this software and associated documentation files (the "Software"), to deal 
 in the Software without restriction, including without limitation the rights 
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished 
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all 
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@ignore
*/

/**
 * Original class: lt.uza.ui.Scale9SimpleButton<br/>
 * http://www.uza.lt
 * 
 * Repackaged under SG-Camo. (Refactored to IBehaviour)
 * @author Glenn
 */

package sg.camoextras.behaviour 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import sg.camo.behaviour.SkinBehaviour;
	import sg.camo.interfaces.IAncestorSprite;
	import sg.camo.interfaces.IResizable;
	import sg.camo.interfaces.ISelectable;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import sg.camoextras.display.Scale9BitmapSprite;
	
	/**
	 * Extended skin behaviour to inject a new Scale9BitmapSprite-based skin with mouse up,over,down and selectable states
	 * over a particular target DIsplayObjectContainer.
	 * <br><br>
	 * If selected, state bitmapData will be held in "down" state.<br>
	 * <br/>
	 *  Original class: lt.uza.ui.Scale9SimpleButton<br/>
	 * http://www.uza.lt
	 * 
	 * 
	 * @see sg.camoextras.display.Scale9BitmapSprite
	 * 
	 * @author Paulius Uza
	 * @author Glenn Ko
	 */
	public class Scale9SimpleStateBehaviour extends SkinBehaviour implements ISelectable
	{
		
		public static const NAME:String = "Scale9SimpleStateBehaviour";
		
		/**
		 * STATE BITMAP DATA OBJECTS
		 */
		 
		private var state_normal:BitmapData;
		private var state_hover:BitmapData;
		private var state_down:BitmapData;
		
		/**
		 * STATE PARAMETERS
		 */
		
		private var has_hover:Boolean = false;
		private var has_down:Boolean = false;
		private var hovering:Boolean = false;
		private var is_selected:Boolean = false;
		

		private var instance:Scale9BitmapSprite;
		
		/** Flag to determine whether to clone bitmapData source states for current behaviour and Scale9BitmapSprite.
		*/
		public var cloneSource:Boolean = true;
		
		/**
		 * Default setting to determine whether to clone sources for current behaviour and Scale9BitmapSprite
		 */
		public static var CLONE_SOURCE:Boolean = true;
		
		public var grid:Rectangle;
		

		/**
		 * Boolean "selected" allows to toggle the button. 
		 * When "selected" is set to true, only "down" state of the button is displayed.
		 */

		public function set selected(value:Boolean):void {
			is_selected = value;
			if(is_selected) {
				instance.updateState(state_down);
			} else {
				if(hovering) {
					instance.updateState(state_hover);
				} else {
					instance.updateState(state_normal);
				}
			}
		}
	
		/**
		 *  Returns Boolean
		 *  representing if the button is selected
		 */
		
		public function get selected():Boolean {
			return is_selected;
		}
		
		/**
		 * NOTE: This still needs further testing to be fully robust, especially for case 2 and 3. (might omit that)
		 * Scans a display object to "wild-guess" and attempts to draw new bitmapData snapshot instances 
		 * of differnet button states based on DisplayObject type.
		 * <br/><br/>
		 * Currently accepts:<br/>
		 * <code>SimpleButton</code> - Checks upStates,  overState and downState of button.
		 * <code>MovieClip</code> - Checks frame 1-3 of movieclip for the above button states..
		 * <code>DisplayObjectContainer</code> - Checks depths from 0-2 of displayObjectContainer for the above button states. 
		 * 
		 */
		override public function set skin(disp:DisplayObject):void {
			// do nothing or attempt to wild-guess skin states from DisplayObject type and dynamically generate bmpData
			var i:int;
			
			if (disp is SimpleButton) {
				var btn:SimpleButton = disp as SimpleButton;
				if (btn.upState is IBitmapDrawable) normalBmpData = drawNewBmpData(chk9(btn.upState));
				if (btn.downState is IBitmapDrawable) downBmpData = drawNewBmpData(chk9(btn.downState));
				if (btn.overState is IBitmapDrawable) hoverBmpData = drawNewBmpData(chk9(btn.overState));
			}
			else if (disp is MovieClip) {
				var mc:MovieClip = disp as MovieClip;
				i = mc.totalFrames;
				i = i < 4 ? i : 3;
				while (--i > 0) {
					mc.gotoAndStop(i);
					this[getTargIndexProp(i)] = drawNewBmpData(mc);
				}
				chk9(mc);
			}
			else if (disp is DisplayObjectContainer) {
				var cont:DisplayObjectContainer = disp as DisplayObjectContainer;
				i = cont.numChildren;
				i = i < 3 ? i : 2;
				while (--i > -1) {
					this[getTargIndexProp(i)] = drawNewBmpData( chk9(cont.getChildAt(i)) );
				}
			}
			_skin = disp;
		}
		
		/**
		 * @private
		 */
		protected function getTargIndexProp(id:int):String {
			switch (id) {
				case 1: return "normalBmpData";
				case 2: return "hoverBmpData";
				case 3: return "downBmpData";
				default: break;
			}
			return "normalBmpData";
		}
		
		/**
		 * @private
		 */
		protected function chk9(disp:DisplayObject):DisplayObject {
			if (grid != null) return disp; // grid already set, ignore
			
			if (disp.scale9Grid) scale9Grid = disp.scale9Grid;	// guess grid
			return disp;
		}
		
		/**
		 * @private
		 */
		protected function drawNewBmpData(dispObj:DisplayObject):BitmapData {
			var bmpData:BitmapData = new BitmapData(dispObj.width, dispObj.height, true, 0);
			bmpData.draw(dispObj as IBitmapDrawable);
			return bmpData;
		}
		
		
		
		/**
		 * Constructor
		 * @param	requiredSkin	 Sets Scale9BitmapSprite skin by constructor parameter (required to set before activation ).
		 */
		
		/**
		 * 
		 * @param	scale9Grid	Required,  prior to activation
		 * @param	normal		Required for normal state bitmapdata,  prior to activation
		 * @param	hover		(Optional)	hover state bitmapdata
		 * @param	down		(Optional)	down state bitmapdata
		 * @param	cloneSource	(Optional) Will use default static variable setting if remains at -1. <br/>
		 * @param 	skin 		(Optional)	If you use this, will inject a via <code>skin</code> setter to determine bitmapData states instead
		 * 			Set to 0 to NOT clone sources, anything higher than 0 (ie. 1) to enable cloning of source bmpData.
		 */
		public function Scale9SimpleStateBehaviour(scale9Grid:Rectangle=null, normal:BitmapData=null, hover:BitmapData = null, down:BitmapData = null, cloneSource:int = -1, skin:DisplayObject=null) 
		{
			super();
			normalBmpData = normal;
			hoverBmpData = hover;
			downBmpData = down;
			this.scale9Grid = scale9Grid;
			this.cloneSource = cloneSource > -1 ? cloneSource > 0 : CLONE_SOURCE;
			if (skin != null) this.skin = skin;
		}
		
		/**
		 * Sets scale9Grid prior to activation. Required parameter if not set in constructor!
		 */
		public function set scale9Grid(rect:Rectangle):void {
			grid = rect;
		}
		public function get scale9Grid():Rectangle {
			return grid;
		}
		
		/**
		 * Sets normal bitmapData state prior to activation. Required parameter if not set in constructor.
		 */
		public function set normalBmpData(bmpData:BitmapData):void {
			if (bmpData == null) {
				return;
			}
			state_normal = cloneSource ? bmpData.clone() : bmpData;
		}
		/**
		 * Sets hover bitmapData state prior to activation. This is optional.
		 */
		public function set hoverBmpData(bmpData:BitmapData):void {
			if (bmpData == null) {
				return;
			}
			has_hover = true;
			state_hover = cloneSource ? bmpData.clone() : bmpData;
		}
		/**
		 * Sets down bitmapData state prior to activation.  This is optional.
		 */
		public function set downBmpData(bmpData:BitmapData):void {
			if (bmpData == null) {
				return;
			}
			has_down = true;
			state_down = cloneSource ? bmpData.clone() : bmpData;
		}
		
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Sets up target dispatching container. Also attempts to find a pre-built "skin" reference in container if available.
		 * @param	targ
		 */
		override public function activate(targ:*):void {
			var tryCont:DisplayObjectContainer = targ as DisplayObjectContainer;
			if (tryCont == null) {
				trace(NAME+" activate() halt! Targ isn't DisplayObjectContainer or null!");
			}
			if (_skin==null) {
				var trySkin:DisplayObject = tryCont is IAncestorSprite ? (tryCont as IAncestorSprite).$getChildByName("skin") : tryCont.getChildByName("skin");
				if (trySkin != null) {
					trySkin.visible = false; //assert vis false
					if (tryCont is IResizable) (tryCont as IResizable).resize(trySkin.width, trySkin.height);
					skin = trySkin;
				}
			}
			
			if (state_normal == null) {
				trace(NAME+" activate() halt! No normalBmpData supplied!");
				return;
			}
			if (grid == null) {
				trace(NAME+" activate() halt! No scale9Grid supplied!");
				return;
			}
			// supply backup states
			if (state_hover == null) {
				state_hover = cloneSource ? state_normal.clone() : state_normal;
			}
			if (state_down == null) {
				state_down = cloneSource ? state_normal.clone() : state_normal;
			}
			
			trace(state_down.rect, state_hover.rect, state_normal.rect);
			if(state_normal.rect.equals(state_hover.rect) && state_normal.rect.equals(state_down.rect)) {
				init(targ);
			} else {
				/* 
				 * WIDTH AND HEIGHT OF THE BITMAP DATA OBJECT REPRESENTING EACH STATE (NORMAL, HOVER, DOWN) 
				 * MUST BE EQUAL. 
				 */
				throw(new Error("State bitmap data dimensions must be equal"));
			}
			
		}
		
		private function init(targ:*):void {
			var cloneVal:int = cloneSource  ? 1 : 0;
			instance = new Scale9BitmapSprite(state_normal, grid, cloneVal  );
			_skin = instance;
			
			super.activate(targ);
			
			if (_disp == null) return;
			
			if(has_hover) {
				_disp.addEventListener(MouseEvent.ROLL_OVER, onStateRollOver, false, 0, true);
				_disp.addEventListener(MouseEvent.ROLL_OUT, onStateRollOut, false, 0, true);
			}
			if(has_down) {
				_disp.addEventListener(MouseEvent.MOUSE_DOWN, onStateMouseDown, false, 0, true);
				_disp.addEventListener(MouseEvent.MOUSE_UP,onStateMouseUp, false, 0, true);
			}
			_disp.addEventListener("selected", onSelected, false, 0, true);
			_disp.addEventListener("unselected", onUnSelected, false, 0, true);
			
		}
	
		/**
		 * In response to "selected" event dispatches from SelectionBehaviour or deriative classes thereoff.
		 * @see sg.camo.behaviour.SelectionBehaviour
		 * 
		 * @param	e
		 */
		protected function onSelected(e:Event):void {
			selected = true;
		}
		
		/**
		 * In response to "unselected" event dispatches from SelectionBehaviour or deriative classes thereoff.
		 * @see sg.camo.behaviour.SelectionBehaviour
		 * 
		 * @param	e
		 */
		protected function onUnSelected(e:Event):void {
			selected = false;
		}
		
		/**
		 * Event Handler
		 * On Mouse Over
		 */
		
		private function onStateRollOver(evt:MouseEvent):void {
			hovering = true;
		
			if(!is_selected) {
				instance.updateState(state_hover);
			}
		}
		
		/**
		 * Event Handler
		 * On Mouse Out
		 */
		
		private function onStateRollOut(evt:MouseEvent):void {
			hovering = false;
			if(!is_selected) {
				instance.updateState(state_normal);
			}
		}
		
		/**
		 * Event Handler
		 * On Mouse Down
		 */
		
		private function onStateMouseDown(evt:MouseEvent):void {
			instance.updateState(state_down);
		}
		
		/**
		 * Event Handler
		 * On Mouse Up
		 */
		
		private function onStateMouseUp(evt:MouseEvent):void {
			if(!selected) {
				if(hovering) {
					instance.updateState(state_hover);
				} else {
					instance.updateState(state_normal);
				}
			}
		}
		
		
		
		override public function destroy():void {
			if (cloneSource) {
				state_normal.dispose();
				if (has_hover) state_hover.dispose();
				if (has_down) state_down.dispose();
			}
			if(has_hover) {
				_disp.removeEventListener(MouseEvent.ROLL_OVER, onStateRollOver);
				_disp.removeEventListener(MouseEvent.ROLL_OUT, onStateRollOut);
			}
			if(has_down) {
				_disp.removeEventListener(MouseEvent.MOUSE_DOWN, onStateMouseDown);
				_disp.removeEventListener(MouseEvent.MOUSE_UP,onStateMouseUp);
			}
			_disp.removeEventListener("selected", onSelected);
			_disp.removeEventListener("unselected", onUnSelected);
			super.destroy();
		}
		
	}

}