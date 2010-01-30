package sg.camo.interfaces 
{
	
	/**
	* Required public interface properties for div elements to be layoutable.
	* @author Glenn Ko
	*/
	public interface IDiv 
	{
		function set displayFlow(str:String):void; 
		function get displayFlow():String;
		
		function set position(str:String):void;
		function get position():String;
		
		function set left(num:Number):void;
		function get left():Number;
		
		function set top(num:Number):void;
		function get top():Number;
		
		function set right(num:Number):void;
		function get right():Number;
		
		function set bottom(num:Number):void;
		function get bottom():Number;
		
		// borrowed from ICamoDisplay
		function get zIndex():Number;
		function get align():String;
		function get verticalAlign():String;
		
	}
	
}