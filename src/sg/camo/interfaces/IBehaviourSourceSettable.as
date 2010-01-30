package sg.camo.interfaces 
{
	
	/**
	 * Marker interface to identify objects which can be supplied with a behaviour source.
	* @see sg.camo.behaviour
	* @author Glenn Ko
	*/
	public interface IBehaviourSourceSettable 
	{
		function set behaviourSource(src:IBehaviouralBase):void;
	}
	
}