package sg.camoextras.utils 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	
	/**
	 * Simply combines URLLoader and URLRequest into one class instance.
	 * @author Glenn Ko
	 */
	public class URLLoaderRequest implements IEventDispatcher
	{
		private var _request:URLRequest;
		private var _loader:URLLoader;
		
		public function URLLoaderRequest(url:String=null, vars:URLVariables=null) 
		{
			_request = new URLRequest(url);
			_request.data = vars;
			_request.method = URLRequestMethod.POST;
			
			_loader = new URLLoader( );
		}
		
		public function set url(str:String):void {
			
			_request.url = str; 	
		}
		public function get url():String {
			return _request.url;
		}
		
		public function set method(str:String):void {
			_request.method = str;
		}
		public function get method():String {
			return _request.method;
		}

		
		public function get data():Object {
			return _loader.data;
		}
		public function set dataFormat(str:String):void {
			_loader.dataFormat = str;
		}
		public function get dataFormat():String {
			return _loader.dataFormat;
		}
		
		public function load():void {
		
			_loader.load(_request);
		}
		
		/**
		 * Sets URLRequests's data (ie. any the variables to send)
		 */
		public function set vars(vars:Object):void {
			_request.data = vars;
		}
		public function get vars():Object {
			return _request.data;
		}

		/**
		 * Automatically sets URLRequets's data to a set of URLVariables and performs a load.
		 * @param	vars	A set of URLVariables to send and load
		 */
		public function sendAndLoad(vars:URLVariables):void {
			_request.data = vars;
			_loader.load( _request );
		}
		
		// IEventDispatcher proxy methods for Loader
		
		/// Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
		public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
			_loader.addEventListener(type, listener, useCapture,  priority, useWeakReference);
		}

		/// Dispatches an event into the event flow.
		public function dispatchEvent (event:Event) : Boolean {
			return _loader.dispatchEvent(event);
		}

		/// Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
		public function hasEventListener (type:String) : Boolean {
			return _loader.hasEventListener(type);
		}

		/// Removes a listener from the EventDispatcher object.
		public function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void {
			_loader.removeEventListener(type, listener, useCapture);
		}

		/// Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type.
		public function willTrigger (type:String) : Boolean {
			return _loader.willTrigger(type);
		}
		
	}

}