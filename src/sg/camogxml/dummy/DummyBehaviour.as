package sg.camogxml.dummy 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	import sg.camo.interfaces.IBehaviour;

	public class DummyBehaviour implements IBehaviour {
	
		public function DummyBehaviour():void {
		
		}
		
		public function get behaviourName():String {
			return "DummyBehaviour";
		}
			
		public	function activate(targ:*):void {
			
		}
		public function destroy():void {
			
		}
	}

}