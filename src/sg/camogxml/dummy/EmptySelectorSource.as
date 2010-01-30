package sg.camogxml.dummy 
{
	import camo.core.property.IPropertySelector;
	import sg.camo.interfaces.ISelectorSource;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class EmptySelectorSource implements ISelectorSource
	{
		
		public function EmptySelectorSource() 
		{
			
		}
		
		public function getSelector( ... selectorNames) : Object {
			return { };
		}
		

		public function findSelector(selectorName:String):IPropertySelector {
			return null;
		}
		
		public function get selectorNames() : Array {
			return [];
		}
		
	}

}