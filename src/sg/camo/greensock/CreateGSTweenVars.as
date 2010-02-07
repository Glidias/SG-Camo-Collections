package sg.camo.greensock 
{
	import com.greensock.TweenLite;
	

	
	/**
	 * Static methods to define convention for processing an object of strings to a parsable set of 
	 * tween variables.
	 * 
	 * @author Glenn Ko
	 */
	public class CreateGSTweenVars
	{
		public static function createVarsFromObject(obj:Object, customPluginVars:GSPluginVars=null):Object {
			var retObj:Object = { };
			var pluginVars:GSPluginVars = customPluginVars || GSPluginVars.getInstance();
			for (var i:String in obj) {
				if (TweenLite.plugins[i]) {
					retObj[i] = obj[i] is String ? pluginVars.getPropertyValue(i, obj[i]) : obj[i];
					continue;
				}
				var wildCard:Boolean = i.charAt(0) === "*";
				var prop:String = wildCard ? i.substr(1) : i;
				retObj[prop] = prop!= "ease" ? wildCard ? obj[i] : Number(obj[i]) : EasingMethods.getEasingMethod(obj[i]);  
				
			}
			return retObj;
		}
		
		
		
	}

}