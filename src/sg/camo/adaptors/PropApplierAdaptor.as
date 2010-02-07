package sg.camo.adaptors 
{
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import flash.utils.Proxy;
	
	/**
	 * Property application system conventions for SG-Camo over any object.
	 * @author Glenn Ko
	 */
	
	[Inject(name='', name='')]
	public class PropApplierAdaptor extends AbstractApplierAdaptor
	{
		
		public function PropApplierAdaptor(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper) 
		{
			if (propMapCache == null) return;
			super(this, propMapCache, typeHelper);
		}
		
		override public function applyProperties(target:Object, properties:Object):void {
			var propMap : Object = propMapCache.getPropertyMap(target);
			var isProxy:Boolean = target is Proxy;
			
			for(var prop:String in properties) {

				var type : String = isProxy ? propMap[prop] || "string" : propMap[prop];
				if(type) { 
					var cleanedUpValue : * = typeHelper.getType(properties[prop], type);
					target[prop] = cleanedUpValue;
				}
			}
		}
		
	}

}