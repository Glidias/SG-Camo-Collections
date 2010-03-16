package sg.camogxml.display.dummy 
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import sg.camo.interfaces.IDiv;
	/**
	 * Boiler-plate div dummy base class extending from Shape. Also used for reflection inspectable UI purposes.
	 * @author Glenn Ko
	 */
	public class DivDummy extends Shape implements IDiv
	{
		
		public function DivDummy() 
		{
			
		}
		
		// dummy unused
		
		[CamoInspectable(description="Block or inline setting for static flow positioning. Block is for breaking singular elements while inline elements flow from left-to-right and wrap to container's size", type="selection(block|inline)")]
		public function  set displayFlow(str:String):void { 
			// do nothing
		};
		public function  get displayFlow():String {
			return "block";
		}
		
		[CamoInspectable(description="Position static/relative keeps display flow by default, but setting it to 'absolute' aligns elements relative off parent container's edge.", type="selection(static|relative|absolute)")]
		public function  set position(str:String):void { };
		public function  get position():String {
			return "static";
		}
		
		[CamoInspectable(description="When position is relative, this value re-adjusts x position relative off current flow position. For 'absolute', adjusts position relative off container's left edge as x position.")]
		public function  set left(num:Number):void { };
		public function  get left():Number {
			return 0;
		}
		
		[CamoInspectable(description="When position is relative, this value re-adjusts y position relative off current flow position. For 'absolute', adjusts position relative off container's top edge as y position.")]
		public function  set top(num:Number):void {}
		public function  get top():Number {
			return 0;
		}
		
		[CamoInspectable(description = "For 'absolute', adjusts positioning relative off right edge of parent container")]
		public function  set right(num:Number):void {}
		public function  get right():Number {
			return 0;
		}
		
		[CamoInspectable(description = "For 'absolute', adjusts positioning relative off bottom edge of parent container")]
		public function  set bottom(num:Number):void {}
		public function  get bottom():Number {
			return 0;
		}
	
		[CamoInspectable(description="Sets priority-based z-indexing with any positive/negative value for independant depth management", type="int")]
		public function get zIndex():Number {
			return 0;
		}
		
		[CamoInspectable(description="Sets individual vertical alignment of display object for inline display flow.", type="vAlignRatio", defaultValue="top")]
		public function set verticalAlign(val:String):void {}
		public function get verticalAlign():String {
			return "none";
		}
		
		[CamoInspectable(description="NOTE: This property doesn't do anything and would be depecrated.")]
		public function set align(val:String):void {}
		public function get align():String {
			return "none";
		}
		
		[CamoInspectable(description="Controls individual margin left spacing for inline and block settings")]
		public function get marginLeft():Number {
			return 0;
		}
		[CamoInspectable(description="Controls individual margin right spacing for inline and block settings")]
		public function get marginRight():Number {
			return 0;
		}
		
		[CamoInspectable(description="Controls individual margin top spacing for only block setting. This doesn't do anything if element is inline.")]
		public function get marginTop():Number {
			return 0;
		}
		[CamoInspectable(description="Controls individual margin bottom spacing for only block setting. This doesn't do anything if element is inline.")]
		public function get marginBottom():Number {
			return 0;
		}

		
		
		
	}

}