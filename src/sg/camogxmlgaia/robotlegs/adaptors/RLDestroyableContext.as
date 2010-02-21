package sg.camogxmlgaia.robotlegs.adaptors 
{
	import org.robotlegs.core.IContext;
	import sg.camo.interfaces.IDestroyable;

	/**
	 * Context holder with IDestroyable interface signature
	 * @author Glenn Ko
	 */
	public class RLDestroyableContext implements IDestroyable {
		
		private var context:IContext;
		
		public function RLDestroyableContext(vc:Object, instance:IContext) {
			context = instance;
		}
		
		public function destroy():void {
			Object(context).shutdown();  // hackish way since can't shutdow context remotely
		}
		
	}

}