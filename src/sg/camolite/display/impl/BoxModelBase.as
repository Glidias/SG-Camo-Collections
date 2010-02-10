package sg.camolite.display.impl
{
	import camo.core.display.BoxModelDisplay;
	import sg.camo.interfaces.IReflectClass;
	/**
	 * A On-stage sprite whose bounds determines the width/height of the 
	 * box model.
	 * @author Glenn Ko
	 */
	public class BoxModelBase extends BoxModelDisplay implements IReflectClass
	{
		private static const RED_BASE:uint = 0xB5342F;
		private static const BLUE_BASE:uint = 0x2156A6;
		
		public function BoxModelBase() 
		{
			width = $width;
			height = $height;
		}
		
		public function set cleanup(count:int):void {
			while (--count > -1) {
				if ($numChildren > 0) $removeChildAt(0)
				else break;
			}
		}
		
		public function get reflectClass():Class {
			return BoxModelBase;
		}
		
	}

}