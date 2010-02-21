package sg.camogxmlgaia.robotlegs.api 
{
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IContext;
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.core.IMediatorMap;
	import org.robotlegs.core.IContextProvider;
	
	
	/**
	 * To be imported to Main to allow cross-platform access. Just declare this class reference.
	 * @author Glenn Ko
	 */
	public class RobotlegsInterfaces
	{
		
		public function RobotlegsInterfaces() 
		{
			IMediator;
			IContext;
			IInjector;
			IReflector;
			IMediatorMap;
			IContextProvider;
			IMainContextProvider;
		}
		
	}

}