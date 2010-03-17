package sg.camogxml.mx.hosts 
{
	import flash.events.Event;
	
	/**
	 * This proxy class allows for hosting an array with a single indexed "[i]" access as a property. 
	 * @author Glenn Ko
	 */
	[Bindable("updateArray")]
	[Inject(name="HostProxy.propertyString",name="HostProxy.host")]
	public class HostArrayProxy extends HostProxy
	{
		protected var _cachedLookupIndex:int;
		protected var _hostArray:Array;
		
		public function HostArrayProxy(propertyString:String=null, host:Object=null) 
		{
			super(host, propertyString);
			_hostArray = host as Array;
			
			if (propertyString) _cachedLookupIndex = int( propertyString.substr(1,propertyString.length-2) );
		}
		
		override public function rebind(newHost:Object):void {
			super.rebind(newHost);
			_hostArray = newHost as Array;
			dispatchEvent(new Event("updateArray"));
		}
		

		
		override protected function $getProperty(name:*):* {
			if (_hostArray == null) return null;

			var lookupIndex:int = _propertyString != name ? int(_propertyString.substr(1,_propertyString.length-2)) : _cachedLookupIndex;
			return lookupIndex < _hostArray.length ? _hostArray[lookupIndex] : null;
		}
		
		// -- Object
		
		override public function toString():String {
			return "[HostArrayProxy]";
		}
		
	}

}