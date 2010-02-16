package sg.camogxml.display.dummy 
{
	/**
	 * A spacer that also includes actual invisible physical shape graphics being drawn
	 * to be detectable by Flash. Graphics are drawn but with zero alpha.
	 * 
	 * @author Glenn Ko
	 */
	public class SpacerShape extends DivDummy 
	{
		protected var _displayFlow:String;
		
		public function SpacerShape(width:Number = 0, height:Number=0, displayFlow:String="block" ) 
		{
			_displayFlow = displayFlow;
			graphics.beginFill(0, 0);
			graphics.drawRect(0, 0, 32, 32);
			this.width = width;
			this.height = height;
		}
		
		override public function  set displayFlow(str:String):void { 
			_displayFlow = str;
		};
		override public function  get displayFlow():String {
			return _displayFlow;
		}
		
	}



}