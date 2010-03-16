package sg.camogxmlgaia.api 
{
	import sg.camo.interfaces.INodeClassSpawner;
	
	/**
	 * Marker interface for assets that require dynamic instantiation/dependency injection
	 * through a provided NodeClassSpawner implementation.
	 * 
	 * @author Glenn Ko
	 */
	public interface INodeClassAsset 
	{
		function spawnClass(spawner:INodeClassSpawner):*;
	}
	
}