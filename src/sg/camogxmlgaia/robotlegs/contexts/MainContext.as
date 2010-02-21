package sg.camogxmlgaia.robotlegs.contexts 
{
	import flash.display.DisplayObjectContainer;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.mvcs.Context;
	/**
	 * This main context provides a custom init method.
	 * @author Glenn Ko
	 */
	public class MainContext extends Context
	{
		
		public function MainContext(contextView:DisplayObjectContainer, autoStartup:Boolean = true) 
		{
			super(contextView, autoStartup);  
		}
		
		/**
		 * One can do further wirings/initializations here after Gaia is done wiring up stuff.
		 */
		public function init():void {
			
		}
		
		
		public function get __injector():IInjector {
			return injector;
		}
		
		public function get __reflector():IReflector {
			return reflector;
		}
	}

}