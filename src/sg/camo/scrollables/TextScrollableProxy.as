package sg.camo.scrollables 
{
	
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import sg.camo.events.OverflowEvent;
	import sg.camo.interfaces.IScrollable;
	import sg.camo.interfaces.IText;
	import flash.events.MouseEvent;
	

	/**
	 * IScrollable class that can work on multi-line textfields. <br/>
	 * Targets textfields specifically.
	 * <br/><br/>
	 * <i>TODO: Horizontal scrolling support as well, for even single-line textfields.</i>
	 * 
	 * @author Glenn Ko
	 */
	public class TextScrollableProxy extends Sprite implements IScrollable, IText
	{
		protected var _target:TextField;
		protected var _textContent:DisplayObject;
		public var scrollLines:int = 1;
		
		/**
		 * Constructor
		 * @param	txtField	Activates textfield to allowing scrolling, including listening for any content/scroll updates.
		 */
		public function TextScrollableProxy(txtField:TextField) 
		{
			_target = txtField;	
			
			_target.addEventListener(Event.CHANGE, contentUpdateHandler, false , -1, true);
			_target.addEventListener(Event.SCROLL, contentUpdateHandler, false , -1, true);
			//_target.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler, false , -1, true);
			
			_textContent = new TextContent(txtField);
			
			if (txtField.stage != null) {
				txtField.stage.addEventListener(Event.RENDER, onRender, false , 0, true);
				txtField.stage.invalidate();
			}
			else {
				txtField.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false , 0, true);
			}
		}
		
		/*
		private function mouseWheelHandler(e:MouseEvent):void {
			//_target.visbile = false;
		//	dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
			scrollContainer.dispatchEvent(e); // re-dispatch event from "scrollContainer"
		}
		*/
		
		
		public function destroy():void {
			_target.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			_target.removeEventListener(Event.CHANGE, contentUpdateHandler);
			_target.removeEventListener(Event.SCROLL, contentUpdateHandler);
		//	_target.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
			_target = null;
			_textContent = null;
		}
		
		
		public function set text (str:String):void {
			_target.text = str;
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
		}
		public function set htmlText(str:String):void {
			_target.htmlText = str;
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
		}
		public function appendText(text:String):void {
			_target.appendText(text);
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
		}
		public function get text ():String {
			return _target.text;
		}
		
		protected function onRender(e:Event):void {
			e.currentTarget.removeEventListener(e.type, onRender);
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
		}
		protected function onAddedToStage(e:Event):void {
			_target.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_target.stage.addEventListener(Event.RENDER, onRender, false , 0, true);
		}
		
		/**
		 * Adjust overflow settings for textfield.
		 * 
		 * @see sg.camo.events.OverflowEvent
		 */
		public function set overflow(str:String):void {
			var value:int;
			switch (str) {
				case "none" :  value = OverflowEvent.NONE;  break;
				case "hidden" :  value = OverflowEvent.HIDDEN; break;
				case "visible" : value = OverflowEvent.NONE; break; 
				case "scroll" : value = OverflowEvent.SCROLL;   break; 
				case "auto" : value = OverflowEvent.AUTO ;  break;
				default:  return;
			}
			scrollContainer.dispatchEvent( new OverflowEvent(value) );
		}
		
		/** @private */
		protected var _meScrolling:Boolean = false;
		/**
		 * Dispatches a CamoDisplay.DRAW event in response to text content changes or text marker scrolling changes. 
		 * This usually triggers listening scrollbars to update itself to fit the new content placement and size.
		 * @param	e	(Event)
		 */
		protected function contentUpdateHandler(e:Event):void {
			if (_meScrolling) {
				_meScrolling = false;
				return;
			}
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW) );
		}
		
		
		public function set scrollH(ratio:Number):void {
			//_meScrolling = true;
			_target.scrollH = Math.ceil(_target.maxScrollH * ratio);
			//_meScrolling = false;
		}
		public function set scrollV(ratio:Number):void {
			//_meScrolling = true;
			_target.scrollV = Math.ceil(_target.maxScrollV * ratio);
			//_meScrolling = false;
		}
		
		override public function get width():Number {
			return  _target.width;
		}
		override public function get height():Number {
		//	trace("retrieved container height:" + (_target.numLines - (_target.maxScrollV-1) ) );
			return  _target.numLines - (_target.maxScrollV-1);
			
		}
		
		public function resetScroll():void {
			_target.scrollH = 1;
			_target.scrollV = 1;
		}

		public function get scrollContainer ():Sprite {
			return  this;
		}
		public function get scrollMask ():* {
			return this;
		}
		public function get scrollContent ():DisplayObject {
			return _textContent;
		}
		public function get itemLength ():Number {
			return scrollLines;
		}
		public function set itemLength(val:Number):void {
			scrollLines = int(val);
		}

		
	}
	

}

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.text.TextField;
import sg.camo.interfaces.ITextField;

	internal class TextContent extends Shape implements ITextField {
		
		protected var _targ:TextField;
		
		public function TextContent(targField:TextField) {
			_targ = targField;
		}
		
		public function get textField():TextField {
			return _targ;
		}
	
		override public function get width():Number {
			return _targ.textWidth;
		}
		override public function get height():Number {
			//trace("retrieved content height:" + (_targ.numLines) );
			return _targ.numLines;
		}
		
		override public function set x(val:Number):void {
			super.x = Math.round(val);
			_targ.scrollH = x;
		}
		
		override public function set y(val:Number):void {
			val =  Math.round(val);
			_targ.scrollV = val;
		}
		
		override public function get y():Number {
			return -_targ.scrollV;
		}
		
		
		
	}