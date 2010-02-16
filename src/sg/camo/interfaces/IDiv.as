package sg.camo.interfaces 
{
	
	/**
	 * This interface provides a set of methods defining display flow, absolute positioning, margining, 
	 * etc. 
	* It consists of all the properties required for div elements to be layoutable under 
	* DivLayoutBehaviour.
	* 
	* @see sg.camo.behaviour.DivLayoutBehaviour
	* 
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
		function get verticalAlign():String;
		function get align():String;
		
		// borrowed from IBoxModel
		function get marginLeft():Number;
		function get marginTop():Number;
		function get marginBottom():Number;
		function get marginRight():Number;
		
		
		// borrowed from DisplayObject boiler-plate
		function set x(num:Number):void;
		function get x():Number;
		
		function set y(num:Number):void;
		function get y():Number;
		
		function set width(num:Number):void;
		function get width():Number;
		
		function set height(num:Number):void;
		function get height():Number;
		
	}
	
}