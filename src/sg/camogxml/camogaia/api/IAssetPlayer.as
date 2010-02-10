package sg.camogaia.api 
{
	import com.gaiaframework.api.IAsset;
	
	/**
	 * Interface to add and play Gaia assets within some player.
	 * @author Glenn Ko
	 */
	public interface IAssetPlayer 
	{
		function addAsset(asset:IAsset):void;
		function playAsset(id:String):void;
	}
	
}