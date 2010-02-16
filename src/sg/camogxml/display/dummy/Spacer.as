package sg.camogxml.display.dummy 
{
	import flash.display.DisplayObject;
	/**
	 * Dummy abstract customisable spacer to simply set width/height spacing in between divs,
	 * or set row heights for inline elements, or produce line breaks. No graphics are being drawn.
	 * 
	 * @author Glenn Ko
	 */
	public class Spacer extends DivDummy
	{
		protected var _displayFlow:String;
		protected var _width:Number;
		protected var _height:Number;
		
		public function Spacer(width:Number = 0, height:Number=0, displayFlow:String="block") 
		{
			_width = width;
			_height = height;
			_displayFlow = displayFlow;
		}
		
		override public function  set displayFlow(str:String):void { 
			_displayFlow = str;
		};
		override public function  get displayFlow():String {
			return _displayFlow;
		}
		override public function set width(num:Number):void {
			_width = num;
		}
		override public function get width():Number {
			return _width;
		}
		
		override public function set height(num:Number):void {
			_height = num;
		}
		override public function get height():Number {
			return _height;
		}
		
		
		

		
	}

}