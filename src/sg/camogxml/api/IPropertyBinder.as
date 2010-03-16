package sg.camogxml.api 
{
	import sg.camo.interfaces.IPropertyApplier;
	
	/**
	 * An extended IPropertyApplier interface with the ability to set/unset binder.
	 * @see sg.camogxml.api.IBinder
	 * 
	 * @author Glenn Ko
	 */
	public interface IPropertyBinder extends IPropertyApplier
	{
		function set binder(val:IBinder):void;
	}
	
}