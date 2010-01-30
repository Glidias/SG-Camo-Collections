package sg.camogxml.dummy 
{
	import sg.camo.interfaces.IDefinitionGetter;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class EmptyDefinitionGetter implements IDefinitionGetter
	{
		
		public function EmptyDefinitionGetter() 
		{
			
		}

		public function getDefinition(str:String):Object {
			return null;
		}
		

		public function hasDefinition(str:String):Boolean {
			return false;
		}
		

		public function get definitions():Array {
			return [];
		}
		
	}

}