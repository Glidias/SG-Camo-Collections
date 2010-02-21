package sg.camogxmlgaia.robotlegs.api 
{
	import flash.display.DisplayObjectContainer;
	import org.robotlegs.core.IContext;
	import org.robotlegs.core.IContextProvider;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	
	/**
	 * Standard interface that provides IInjector/IReflector/IContext public api, to allow cross-platform
	 * wirings.
	 * @author Glenn Ko
	 */
	public interface IMainContextProvider
	{
		function getInjector():IInjector;
		function getReflector():IReflector;
		function startup(targContext:DisplayObjectContainer):IContext;
		function init():void;
	}
	
}