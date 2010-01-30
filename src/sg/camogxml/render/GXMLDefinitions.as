package sg.camogxml.render
{
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDomainModel;
	/**
	 * Stores a hash of class definition names which the node names will link to during GXML rendering.
	 * TODO: caching like in GXMLBehaviours
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLDefinitions implements IDefinitionGetter, IDomainModel, IDestroyable
	{
		protected var _xml:XML;
		protected var _defs:Dictionary = new Dictionary();
		protected var _domain:ApplicationDomain = ApplicationDomain.currentDomain;
		
		public function GXMLDefinitions(xml:XML=null) 
		{
			
			if (xml == null) return;
			modelXML = xml;
		}
		
		// -- IDomainModel injection
		public function set appDomain(domain:ApplicationDomain):void {
			_domain = domain;
		}
		public function set modelXML(xml:XML):void {
			_xml = xml;
			var curDomain:ApplicationDomain = _domain;  
			var nodeList:XMLList = xml.children();
			var xmlItem:XML;
			if ( xml.@classified == "true") {
				for each(xmlItem in nodeList) {
					var nodeName:String = xmlItem.name();
					switch(nodeName) {
						case "classes":
							parseClassList(xmlItem.*, curDomain);
						break;
						case "methods":
							parseMethodList(xmlItem.*, curDomain);
						break;
						default:break;
					}
				}
				
				
				return;
			}
			parseClassList(nodeList, curDomain);
		}
		
		private function parseClassList(nodeList:XMLList, curDomain:ApplicationDomain ):void {
			for each(var xmlItem:XML in nodeList) {
				var def:String = xmlItem['@class'];
				if (domainHasDefinition(curDomain, def)) {
					_defs[String(xmlItem.name())] =  curDomain.getDefinition(def);
				}
			}
		}
		private function parseMethodList(nodeList:XMLList, curDomain:ApplicationDomain):void {

			for each(var xmlItem:XML in nodeList) {
				var def:String = xmlItem['@class'];
				if (domainHasDefinition(curDomain, def)) {
					var baseClassName:String = String(xmlItem.name());
					var classeObj:Object = curDomain.getDefinition(def);
					var classDesc:XML = describeType(classeObj);
					var methodList:XMLList = classDesc.method;
					for each(var methodXML:XML in methodList) {
						trace(baseClassName + "." + methodXML.@name, classeObj[methodXML.@name.toString()] );
						 _defs[ baseClassName + "." + methodXML.@name ] = classeObj[methodXML.@name.toString()];
					}
				}
			}
		}

		protected static function domainHasDefinition(domain:ApplicationDomain, def:String):Boolean {
			var hasDef:Boolean = domain.hasDefinition(def);
			if (!hasDef) trace("GXMLDefinitions Warning! " + domain +" doesn't have definition:" + def);
			//else trace("SUCESS: " + def);
			return hasDef;
		}
		
		public function hasDefinition(str:String):Boolean {
			return _defs[str] != null  ||   _domain.hasDefinition(str);
		}
		
		public function getDefinition(str:String):Object {
			return _defs[str] ? _defs[str] :  _domain.hasDefinition(str) ?  _domain.getDefinition(str)  : null;
			//return _defs[str] as Class;    // should use this one. the above only for testing.
		}
		
		public function get definitions():Array {
			var arr:Array = [];
			for (var i:Object in _defs) {
				arr.push(i);
			}
			return arr;
		}
		
		public function destroy():void {
			_defs = null;
		}
		
	}

}