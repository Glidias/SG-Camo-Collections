package sg.camogxml.mx.binding 
{
	import flash.utils.Dictionary;
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IBinder;
	import sg.camogxml.mx.hosts.*;

	
	/**
	 * Based on MX's BIndingUtls class.
	 * However, this binding utility also allows for binding to function calls and array index calls using the "()" and "[]" suffixes
	 * for properties along the property chain. 
	 * It also stores the watchers that can be later removed (unwatched) during destroy(). This makes this a useful instance
	 * to compose into your existing classes/mediators that require data binding via pure Actionscript.
	 * @author Glenn Ko
	 */
	
	[Inject(name="")]
	public class GBindingUtils
	{
		protected var _watchers:Dictionary = new Dictionary();
		
		protected var _typeHelper:ITypeHelper;
		
		/**
		 * Constructor. Allows for setting of ITypeHelper dependency (which can be set later by setter if needed).
		 * ITypeHelper is required for some classes like those that need to call functions remotely with type convertible parameters.
		 * 
		 * @see sg.camogxml.utils.FunctionInvoker
		 * 
		 * @param	functionInvoker	
		 */
		public function GBindingUtils(typeHelper:ITypeHelper=null) 
		{
			_typeHelper = typeHelper;
			if (_typeHelper == null) trace("GBindingUtils :: constructor warning. No ITypeHelper supplied.");
		}
		
		protected function getNewFunctionHost(host:Object, propertyString:String):IHostProxy {
			var retHost:HostFunctionProxy =  new HostFunctionProxy( propertyString, host, _typeHelper);
		
			return retHost;
		}
		
		protected function getNewArrayHost(host:Object, propertyString:String):IHostProxy {
			return new HostArrayProxy(propertyString, host);
		}
		
				
		/** Converts AS string to property chain, considering bracketed array properties */
		public function stringToPropertyChain(str:String):Array {
			return str.split("[").join(".[").split(".");
		}
		
		public function bindProperty (site:Object, prop:String, host:Object, chain:Object, commitOnly:Boolean = false) : ChangeWatcher {
			return setupWatcherChain(host, chain, site, prop, commitOnly);
		}
		public function bindSetter (setter:Function, host:Object, chain:Object, commitOnly:Boolean = false) : ChangeWatcher {
			return setupWatcherChain(host, chain, setter, null, commitOnly);
		}

		
		protected function setupWatcherChain(host:Object, chain:Object, siteOrSetter:*, prop:String=null, commitOnly:Boolean = false):ChangeWatcher {
			var watcher:ChangeWatcher;
			var str:String;
			var arr:Array;
			var resultHost:*;
			var suffix:String;
			str = chain is String ? chain as String : chain is Array ? chain.length < 2 ? chain[0] : null : null;
			if ( str ) {  // single string case
				suffix = str.charAt(str.length - 1);
				resultHost = suffix === ")" ?  getNewFunctionHost(host, str) : suffix === "]" ? getNewArrayHost(host, str) : host;
				watcher = setupWatcher( resultHost, chain, siteOrSetter, prop, commitOnly);
			}
			else if (chain is Array) {  // multiple array case
				var i:int;
				arr = chain as Array;
				var len:int = arr.length;
				var curHostIndex:int = 0;
				var subHostProxy:IHostProxy;
				for (i = 0; i < len; i++) {
					str = arr[i];
					suffix = str.charAt(str.length - 1);
					
					resultHost = suffix === ")" ?  getNewFunctionHost(resolveHost(host,arr,curHostIndex,i), str) : suffix === "]" ? getNewArrayHost(null, str) : host;
					if (resultHost !== host) {
						if (i != curHostIndex ) {
							subHostProxy = resultHost;
							
							watcher = setupWatcher(host, arr.slice(curHostIndex, i), subHostProxy.rebind, null, commitOnly);
						}
						host = resultHost;
						curHostIndex = i;
					}
				}
				watcher = setupWatcher(host, arr.slice(curHostIndex, i), siteOrSetter, prop, commitOnly);
			}
			else watcher = setupWatcher(host, chain, siteOrSetter, prop, commitOnly);
			
			return watcher;
		}
		
		public function getNewSiteProperty(oldSite:*, propertyDottedString:String):Array {
			var chain:Array = stringToPropertyChain(propertyDottedString);
			if (chain.length < 2) return [oldSite, propertyDottedString]
			var newHost:* =  resolveHost(oldSite, chain.slice(0, chain.length - 1), 0, chain.length );
			return [newHost, chain[chain.length - 1]];
		}
		
		
		protected function resolveHost(curHost:*, curArray:Array, curHostIndex:int, curIndex:int):* {
			var i:int = curHostIndex;
			while (i < curIndex && curHost) {
				curHost = curHost[curArray[i]];
				i++;
			}
			return curHost;
		}
		
		protected function setupWatcher(host:Object, chain:Object, siteOrSetter:*, prop:String=null, commitOnly:Boolean = false):ChangeWatcher {
			var watcher:ChangeWatcher =  prop != null ? BindingUtils.bindProperty(siteOrSetter, prop, host, chain, commitOnly) : BindingUtils.bindSetter(siteOrSetter, host, chain, commitOnly);
			_watchers[watcher] = true;
			return watcher;
		}
		
		public function unbindAll():void {
			for (var i:* in _watchers) {
				i.unwatch();
			}
		}


		
	}

}