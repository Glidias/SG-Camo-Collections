package sg.camogxml.property 
{
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IBinder;
	import sg.camogxml.api.IPropertyBinder;
	import flash.utils.Proxy;
	
	/**
	 * A property applier with the ability to set a binder to link to the application-side
	 * end for binding properties. Processes braced items "{" "}".
	 * @author Glenn Ko
	 */
	
	[Inject(name="",name="",name="gxml")]
	public class PropertyBinder implements IPropertyBinder
	{
		protected var propMapCache:IPropertyMapCache;
		protected var typeHelper:ITypeHelper;
		protected var _binder:IBinder;
		
		public function PropertyBinder(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper, someBinder:IBinder=null) 
		{
			this.propMapCache = propMapCache;
			this.typeHelper = typeHelper;
			_binder = someBinder;
		}
		
		public function applyProperties(target:Object, properties:Object):void {
			var propMap : Object = propMapCache.getPropertyMap(target);
			var isProxy:Boolean = target is Proxy;
			
			for(var prop:String in properties) {
				var stringVal:String = properties[prop];
				if (stringVal.charAt(0) === "{") {
					_binder.addBinding(target, prop, stringVal.substr(1, stringVal.length -2));
					continue;
				}
				var type : String = isProxy ? propMap[prop] || "string" : propMap[prop];
				if(type) { 
					var cleanedUpValue : * = typeHelper.getType(properties[prop], type);
					target[prop] = cleanedUpValue;
				}
			}
		}
		
		public function set binder(val:IBinder):void {
			_binder = val;
		}
		
	}

}