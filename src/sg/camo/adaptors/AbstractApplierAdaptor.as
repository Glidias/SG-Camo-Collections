package sg.camo.adaptors 
{
	import camo.core.utils.PropertyMapCache;
	import flash.errors.IllegalOperationError;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * Abstract base class to handle property application.
	 * 
	 * @author Glenn Ko
	 */
	
	public class AbstractApplierAdaptor implements IPropertyApplier
	{
		protected var propMapCache:IPropertyMapCache;
		protected var typeHelper:ITypeHelper;
		
		public function AbstractApplierAdaptor(self:AbstractApplierAdaptor, propMapCache:IPropertyMapCache, typeHelper:ITypeHelper) 
		{
			if(self != this)
			{
				throw new IllegalOperationError( "AbstractApplierAdaptor cannot be instantiated directly." );
				return;
			}
			this.propMapCache = propMapCache;
			this.typeHelper = typeHelper;
		}
		
		
		public function applyProperties(target:Object, properties:Object):void {
			// to declare in extended classes
		}
		
		
		
	}

}