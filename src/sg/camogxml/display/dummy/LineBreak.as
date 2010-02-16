package sg.camogxml.display.dummy 
{
	/**
	 * Hardcoded override settings for strict block line break, without the ability
	 * to set width and height. No graphics are being drawn.
	 * 
	 * @author Glenn Ko
	 */
	public class LineBreak extends DivDummy
	{
		
		public function LineBreak() 
		{
			super();
		}
		
		override public function set width(num:Number):void {
			// do nothing
		}
		override public function get width():Number {
			return 0;
		}
		
		override public function set height(num:Number):void {
			// do nothing
		}
		override public function get height():Number {
			return 0;
		}
	}

}