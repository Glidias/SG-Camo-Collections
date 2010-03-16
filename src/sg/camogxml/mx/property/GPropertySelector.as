package sg.camogxml.mx.property 
{
	import camo.core.property.PropertySelector;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	/**
	 * A property selector that allows data-binding support. You need to compile this under 
	 * the Flex SDK compiler for mx.events dependencies.
	 * 
	 * @author Glenn Ko
	 */
	
	[Bindable("propertyChange")]
	public class GPropertySelector extends PropertySelector implements IEventDispatcher
	{
		
		protected var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public function GPropertySelector() 
		{
			super();
		}
		
		override protected function $setProperty(name : *, value : *) : void
		{
			var oldValue:* = properties[name];
			super.$setProperty(name, value);
			
            dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, name, oldValue, value, this));
		}
		
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