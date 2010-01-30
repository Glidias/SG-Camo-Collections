package sg.camogxmlgaia.assets.domain 
{
	import flash.events.Event;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camogxmlgaia.api.ISourceAsset;
	import sg.camogxmlgaia.assets.SWFLibraryAsset;
	/**
	 * A SWFLibraryAsset whose linkages are brought into a set of retrievable class definitions under the adopted
	 * IDefinitionGetter interface.
	 * 
	 * @see sg.camo.interfaces.IDefinitionGetter
	 * 
	 * @author Glenn Ko
	 */
	public class SWFDefinitionsAsset extends SWFLibraryAsset implements IDefinitionGetter, ISourceAsset
	{
		
		public function SWFDefinitionsAsset() 
		{
			super();
		}	
		
		public function get sourceType():String {
			return "definition";
		}
		public function get source():* {
			return this;
		}
		
		override public function toString():String
		{
			return "[SWFDefinitionsAsset] " + _id;
		}
		
		
	}

}