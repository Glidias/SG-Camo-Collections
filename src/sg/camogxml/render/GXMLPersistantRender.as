package sg.camogxml.render 
{
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.ISelectorSource;
	
	/**
	 * A single GXML render that always remain persistant and doesn't get garbage collected by default.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLPersistantRender extends GXMLRender
	{
		
		public function GXMLPersistantRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, inlineStyleSheetClass:Class ) 
		{
			super(definitionGetter, behaviours, stylesheet, inlineStyleSheetClass);
		}
			public static function constructorParams(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, inlineStyleSheetClass:Class ):void { };
			
		/**
		 * Avoid garbage collection unless explicit <code>destroyRecurse()</code> method is called.
		 */
		override public function destroy():void {
			// do nothing
		}
		
	}

}