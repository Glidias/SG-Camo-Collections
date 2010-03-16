package sg.camogxml.mx.hosts 
{
	
	/**
	 * Public interface signature to allow rebinding of host proxy to a new host.
	 * This is usually a binded setter along a property chain.
	 * @author Glenn Ko
	 */
	public interface IHostProxy 
	{
		function rebind(newHost:Object):void;
	}
	
}