package sg.camogxml.mx.collections
{
	import mx.collections.XMLListCollection;
	import sg.camo.interfaces.ITypeHelper;
	
	/**
	 * 
	 * @author Glenn Ko
	 */
	[Inject(name="XMLListCollection", name="")]
	public class CamoXMLListCollection extends XMLListCollection 
	{
		protected var _typeHelper:ITypeHelper;
			
			
		public function CamoXMLListCollection (source:XMLList = null, typeHelper:ITypeHelper=null) {
			super(source);
			_typeHelper = typeHelper;
		}
		
		[Inject]
		public function setTypeHelper(val:ITypeHelper):void {
			 _typeHelper = val;
		}
		
		public function findItemAt(index:int, prefetch:int = 0):Object {
			return super.getItemAt(index, prefetch);
		}
		
		 public function parseItemAt (index:int, prefetch:int = 0) : Object {
			var retObj:Object = convertXMLToObject(super.getItemAt(index, prefetch) as XML, _typeHelper);
			if (retObj == null) return "";
			return retObj;
		}
		
		public static function convertXMLToObject(xml:XML, typeHelper:ITypeHelper=null):Object {
			var obj:Object = null;
			var childList:XMLList = xml.children();
			var len:int = childList.length();
			if (len > 0) {
				obj = { };
				for (var i:int = 0; i < len ; i++) {	
					var xml:XML = childList[i];
					obj[xml.name().toString()] = typeHelper && xml["@type"] != undefined ? typeHelper.getType(xml, xml["@type"]) : xml;
				}
			}	
			else if (typeHelper && xml["@type"] != undefined) {
				obj = typeHelper.getType(String(xml), xml["@type"].toString().toLowerCase());
			}
			
			return obj;
		}
		
	}
}
	
	
