package sg.camogxmlgaia.utils 
{
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.utils.GXMLGlobals;
	
	
	/**
	 * Static utility to resolve dependencies based off a particular instance through introspection
	 * and an XML scheme that denotes how searches are done within a targetted class instance to
	 * retrieve that dependency. (aka. DependencyFinder).
	 * 
	 * @author Glenn Ko
	 */
	public class DependencyResolverUtil
	{
		private static var implHash:Dictionary = new Dictionary();
		private static var subjectMap:Dictionary = new Dictionary();
		private static var cachedPropertyMaps:Dictionary = new Dictionary();
		private static var lastScanned:XML;
		public static var bindingMethod:Function = dummyBinding;
		
		
		private static function dummyBinding(val:*):* {
			return val;
		}
		
		/**
		 * Resolves a dependency based of an already-given live instance and an optional subject reference linking to an XML map. 
		 * @param	instanceTarget	A live instance from which an attempt is made to resolve to a particular implementation. (No static classes allowed).
		 * @param	findClassName	The class/interface name to search for the given instance for resolving to
		 * @param	subject			The subject mapping ( a stored subject key) from which to retrieve a xml search map. 
		 * 							If the parameter value is already an XML, uses the XML itself as a search map.
		 * @return  The resolved value if valid, or null if not found
		 */
		public static function resolveDependency(instanceTarget:*, findClassName:String, subject:* = null):* {
			if (instanceTarget == null || instanceTarget is Class) return null;
			
			var className:String = getQualifiedClassName(instanceTarget);
			var hashOfImpls:Dictionary = implHash[className] || getNewImplHash(className, instanceTarget); 
	
			 
			var xmlMap:XML = subject is XML ? subject :  getDictionaryMapping(subject, findClassName);
			if (xmlMap == null) { // attempt resolve immediately
				return hashOfImpls ? hashOfImpls[findClassName] ? instanceTarget : null  : null;
			}
			
			// Else continue search through XML checklist
			var retVal:* = attemptResolveRecurse(xmlMap, instanceTarget, findClassName, hashOfImpls);
			if (retVal == null) throw new Error('Dependency resolveDependency failed:'+xmlMap.toXMLString() + " ::: "+ instanceTarget)
			return retVal;
		}
		
		private static function attemptResolveRecurse(node:XML, instanceTarget:*, findClassName:String, hashOfImpls:Dictionary):* {
			var checkList:XMLList = node.check;
			if (checkList.length() < 1) return null;
			var len:int = checkList.length();
			
			for (var i:int = 0; i < len; i++) {
				node = checkList[i];
				var retVal:* = attemptResolveNode(node, instanceTarget, findClassName, hashOfImpls);
				if (retVal != null) return retVal;
			}
			return null;
		}
		
		private static function attemptResolveNode(xml:XML, instanceTarget:*, findClassName:String, hashOfImpls:Dictionary):* {
			var propMap:Object;
			var node:XML;
			var retVal:*;
			var len:int;
	
			var className:String = xml["@class"];
			
			if (hashOfImpls == null) return null;
			
			
			if ( hashOfImpls[ className ]) {
			//	trace("considering class:"+ className);
				
				var inspectClass:Object = getDefinitionByName( className );
				var dummySubImpl:Dictionary = implHash[ className ] || getNewImplHash( className );
				
				// attempt recurse if available
				retVal = attemptResolveRecurse(xml, instanceTarget, findClassName, dummySubImpl);
				if (retVal) return retVal;
				
				// Else If final, iterate through properties of current instance 1 last time to retrieve a property map type match of at least
				// 1 of the items in property map.
				propMap = propertyMap( inspectClass, className );
				
				for (var prop:String in propMap) {
					if (propMap[prop] === findClassName) {
					//	trace("Returning instance prop of:"+instanceTarget, prop);
						return instanceTarget[ prop ];
					}
				}
			}
			else if ( xml["@property"] != undefined ) {	
				//trace("considering property:"+ xml["@property"]);
				
				// if not final (consider nested property first or after???);
				
				
				// else get property of current instance only if match with property map type is found.
				propMap = propertyMap(instanceTarget);

				if ( propMap[ xml["@property"] ] === findClassName  ) {
					
					return instanceTarget[ xml["@property"] ]; // note: no type-checking
				}
				
			
				else if ( propMap[ xml["@property"] ] != undefined ) {
					inspectClass = instanceTarget[ xml["@property"].toString() ];
					className = getQualifiedClassName(inspectClass);
				
					dummySubImpl = implHash[ className ] || getNewImplHash( className, inspectClass );
				
					if (dummySubImpl[findClassName]) return inspectClass;
					retVal =   attemptResolveRecurse(xml, inspectClass, findClassName, dummySubImpl   );
					if (retVal) return retVal; 
				}
				
			}
			else if ( xml["@method"] != undefined) {
																			// should validate availablity of instance method in 2nd case
				var findFunc:Function = bindingMethod( xml["@method"].toString() ) as Function || instanceTarget[xml["@method"].toString()] as Function;
				if (findFunc == null) {
					trace("Halting method! Function not found for:" + xml["@method"].toString());
					return null;
				}
				var arr:Array = [];
				var paramList:XMLList = xml.param;
				var pushedVal:*;
				
				len = paramList.length();
				var typeHelper:ITypeHelper = GXMLGlobals.typeHelper;
				for ( var i:int = 0; i < len; i++) {
					node = paramList[i];
					
					if (node.@property == undefined) {
						pushedVal = node.@type != undefined ? typeHelper.getType( String(bindingMethod(node.toString()) ), node.@type.toString().toLowerCase() ) : bindingMethod( node.toString()  );
						arr.push( pushedVal )
					}
					else if ( instanceTarget.hasOwnProperty(node.@property.toString()) ) {
						arr.push(instanceTarget[node.@property.toString() ])
					}
					else {
						trace("Halting method! No valid property found for for function", instanceTarget, prop);
						return null;
					}
				}
				retVal = findFunc.apply(null, arr); 
				return retVal; // note: no type-checking
			}
			
			return null;
		}
		

		
		private static function getDictionaryMapping(subject:*, findClassName:String):XML {
			var chkDict:Dictionary = subjectMap[subject];
			return 	chkDict ?  chkDict[findClassName] : null;
		}
		
		private static function getDefinition(name:String):* {
			return ApplicationDomain.currentDomain.hasDefinition(name) ? getDefinitionByName(name) : null;
		}
		private static function getNewImplHash(findClassName:String, instanceTarget:*= null ):Dictionary {
			
			instanceTarget = instanceTarget || getDefinition( findClassName.replace("::", ".") );
		
			if (instanceTarget == null) return  null;
			
			var dict:Dictionary = new Dictionary();
			
					
					
			var classDesc:XML = getNewPropertyMap(instanceTarget, findClassName);

			if (classDesc.factory.length() > 0 ) classDesc =  classDesc.factory[0];
			
			var list:XMLList;
			var len:int;
			var xml:XML;
			
			list = classDesc.extendsClass;
			for each (xml in list) {
				dict[String(xml.@type)] = true;
			}
			list = classDesc.implementsInterface;
			for each (xml in list) {
				dict[String(xml.@type)] = true;
			}
			implHash[findClassName] = dict;
			return dict;
		}
		
		private static function getNewPropertyMap(target:Object, className:String):XML { 
			propertyMap(target, className);
			return lastScanned;
		}
		
		private static function createNewFindingsDictionary(subject:*):Dictionary {
			var dict:Dictionary = new Dictionary();
			subjectMap[subject] = dict;
			return dict;
		}
		
		/**
		 * Adds a xml structure for a particular subject context to perform a specific search
		 * @param	xml			The base xml node from which a subject may be found with nested "find" mappings.
		 * @param   subject		If supplied, uses this value for the subject and ignores any "subject" attribute defined in the xml.
		 */
		public static function addFindingsMap(xml:XML, subject:*= null):void {
		
			//var subjecto:* = xml.@subjects != undefined ? xml.@subjects.split(" ") : xml.@subject!=undefined ? xml.@subject : null;
			subject = subject || String(xml.@subject);
			if (subject == null) {
				trace("addFindingsMap() warning. No subject attribute found. Using empty string.");
				subject = "";
			}
			
			var dict:Dictionary = subjectMap[subject] ||  createNewFindingsDictionary(subject);
			var c:XMLList = xml.find;
			
			for each(var node:XML in c) {
				if ( node['@class'] != undefined) {
					dict[ String(node['@class'])  ] = node;
				}
				else trace("addFindingsMap() unit failed. No class attrib defined for:" + node);
			}
			
			
		}
		
		public static function addFindingsMapBatch(xml:XML):void {
			var xmlList:XMLList = xml.*;
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				addFindingsMap(xmlList[i]);
			}
		}
		
		public static function scan(target:Object):XML {
			var retXML:XML = describeType(target);
			lastScanned = retXML;
			return retXML;
		}
		
		
		public static function propertyMap(target : Object, className:String=null) : Object {
			var propMap : Object;
			
		
			if (className == null) className = getQualifiedClassName( target );
			
			if (!cachedPropertyMaps[className]) {
				propMap = {};
				var classXML : XML = scan(target);
				//classXML.@name
				var factoryList:XMLList = classXML.factory;  // added support for factory node list, if found.
				var list : XMLList = factoryList.length() > 0 ? factoryList[0].* : classXML.*;
				
				var item : XML;
				for each (item in list) {
					var itemName : String = item.name().toString();
					switch(itemName) {
						case "variable":
							propMap[item.@name.toString()] = item.@type.toString();
							break;
						case "accessor":
							var access : String = item.@access;
							//if ((access == "readwrite") || (access == "writeonly")) {
								propMap[item.@name.toString()] = item.@type.toString();
							//}
							break;
					}
					
					cachedPropertyMaps[className] = propMap; 
				}
			} else {
				propMap = cachedPropertyMaps[className];
			}
			
			return propMap; 
		}
		
		

		
	}

}