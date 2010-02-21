package sg.camogxmlgaia.robotlegs.adaptors 
{

	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IMediatorMap;
	import sg.camo.interfaces.IDestroyable;

	/**
	 * Mediator holder with IDestroyable interface signature
	 * @author Glenn Ko
	 */
	public class RLDestroyableMediator implements IDestroyable {
		
		private var mediator:IMediator;
		
		[Inject]
		public var map:IMediatorMap;
		
		public function RLDestroyableMediator(vc:Object, instance:IMediator) {
			mediator = instance;
			map.registerMediator(vc, mediator);
		}
		
		public function destroy():void {
			map.removeMediator(mediator);
		}
	}

}