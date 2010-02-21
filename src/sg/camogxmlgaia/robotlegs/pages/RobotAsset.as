package sg.camogxmlgaia.robotlegs.pages 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import org.robotlegs.core.IContext;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import sg.camogxmlgaia.robotlegs.api.IMainContextProvider;
	import sg.camogxmlgaia.robotlegs.contexts.MainContext;
	/**
	 * This is the main robotlegs asset that can run as a document class and main context
	 * provider under CGG.  It requires manual startup and initialization of it's main
	 * context, providing cross-platform access to the injector/reflector.
	 * 
	 * @author Glenn Ko
	 */
	public class RobotAsset extends Sprite implements IMainContextProvider
	{
		private var _myContext:MainContext;
		
		public function RobotAsset() 
		{
			super();
		}
		
		/**
		 * Instantiates context in a particular contextView to gain access to injector/reflector
		 * @param	contextView		
		 * @return
		 */ 
		public function startup(contextView:DisplayObjectContainer):IContext {
			_myContext = new contextClass(contextView) as MainContext;
			return _myContext;
		}
		
		/**
		 * This must be a MainContext class or a class extending form MainContext
		 * @see sg.camogxmlgaia.robotlegs.contexts.MainContext
		 */
		public function get contextClass():Class {
			return MainContext;
		}
		
		/**
		 * Initializes mapping on this end
		 */
		public function init():void {
			_myContext.init();
		}
		
		
		// -- accesstors
		
		public function getInjector():IInjector {
			return _myContext.__injector;
		}
		
		public function getReflector():IReflector {
			return _myContext.__reflector;
		}
		
	}

}