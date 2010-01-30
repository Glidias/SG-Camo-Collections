package sg.camogxml.managers.gs.data 
{
	import camo.core.utils.ArrayObjectTypeHelper;
	import camo.core.utils.PropertyMapCache;
	import camo.core.utils.TypeHelperUtil;
	import com.greensock.plugins.TweenPlugin;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camogxml.dummy.ApplicationDomainGetter;

	/**
	 * A storehouse of plugin variables to allow seamless data conversion of TweenLite/TweenMax
	 * plugin properties from strings.
	 * 
	 * @author Glenn Ko
	 */
	public class GSPluginVars
	{
		
		/**
		 * You can set this to an empty string if you're using custom plugins from other packages.
		 */
		public static var CLASS_PREFIX:String = "com.greensock.plugins.";
		
		private static const CACHE_NAME:String = "sg.camogxml.managers.gs.data::GSPluginVars";
		private var defGetter:IDefinitionGetter;
		
		// public type declarations for plugins
		public var autoAlpha:Number;
		public var bezier:Function = ArrayObjectTypeHelper.getNumberedObjectArray; 
		public var bezierThrough:Function = ArrayObjectTypeHelper.getNumberedObjectArray;  
		
		public var endArray:Function = ArrayObjectTypeHelper.getNumericArray;
		public var frameLabel:String;
		public var frame:Number;
		public var hexColors:Function = ArrayObjectTypeHelper.getUintObject; 
		
		//public var quaternions:Function;  // not applicable. Need pv3d
		public var removeTint:Boolean;
		public var roundProps:Array;
		public var scale:Number;
		public var tint:uint;
		public var visible:Boolean;
		public var volume:Number;
		
		public var scrollRect:Function = ArrayObjectTypeHelper.getNumericObject;   
		public var setActualSize:Function = ArrayObjectTypeHelper.getNumericObject;  
		public var setSize:Function = ArrayObjectTypeHelper.getNumericObject;  
		public var shortRotation:Function = ArrayObjectTypeHelper.getNumericObject; 
		public var soundTransform:Function = ArrayObjectTypeHelper.getNumericObject;
		public var transformMatrix:Function = ArrayObjectTypeHelper.getNumericObject;
		
		private static var customClasses:Dictionary = new Dictionary();
		private static var SINGLETON_CACHE:GSPluginVars;

		
		/**
		 * Constructor to dynamically instantiate a unique GSPluginVars with the following dependency options.
		 * @param	defGetter	Supply a IDefinitionGetter interface from which to retrieve class definitions
		 * 						for plugins.
		 * @param	appDomain	If first parameter not supplied, uses an ApplicationDomain to retrieve
		 * 						class definitions for plugins, which by default is set to current.
		 */
		public function GSPluginVars(defGetter:IDefinitionGetter=null, appDomain:ApplicationDomain=null) 
		{
			this.defGetter = defGetter || new ApplicationDomainGetter( (appDomain || ApplicationDomain.currentDomain) );
		}
		
		/**
		 * Retrieves instance from singleton cache for single static GSPluginVars reference
		 * to simply retrieve plugin class definitions from default current application domain.
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
			var propMap:Object = PropertyMapCache.getPropertyMapCache(CACHE_NAME, GSPluginVars);
			var type:String = propMap[prop];	
			return type != null ?  type != "function"  ? TypeHelperUtil.getType( data, type ) :   GSPluginVars[prop](data) : getCustomClassValue(data, prop);
		}
		
		private static function getCustomClassValue(data:String, prop:String):* {
			var customClass:Class = customClasses[prop];
			if (customClass == null) return null; 
			var propMap:Object = PropertyMapCache.getPropertyMap(customClass);
			var retObj:Object = TypeHelperUtil.stringToObject(data, "~", "@");
			for (var i:String in retObj) {
				var type:String = propMap[i];
				if (type != null) retObj[i] = TypeHelperUtil.getType( retObj[i], type )
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
				var classDef:String = CLASS_PREFIX + arr[i];
				arr[i] = defGetter.hasDefinition(classDef) ? defGetter.getDefinition(classDef) as Class || GSPluginVars : GSPluginVars;  
			}
			trace("GSPluginVars activating: "+arr+" from "+defGetter);
			TweenPlugin.activate(arr);
		}
		
	}

}