package sg.camogxml.display.dummy 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import sg.camo.interfaces.IDiv;
	/**
	 * Boiler-plate div dummy base class extending from Shape.
	 * @author Glenn Ko
	 */
	public class DivDummy extends Shape implements IDiv
	{
		
		public function DivDummy() 
		{
			
		}
		
		// dummy unused
		
		public function  set displayFlow(str:String):void { 
			// do nothing
		};
		public function  get displayFlow():String {
			return "block";
		}
		
		public function  set position(str:String):void { };
		public function  get position():String {
			return "static";
		}
		
		public function  set left(num:Number):void { };
		public function  get left():Number {
			return 0;
		}
		
		public function  set top(num:Number):void {}
		public function  get top():Number {
			return 0;
		}
		
		public function  set right(num:Number):void {}
		public function  get right():Number {
			return 0;
		}
		
		public function  set bottom(num:Number):void {}
		public function  get bottom():Number {
			return 0;
		}
		
	
		public function get zIndex():Number {
			return 0;
		}
		public function get verticalAlign():String {
			return "none";
		}
		public function get align():String {
			return "none";
		}
		
	
		public function get marginLeft():Number {
			return 0;
		}
		public function get marginTop():Number {
			return 0;
		}
		public function get marginBottom():Number {
			return 0;
		}
		public function get marginRight():Number {
			return 0;
		}
		
		
		
	}

}