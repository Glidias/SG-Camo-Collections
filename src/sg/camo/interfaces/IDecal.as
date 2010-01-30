package sg.camo.interfaces 
{
	
	/**
	 * Marker interface for Camo decals, with specific Decal methods.
	 * @author Glenn Ko
	 */
	public interface IDecal extends IBitmapData
	{
		function refresh():void;
		function detach():void;
	}
	
}