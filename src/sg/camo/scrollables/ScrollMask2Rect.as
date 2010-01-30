package sg.camo.scrollables
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import sg.camo.interfaces.IScrollProxy;
	import sg.camo.interfaces.IScrollable;
	
	/**
	 * Converts any current IScrollProxy implementation which involves scrolling content physically
	 * within masks to scrolling by scrollRect instead. 
	 * <br/>
	 * This behaviour is automatically used by <code>ScrollableBehaviour</code> if  it is found that
	 * an actual <code>scrollRect</code> is used as the "scrollMask" for the scrollContent. 
	 * 
	 * @see sg.camo.behaviour.ScrollableBehaviour
	 * 
	 * @author Glenn Ko
	 */
	public class ScrollMask2Rect implements IScrollable
	{
		protected var _dummyRef:DummyReference = new DummyReference();
		protected var _target:IScrollable;
		
		/**
		 * Constructor
		 * @param	iScroll		An IScrollProxy reference to convert.
		 */
		public function ScrollMask2Rect(iScroll:IScrollProxy) 
		{
			_target = iScroll.target;
			_dummyRef.width = iScroll.scrollContent.width;
			_dummyRef.height = iScroll.scrollContent.height;
			_dummyRef.disp = iScroll.scrollContent;	
			
			//_scrollRectProxy = new ScrollRectProxy(iScroll.scrollContent);
			
			
			iScroll.target = this;
		}
		
		public function get x():Number {
			return scrollMask.x;
		}
		public function get y():Number {
			return scrollMask.y;
		}
		
		public function get width():Number {
			return scrollContent.scrollRect.width;
		}
		public function set width(val:Number):void {
			var rect:Rectangle = scrollContent.scrollRect;
			rect.width = val;
			scrollContent.scrollRect = rect;
		}
		public function get height():Number {
			return scrollContent.scrollRect.height;
		}
		public function set height(val:Number):void {
			var rect:Rectangle = scrollContent.scrollRect;
			rect.height = val;
			scrollContent.scrollRect = rect;
		}
		
		protected function getDestScrollH (ratio:Number):Number {
			var w:Number = _dummyRef.width - scrollMask.width;
			return  (ratio * w);
		}
		
		protected function getDestScrollV(ratio:Number):Number {
			var h:Number = _dummyRef.height - scrollMask.height;
			return  (ratio * h);
		}
		
		public function set scrollH (ratio:Number):void {
			_dummyRef.x =  getDestScrollH(ratio);
		}
		public function set scrollV (ratio:Number):void {
			_dummyRef.y = getDestScrollV(ratio);
		}
		
		
		public function get scrollContent():DisplayObject {
			return _dummyRef;
		}
		public function resetScroll():void {
			_dummyRef.x = 0;
			_dummyRef.y = 0;
		}
		
		

		public function get scrollContainer ():Sprite {
			return _target.scrollContainer;
		}
		public function get scrollMask ():* {
			return scrollContent.scrollRect;
		}
		public function get itemLength ():Number {
			return _target.itemLength;
		}
		public function set itemLength (val:Number):void {
			 _target.itemLength = val;
		}
		
		public function destroy():void {
			_target = null;
			_dummyRef = null;
		}
			
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			_target.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			_target.removeEventListener(type, listener, useCapture);
		}

		
	}

}

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.Rectangle;


	internal class DummyReference extends Shape {
		
		private var _disp:DisplayObject;
		private var _scrollRect:Rectangle;
		private var _width:Number;
		private var _height:Number;
		
		public function DummyReference(width:Number=0, height:Number=0, disp:DisplayObject=null) {
			this.disp = disp;
			_width = width;
			_height = height;
		}
		
		public function set disp(d:DisplayObject):void {
			_disp = d;
		}

		override public function set x(val:Number):void {
			var rect:Rectangle = _disp.scrollRect;
			rect.x = -val;
			_disp.scrollRect = rect;
		}
		override public function get x():Number {
			return -_disp.scrollRect.x;
		}
		override public function get scrollRect():Rectangle {
			return _disp.scrollRect;
		}
		
		override public function set y(val:Number):void {
			var rect:Rectangle = _disp.scrollRect;
			rect.y = -val;
			_disp.scrollRect = rect;
		}
		override public function get y():Number { 
			return -_disp.scrollRect.y;
		}
		
		override public function set width(val:Number):void {
			_width = val;
		}
		override public function set height(val:Number):void {
			_height = val;
		}
		
		override public function get width():Number {
			return _width;
		}
		override public function get height():Number { 
			return _height;
		}
		
		
		
	}

