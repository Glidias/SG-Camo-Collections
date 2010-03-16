package sg.camo.greensock 
{
	import com.greensock.plugins.TweenPlugin;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;

	/**
	 * A storehouse of plugin variables to allow seamless data conversion of TweenLite/TweenMax
	 * plugin properties from strings. 
	 * <br/><br/>
	 * NOTE: If this class is automatically executed through the singleton cache, 
	 * it requires setting of global interface values under GSGlobals prior beforehand.
	 * 
	 * @see sg.camo.greensock.GSGlobals
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject(name='GSPluginVars.IDefinitionGetter', name='GSPluginVars.ApplicationDomain', name='', name='')]
	public class GSPluginVars implements IDefinitionGetter
	{
		/**
		 * You can set this to an empty string if you're using custom plugins from other packages.
		 */
		public static var CLASS_PREFIX:String = "com.greensock.plugins.";
		
		private static const CACHE_NAME:String = "sg.camo.greensock::GSPluginVars";
		private var defGetter:IDefinitionGetter;
		
		// public type declarations for plugins
		public var autoAlpha:Number;
		public var bezier:Function = getNumberedObjectArray; 
		public var bezierThrough:Function = getNumberedObjectArray;  
		
		public var endArray:Function = getNumericArray;
		public var frameLabel:String;
		public var frame:Number;
		public var hexColors:Function = getUintObject; 
		
		//public var quaternions:Function;  // not applicable. Need pv3d
		public var removeTint:Boolean;
		public var roundProps:Array;
		public var scale:Number;
		public var tint:uint;
		public var visible:Boolean;
		public var volume:Number;
		
		public var scrollRect:Function = getNumericObject;   
		public var setActualSize:Function = getNumericObject;  
		public var setSize:Function = getNumericObject;  
		public var shortRotation:Function = getNumericObject; 
		public var soundTransform:Function = getNumericObject;
		public var transformMatrix:Function = getNumericObject;
		
		private static var customClasses:Dictionary = new Dictionary();
		private static var SINGLETON_CACHE:GSPluginVars;
		
		protected var _appDomain:ApplicationDomain;
		
		protected var _typeHelper:ITypeHelper;
		protected var _propMapCache:IPropertyMapCache;
		
		
		
		
		
		
	//	public var colorTransform:Function = ;

		
		/**
		 * Custom constructor to dynamically instantiate a unique GSPluginVars with the following dependency options.
		 * @param	defGetter	Supply a IDefinitionGetter interface from which to retrieve class definitions
		 * 						for plugins.
		 * @param	appDomain	If first parameter not supplied, uses an ApplicationDomain to retrieve
		 * 						class definitions for plugins, which by default is set to current.
		 * @param   typeHelper		A  typehelper implementation to use (if not set through GSGlobals)
		 * @param   propMapCache	A  property map cache implementation to use  (if not set through GSGlobals)
		 * @see sg.camo.greensock.GSGlobals
		 */
		public function GSPluginVars(defGetter:IDefinitionGetter=null, appDomain:ApplicationDomain=null, typeHelper:ITypeHelper=null, propMapCache:IPropertyMapCache=null) 
		{
			_appDomain = appDomain || ApplicationDomain.currentDomain;
			this.defGetter = defGetter || this;
			_typeHelper = typeHelper || GSGlobals.typeHelper || throwError("ITypeHelper")
			_propMapCache = propMapCache  || GSGlobals.propertyMapCache ||  throwError("IPropertyMapCache");
		}
		
		protected function throwError(impl:String):* {
			throw new Error("GSPluginVars instantiation critical warning. " + impl + " not set! Set this through GSGlobals beforehand to avoid this!"  );
			return null;
		}
		
		
		public function getDefinition(str:String):Object {
			return _appDomain.getDefinition(str);
		}

		public function hasDefinition(str:String):Boolean {
			return _appDomain.hasDefinition(str);
		}
		

		public function get definitions():Array {
			return []; // not implemented. No definition list pubilcily available
		}
		
		/**
		 * Retrieves instance from singleton cache for single static GSPluginVars reference. <br/>
		 * Warning:  This is limited to only retrieving class definitions from default current application domain
		 * only and accessing dependencies through GSGlobals. Ensure all GSGlobals' settings are set prior 
		 * to having this called.
		 * @see sg.camo.greensock.GSGlobals
		 * @return	A static singleton instance
		 */
		public static function getInstance():GSPluginVars {
			return SINGLETON_CACHE || new GSPluginVars();
		}
		
		/**
		 * Convert a string to the appropiate plugin property value
		 * @param	prop	The property identifier of the plugin (eg. autoAlpha, volume, frame, etc.)
		 * @param	data	The string data to convert to the serialized data type
		 * @return	The converted serialized value
		 */
		public function getPropertyValue(prop:String, data:String):* {
			var customClass:Class = customClasses[prop];
			if (customClass) return getCustomClassValue(customClass, data, prop);

			var propMap:Object = _propMapCache.getPropertyMapCache(CACHE_NAME) || _propMapCache.getPropertyMap(GSPluginVars);
			var type:String = propMap[prop];	
			return type != null ?  type != "function"  ? _typeHelper.getType( data, type ) :   this[prop](data) : getNumericObject(data);   // assumed default last NumericObject 
		}
		
		private function getCustomClassValue(customClass:Class, data:String, prop:String):* {
			var propMap:Object = _propMapCache.getPropertyMap(customClass);
			var retObj:Object = stringToObject(data, "~", "@");
			for (var i:String in retObj) {
				var type:String = propMap[i];
				if (type != null) retObj[i] = _typeHelper.getType( retObj[i], type )
				else trace("Warning. No type conversion found for property:" + i + " for "+prop);
			}
			return retObj;
		}
		
		/**
		 * Registers a custom class (containing public variable type information) for the type of plugin being used
		 * based on the property of the tween's object to allow type conversion serialisation.
		 * 
		 * @example registerClassVariablesWithProperty(DropShadowFilterVars, "dropShadowFilter");
		 * 
		 * @param	classe		The class of variables to reference from
		 * @param	prop		The property name
		 */
		public static function registerClassVariablesWithProperty(classe:Class, prop:String):void {
			customClasses[prop] = classe;
		}
		
		
		/**
		 * Parses a space array string of plugins in batch from the current definition getter.
		 * This method gracefully fails if no class is found from the definition getter.
		 * @example parsePluginString("AutoAlphaPlugin TintPlugin");
		 * 
		 * @param	str	The space array of strings containing class definitions of plugins under the com.greensock.plugins package.
		 * 				If you have our own unique packages, you must set CLASS_PREFIX static variable to an empty string "" and list out
		 * 				all class paths fully.
		 */
		public function parsePluginString(str:String):void {
			var arr:Array = str.split(" ");
			for (var i:String in arr) {
				var valStr:String = arr[i];
				var classPrefix:String = valStr.search(".") > -1 ? "" : CLASS_PREFIX;
				var classDef:String = classPrefix + valStr;
				arr[i] = defGetter.hasDefinition(classDef) ? defGetter.getDefinition(classDef) as Class || GSPluginVars : GSPluginVars;  
			}
			trace("GSPluginVars activating: "+arr+" from "+defGetter);
			TweenPlugin.activate(arr);
		}
		
		
		// ---------

		
		public static function getNumericObject(str:String):Object {
			trace(str);
			var val:Object = stringToObject(str, "~", "@");
		
			for (var i:String in val) {
				if ( i.charAt(0) != "*" ) {
					val[i] = Number(val[i]);
					trace(i, val[i]);
				}
				else {  // also consider relative values
					val[i.substr(1)] = val[i];
					delete val[i];
				}
			}
			
			return val;
		}
		
		public static function getNumericArray(str:String):Array {
			var val:Array =  str.split(" ");
			for (var i:String in val) {
				val[i] = Number(val[i]);
			}
			return val;
		}
		
		public static function getNumberedObjectArray(str:String):Array {
			var val:Array = str.split(" ");
			for (var i:String in val) {
				val[i] = getNumericObject(str);
			}
			return val;
		}
		
		public static function  getUintObject(str:String):Object {
			var val:Object = stringToObject(str, "~", "@");
			for (var i:String in val) {
				val[i] = stringToUint(val[i]);
			}
			return val;
		}
		
		// Saved out local copy of core TypeHelperUtil implementations to be used internally
		// by Greensock.
		
		/**
		 * <p>Converts a string into a uint.
		 * NOTE: Doesn't support color labels,
		 * must use hex values! </p>
		 */
		public static function stringToUint(value : String) : uint
		{
			
			value = value.substr( - 6, 6 );
			var color : uint = Number( "0x" + value );
			return color;
		}
		
		protected static function stringToObject(data : String, dataDelimiter : String = "," ,propDelimiter : String = ":") : * 
		{
			var dataContainer : Object = {};

			var list : Array = data.split( dataDelimiter );
			trace(list);
			var total : Number = list.length;

			for (var i : Number = 0; i < total ; i ++) 
			{
				var prop : Array = list[i].split( propDelimiter );
				
				dataContainer[prop[0]] = prop[1];
			}
			
			return dataContainer;
		}
		
	}




}