package sg.camo.interfaces 
{
	import flash.display.BitmapData;
	
	/**
	 * Marker interface for classes that compose a bitmapdata instance (such as Bitmap or Decals)
	 * @author Glenn Ko
	 */
	public interface IBitmapData
	{
		function set bitmapData(bmpData:BitmapData):void;
	}
	
}