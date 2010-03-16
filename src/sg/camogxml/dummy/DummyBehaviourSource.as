package sg.camogxml.dummy 
{
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	/**
	 * This doesn't do anything but simply fulfills a GXML dependency (if you aren't using behaviours).
	 * This also implements a definition getter interface from which no behaviour definitions are found
	 * @author Glenn Ko
	 */
	public class DummyBehaviourSource implements IBehaviouralBase, IDefinitionGetter
	{
		
		public function DummyBehaviourSource() 
		{
			
		}
		
		public function addBehaviour(beh:IBehaviour):void {
			
		}
		public function removeBehaviour(beh:IBehaviour):void {
			
		}
		public function getBehaviour(behName:String):IBehaviour {
			return new DummyBehaviour();
		}

		
		// -- IDefinitionGetter
		
		public function getDefinition(str:String):Object {
			return DummyBehaviour;
		}
		

		public function hasDefinition(str:String):Boolean {
			return false;
		}

		public function get definitions():Array {
			return [];
		}
		
	}
	

}
