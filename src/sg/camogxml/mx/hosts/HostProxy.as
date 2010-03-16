package sg.camogxml.mx.hosts 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	/**
	 * Base class for Host proxies, which act as sub-hosts for special bindable properties,
	 * such as function calls or array access) which are bindable at runtime.
	 * 
	 * @author Glenn Ko
	 */
	
	public class HostProxy extends Proxy implements IEventDispatcher, IHostProxy
	{
		
		protected var _host:Object;
		protected var _propertyString:String;
		protected var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		/**
		 * 
		 * @param	host	
		 * @param	propertyString	This value is usually be set to something to describe 
		 * 							the property being retrieved remotely.
		 */
		public function HostProxy(host:Object, propertyString:String) 
		{
			_host = host;
			_propertyString = propertyString;
		}
		
		
		public function rebind(newHost:Object):void {
			_host = newHost;
		}
		
		// -- Proxy
		
		override flash_proxy function callProperty (name:*, ...rest) : * {
		
		}
		
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			return $deleteProperty(name);
		}
		protected function $deleteProperty(name:*):Boolean {
			return false;
		}


		override flash_proxy function getProperty(name : *) : *
		{
			return $getProperty(name);
		}
		protected function $getProperty(name:*):* {
			return null;
		}



		override flash_proxy function setProperty(name : *, value : *) : void
		{ 
			$setProperty(name, value);
		}
		protected function $setProperty(name:*, value:*):void {
			
		}
		
		// -- Object
		
		public function toString():String {
			return  "[HostProxy]"
		}
		
		// -- IEventDispatcher
		 public function hasEventListener(type:String):Boolean
        {
            return eventDispatcher.hasEventListener(type);
        }
       
        public function willTrigger(type:String):Boolean
        {
            return eventDispatcher.willTrigger(type);
        }
       
        public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
        {
            eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
       
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
        {
            eventDispatcher.removeEventListener(type, listener, useCapture);
        }
       
        public function dispatchEvent(event:Event):Boolean
        {
            return eventDispatcher.dispatchEvent(event);
        }
	}

}