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
		
		protected var vc:Object;
		
		public function RLDestroyableMediator(vc:Object, instance:IMediator) {
			mediator = instance;
			this.vc = vc;
		}
		
		[PostConstruct]
		public function init():void {
			map.registerMediator(vc, mediator);
		}
		
		public function destroy():void {
			map.removeMediator(mediator);
			vc = null;
		}
	}

}