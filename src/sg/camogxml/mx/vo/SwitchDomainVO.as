package sg.camogxml.mx.vo 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	/**
	 * A domain value object that usually triggers property changes whenenver the domain switches.
	 * @author Glenn Ko
	 */
	[Inject(name="SwitchDomainVO.object")]
	public class SwitchDomainVO extends Proxy implements IEventDispatcher
	{
		
		protected var properties:Object;
		protected var eventDispatcher:EventDispatcher = new EventDispatcher();
	
		public function SwitchDomainVO(object:Object=null) 
		{
			properties = object || {};
		}
		
		// Domain switch getter
		
		[Bindable("domainChanged")]
		public function get $domain():Object {
			return _domainKey != null ? properties[_domainKey] : this;
		}
		
		// Domain key setter
		
		protected var _domainKey:String;
		public function set domainKey(val:String):void {
			if (val != _domainKey) {
				_domainKey = val;
				dispatchEvent(new Event("domainChanged"));
			}
		}
		[Bindable("domainChanged")]
		public function get domainKey():String {
			return _domainKey!= null ? _domainKey : "";
		}
		
		
		// -- Proxy
		
		override flash_proxy function callProperty (name:*, ...rest) : * {
			return null;
		}
		
		
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			return delete properties[name]; 
		}


		override flash_proxy function getProperty(name : *) : *
		{
			return properties[name];
		}


		override flash_proxy function setProperty(name : *, value : *) : void
		{ 
			properties[name] = value;
		}
		
		
		// -- Object
		
		public function toString():String {
			return "[SwitchDomainVO]";
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