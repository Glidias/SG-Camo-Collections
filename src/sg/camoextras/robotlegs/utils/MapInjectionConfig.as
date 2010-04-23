package sg.camoextras.robotlegs.utils 
{
	import flash.utils.getDefinitionByName;
	import org.robotlegs.core.IInjector;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * Static util class to map config injections
	 * @author Glenn Ko
	 */
	
	public class MapInjectionConfig
	{
	
	
		public static function mapInjectionList(injector:IInjector, typeHelper:ITypeHelper, xmlList:XMLList):void {
			for each( var xml:XML in xmlList) {
				if (xml.@name == undefined) throw new Error("Name key must be supplied for injection config!");
				var namer:String = xml.@name;
				var tokenType:String = xml.@type || xml["@class"] || "string";
				var classe:Class = xml.@type != undefined ?  getClassType(xml.@type) : xml["@class"] != undefined ? getDefinitionByName(xml["@class"]) as Class : String;
				injector.mapValue(classe, typeHelper.getType(xml.toString(), tokenType), namer);
			}
		}
		
		private static function getClassType(val:String):Class {
			val = val.toLowerCase();
			switch( val) {
				case "string": return String;
				case "int": return int;
				case "uint": return uint;
				case "number": return Number;
				case "boolean": return Boolean;
				case "xml": return XML;
				default: return String;
			}
			return String;
		}

		
	}

}