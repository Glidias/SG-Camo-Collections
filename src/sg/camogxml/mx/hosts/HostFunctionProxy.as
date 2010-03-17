package sg.camogxml.mx.hosts 
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import mx.utils.DescribeTypeCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IFunctionInvoker;
	
	/**
	 * This proxy class allows for hosting a bindable function call as a property. 
	 * @author Glenn Ko
	 */
	
	[Bindable("updateFunction")]
	[Inject(name="HostProxy.propertyString",name="HostProxy.host",name="HostFunctionProxy.typeHelper",name="HostFunctionProxy.customEvent")]
	public class HostFunctionProxy extends HostProxy
	{
		protected var _eventToListenFor:String;
		protected var _customEvent:String;
		
		protected var methodName:String;
		protected var methodParams:Array;
		
		protected var _typeHelper:ITypeHelper;
		
		protected var oldValue:Object;
		
		protected var _noCache:Boolean = false;
		// cached method  parameter type information if noCache is enabled
		protected var _methodTypes:Array;		

		/**
		 * @param	propertyString	The coded string of the function being invoked with
		 * 							optional comma-delimited parameters. (eg. <code>methodName()</code> 
		 * 							or <code>methodName(param1,param2)</code> . Comma delimited parameter calls
		 * 							may require a ITypeHelper dependency to be supplied to handle parameter
		 * 							type conversions for non-string values. 
		 * 							For non-cachable parameters that require type conversion with a ITypeHelper
		 * 							upon every function call, a character prefix of '~' can be added to the 
		 * 							propertyString to indicate so.
		 * @param	host			The host reference that contains the function. The host must be
		 * 							an IEventDispatcher in order for this class to work, since the proxy needs
		 * 							to listen for the bindable-function event to trigger the function call. 
		 * 							This value can initially be set to null if rebinding occurs later.
		 * @param	typeHelper		This property must be set to allow for invoking functions remotely with type-convertible parameters.
		 * @param   customEvent		A custom event type to listen for on the host, in order to trigger 
		 * 							the function call. This would ignore any Bindable meta-data
		 * 							present in the host. Usually this isn't used as most classes will have
		 * 							their own Bindable meta-tags for the function.
		 */					
		public function HostFunctionProxy(propertyString:String, host:Object=null,  typeHelper:ITypeHelper=null, customEvent:String=null) 
		{
			super(host, propertyString);
			
			if (propertyString == null) return;
			
			_noCache = propertyString.charAt(0) === "~";
				
			propertyString = _noCache ? _propertyString.substr(1) : _propertyString;
			
			var openBracket:int =  propertyString.indexOf("(");
			methodName =  propertyString.substr(0, openBracket);
			var checkParamsString:String = propertyString.substring(openBracket +1, propertyString.indexOf(")"));
			methodParams = checkParamsString.length > 0 ? checkParamsString.split(",") : null;
			
			_typeHelper = typeHelper;
			_customEvent = customEvent;
			
			if (!host) return;
			var listener:IEventDispatcher = host as IEventDispatcher;
			
			if (listener) {
				initListenInvokeOf(listener);
				listener.addEventListener(_eventToListenFor, invokeFunctionHandler, false , 0, true);
			}
			
			
		}


		protected function initListenInvokeOf(listener:IEventDispatcher):void {
			
			var methodXML:XML = DescribeTypeCache.describeType(listener).typeDescription..method.(@name == methodName)[0];
			
			if (methodXML == null) throw new Error("No method found for target:" + listener + " , methodName:" + methodName);
			var paramList:XMLList;
			var i:int;
			var len:int;
			if ( _typeHelper && !_noCache) {  // do cached type conversion
			
				paramList = methodXML.parameter;
				i = 0;
				len = methodParams.length;
				while ( i < len) {
					methodParams[i] = _typeHelper.getType( methodParams[i], paramList[i].@type.toString().toLowerCase() );
					i++;
				}
			}
			else if (_noCache) {	
				paramList = methodXML.parameter;
				i = paramList.length();
				_methodTypes = i > 0 ? new Array(i) : null;
				while ( --i > -1) {
					_methodTypes[i] = paramList[i].@type.toString().toLowerCase();
				}
			}
				
			// There should be checks for XML search case.. or special cases...
			_eventToListenFor = _customEvent  ||  methodXML.metadata.(@name == "Bindable")[0].arg[0].@value;
		}
		
		protected function invokeFunctionHandler(e:Event):void {
			dispatchEvent(new Event("updateFunction"));
		}
		
		
		override protected function $getProperty(name:*):* {
			if (_host == null || name != _propertyString) {
			//	throw new Error('aaaaaaawrwa'+_propertyString + "," +_host);
				return null;
			}
			
			oldValue =  methodParams ? _noCache ? reinvoke(methodParams) : _host[methodName].apply(null, methodParams) : _host[methodName]();
			
			return oldValue;
		}
		
		/**
		 * Reinvokes function with new parameter type-conversions as per non-cachable case.
		 * @param	methodParams
		 * @return
		 */
		protected function reinvoke(methodParams:Array):* {
			var params:Array = methodParams.concat();
			for (var i:String in params) {
			
				params[i] = _typeHelper.getType(params[i], _methodTypes[i]);
			}
			return _host[methodName].apply(null, params);
		}
		
	
		override public function rebind(newHost:Object):void {
			
			if ( (_host is IEventDispatcher) && _eventToListenFor) {
				(_host as IEventDispatcher).removeEventListener(_eventToListenFor, invokeFunctionHandler);
			}
			
			super.rebind(newHost );
			var listener:IEventDispatcher = _host as IEventDispatcher;
			if (listener && _eventToListenFor) listener.addEventListener(_eventToListenFor, invokeFunctionHandler, false , 0, true)
			else if (listener) {
				initListenInvokeOf(listener);
			}

			
			dispatchEvent(new Event("updateFunction"));
		}
		

		
		override public function toString():String {
			return "[HostFunctionProxy]"
		}
		

		
		
		
	}

}