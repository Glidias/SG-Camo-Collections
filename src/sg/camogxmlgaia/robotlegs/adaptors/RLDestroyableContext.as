package sg.camogxmlgaia.robotlegs.adaptors 
{
	import org.robotlegs.core.IContext;
	import org.robotlegs.core.IInjector;
	import sg.camo.interfaces.IDestroyable;

	/**
	 * Context holder with IDestroyable interface signature
	 * @author Glenn Ko
	 */
	public class RLDestroyableContext implements IDestroyable {
		
		private var context:IContext;
		
		[Inject]
		public var injector:IInjector;
		
		public function RLDestroyableContext(vc:Object, context:IContext) {
			this.context = context;
		}
		
		public function destroy():void {
			Object(context).shutdown();  // hackish way since can't shutdow context remotely
		}
		
	}

}