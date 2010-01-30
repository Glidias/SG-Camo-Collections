package sg.camo.interfaces 
{
	
	/**
	 * Marker interface to identify self-reflectable instance that reflects a specific base class. 
	 * <br/>
	 * This is normally implemented by classes that are instantiated from Flash Library symbols so that they'll
	 * always provide a consistent base class signature for external agents calling describeType() or getQualfiedClassName()
	 * on them.
	 * 
	 * @see camo.core.utils.ClassInspect
	 * 
	 * @author Glenn Ko
	 */
	public interface IReflectClass 
	{
		function get reflectClass():Class;

	}
	
}