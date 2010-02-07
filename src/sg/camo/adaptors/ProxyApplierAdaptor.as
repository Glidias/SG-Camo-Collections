package sg.camo.adaptors 
{
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * A manually constructed adaptor that allows you to supply another property applier
	 * instance.
	 * @author Glenn Ko
	 */
	 
	[Inject(name='proxy', name='', name='')]
	public class ProxyApplierAdaptor extends AbstractApplierAdaptor
	{
		/**
		 * Constructor
		 * @param	propApplier		Supplies manually
		 * @param	propMapCache
		 * @param	typeHelper
		 */
		public function ProxyApplierAdaptor(propApplier:IPropertyApplier, propMapCache:IPropertyMapCache, typeHelper:ITypeHelper) 
		{
			super(self, propMapCache, typeHelper);
		}
		
		
		override public function applyProperties(target:Object, properties:Object):void {
			propApplier.applyProperties(target, properties);
		}
		
	}

}