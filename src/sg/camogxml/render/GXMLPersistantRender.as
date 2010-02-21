package sg.camogxml.render 
{
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.ISelectorSource;
	

	/**
	 * A single GXML render that always remain persistant and skips default destructor implementation.
	 * 
	 * @author Glenn Ko
	 */
	[Inject(name = 'gxml', name = 'gxml', name = 'gxml', name = '', name = 'textStyle')]	
	public class GXMLPersistantRender extends GXMLRender
	{
		
		public function GXMLPersistantRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier ) 
		{
			super(definitionGetter, behaviours, stylesheet, propApplier, textPropApplier);
		}
		
			
		/**
		 * Avoid garbage collection unless explicit <code>destroyRecurse()</code> method is called.
		 */
		override public function destroy():void {
			// do nothing
		}
		
		
		
	}

}