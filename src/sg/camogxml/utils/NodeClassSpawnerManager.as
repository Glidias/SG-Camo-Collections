package sg.camogxml.utils 
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camogxml.api.IConstructorInfo;
	import sg.camogxml.api.IFunctionDef;
	import sg.camogxml.utils.ConstructorInfoCache;
	import sg.camogxml.utils.FunctionDefCreator;
	import sg.camogxml.utils.FunctionDefInvoker;
	import sg.camo.interfaces.INodeClassSpawnerManager;
	import sg.camogxml.utils.ConstructorUtils;
	import sg.camogxml.utils.GXMLGlobals;
	
	
	/**
	 * Class instantiator and dependency injector utility supporting constructor, setter 
	 * and method dependency injection with the help of Camo Core's utilities. 
	 * <br/><br/>
	 * This class was made specifically to support varying/adjustable settings over 
	 * newly instantiated instances through user-supplied XML node attribute settings.
	 * By supplying a class to instantiate with an accompanying XML node, varied settings can
	 * be applied to the instance based on given node attribute values.
	 * 
	 * @author Glenn Ko
	 */
	public class NodeClassSpawnerManager implements INodeClassSpawnerManager
	{
		public var typeHelper:ITypeHelper = GXMLGlobals.typeHelper;
		public var propMapCache:IPropertyMapCache = GXMLGlobals.propertyMapCache;
		
		/** @private */
		protected var bind:Function = noBinding;  
		
		/** Denotes constructor injection */
		public static const CONSTRUCTOR_TYPE:String = "constructor";	
		/** Denotes setter injection */
		public static const SETTER_TYPE:String = "setter";	
		/** Denotes method injection */
		public static const METHOD_TYPE:String = "method";		
		
		private var DUMMY_NODE:XML = <node></node>
		
		private static var valueMappings:Dictionary = new Dictionary();	
		
		private function noBinding(str:String):* {
			return str;
		}
		
		/**
		 * Use this setter to set up a new default binding method to return a specific value.
		 */
		public function set bindingMethod(func:Function):void {
			bind = func;
		}
		
		
		/**
		 * Sets up wiring of subjects to values.
		 * 
		 * @param	xml
		 */
		public function mapXMLSubjects(xml:XML):void {
			var mappingList:XMLList = xml.*;
			var node:XML;
			var i:int = 0;
			var len:int = mappingList.length();
			var typeParamPrefix:String = xml.@typeParamPrefix;

			while (i < len) {
				node = mappingList[i];
				typeParamPrefix =  (node.@typeParamPrefix != undefined )  ?  node.@typeParamPrefix : typeParamPrefix;
				doMappingChunk(xml, typeParamPrefix);
				i++;
			}
		}
		private function doMappingChunk(xml:XML, typeParamPrefix:String = ""):void { 
			var subjectList:XMLList = xml.*;
			var node:XML;
			var i:int = 0;
			var len:int = subjectList.length();
		
			
			while (i < len) {
				node = subjectList[i];
				typeParamPrefix = node.@typeParamPrefix != undefined ? node.@typeParamPrefix : typeParamPrefix;
				if (node.@id == undefined) {
					trace("Warning! No subject id specified for: doMappingChunk:" + xml.toXMLString());
					i++;
					continue;
				}
				doSubjectNode(node, typeParamPrefix, node.@id)
				i++;
			}
		}
		private function doSubjectNode(xml:XML, typeParamPrefix:String, subject:String):void {
			var children:XMLList = xml.*;
			var node:XML;
			var len:int = children.length();
			for (var i:int = 0 ; i < len; i++)  {
				node = children[i];
				var nodeName:String = String(node.name());
				if (nodeName === "clone") {
					var cloneId:String = node.@id != undefined ? node.@id : null;
					if (cloneId == null) {
						trace("Error. Clone failed for:"+node.toXMLString());
						continue;
					}
					var toCloneValMap:ValueMap =  valueMappings[cloneId]; 
					if (toCloneValMap == null) {
						trace("Error. No value mapping found. Clone failed for:"+node.toXMLString());
						continue;
					}
					valueMappings[subject] = toCloneValMap.clone();
				}
				else if (nodeName === "clear") {
					clearSubject(clearSubject);
				}
				else {
					
					var type:String = node.@type != undefined ? node.@type : SETTER_TYPE;
					var typeParam:String =node.@typeParam!=undefined  ? typeParamPrefix + node.@typeParam : type === SETTER_TYPE ? node.@attrib : null;
					var value:* = node.@type == "method" ? node.toString() :   node.@method != undefined ?   bind( node.@method.toString()  )  :   Boolean(node) ? node.@bind == "true" ? bind(node.toString()) : node.toString()  : null;
					var compulsory:Boolean = node.@compulsory == "true";
					var methodParams:Array = ( node.@method == undefined || !(value is Function) ) ? null : createMethodParams(node);
					mapSubjectAttributeToValue(subject, node.@attrib, typeParam, type, value, compulsory, methodParams);
				}
			}
		}

		private  function createMethodParams(node:XML):Array {
			
			var methodParams:Array = [];
			methodParams.delimiter = node.@delimeter;
			var arr:Array;
			var i:int;
			var len:int;
			var list:XMLList = node.param;
			if (list.length() < 1)  list = node.parameter;
			len = list.length();
			
			for (i = 0; i < len; i++) {
				var pNode:XML = list[i];
				var type:String =  pNode.@type != undefined ? pNode.@type.toString().toLowerCase() : "string";
				var val:*  = pNode.@bind == "true" ?  bind(typeHelper.getType( pNode.toString(), type)) :  pNode.toString();
				methodParams.push(  val );
			}
			
			return methodParams.length > 0 ? methodParams : null;
		}

		
		/**
		 * Maps a node attribute based on a given subject context
		 * @param	subject		A given subject key such as a class instance, a class, or string in order to 
		 *						determine the subject context for mapping values. An xml node can also be supplied from
		 * 						which the node name is used as the subject key.
		 * @param	attribute	The attribute name.
		 * @param	typeParam	Define the property or property type to look out for to inject the value.
		 * @param	type		Defaulted to SETTER_TYPE injection. Set this to either one of the CONSTRUCTOR_TYPE / SETTER_TYPE / METHOD_TYPE  constants to define the type of dependency injection being used. 
		 * @param	value		A fixed application-specific non-string value to be injected, a pure string value that can be processed and binded, or a custom function to parse an XML attribute string value and resolve it's value.
		 * @param   compulsory 	Whether to assert that setting of the value is compulsory, even if the attribute was left undefined. 
		 * 						If you have default values that needs to be applied regardless, you should set this to true.
		 * @param   methodArr	If value is a method, you can supply a pre-configured array of values to be applied to the method.
		 */
		public function mapSubjectAttributeToValue(subject:*, attribute:String, typeParam:String, type:String=SETTER_TYPE, value:*=null, compulsory:Boolean=false, methodArr:Array=null):void {
			var subjectKey:String =  getSubjectKey(subject);
			var obj:ValueMap = valueMappings[subjectKey] || createNewValueMap(subjectKey);
			
			if (type === SETTER_TYPE ) obj.setterValues[typeParam] = new AttributeValuePair(attribute, value, compulsory, methodArr)
			else if (type === METHOD_TYPE) {
				var paramsXML:XML = XML(value);
				//FunctionDefCreator.fromXML(paramsXML)
				obj.methodValues.push( new AttributeValuePair(attribute, "|", compulsory, createMethodParams(paramsXML) , typeParam ) );
				
			}
			else {
				obj.setConstructorValue( typeParam,  new AttributeValuePair(attribute, value, compulsory, methodArr, typeParam) );
			}
			
		}
		/**
		 * Removes entire subject mapping.
		 * @param	subject
		 */
		public function clearSubject(subject:*):void {
			delete valueMappings[subject];
		}
		
		private function createNewValueMap(subjectKey:String):ValueMap {
			var obj:ValueMap = new ValueMap();
			valueMappings[subjectKey] = obj;
			return obj;
		}
		
		private function getSubjectKey(subject:*):String {
			return subject is String ? subject : subject is XML ? String( (subject as XML).name() ) : getQualifiedClassName(subject);
		}
		
		public function injectInto(classInstance:*, node:XML=null, subject:*= null, additionalBinding:Function = null):void {
			//var propMapCache:IPropertyMapCache = ;
			var className:String = getQualifiedClassName(classInstance);
			var subjectKey:String = subject ? getSubjectKey(subject) : node ? String(node.name()) : className;
			var obj:ValueMap = getValueMapOfs(subjectKey, className);
			if (obj == null) {
				 // don't fail gracefully for this, assume ValueMap required
				throw new Error("NodeClassSpawnerManager injectInto() failed. No value map found for:"+classInstance)  
			}
			node = node || DUMMY_NODE;
			performInjections(node, GXMLGlobals.propertyMapCache, obj, className, classInstance, additionalBinding);
		}
		
		protected function getValueMapOfs(subjectKey:*, className:String):ValueMap {
			var obj:ValueMap = valueMappings[subjectKey];
			var obj2:ValueMap = valueMappings[className];  
			 		
			if (obj == null) { 
				if (obj2 == null) return null; //throw new Error("NodeClassSpawnerManager :: getValueMapOfs() No value map found for:"+subjectKey + " or "+className);  
				else {
					obj = obj2;
					obj2 = null;
				}
			}
			else if (obj2 != null) {
				
				obj = obj.merge(obj2); // test: added in obj2 tier consideration
			}
			
			return obj;
		}
		
		/**
		 * 	Attempts to instantiate the class with the correct
		 * mapped constructor parameters and all other setter values when considering
		 * any accompanying mapped xml node attributes found in the xml node.
		 * @param	classDef	The class to instantiate
		 * @param	node		The xml node with accompanying attributes (if available)
		 * @param	subject		The base registered context subject
		 * @param   additionalBinding	Supplies an additional binding method to perform resolving of values.
		 * 							    If the resolved value returns null, it'll still use the default binding resolve method.
		 * @return	The instantiated class
		 */
		public function spawnClassWithNode(classDef:Class, node:XML=null, subject:*= null, additionalBinding:Function=null ):* {
			var className:String = getQualifiedClassName(classDef);
			node = node || DUMMY_NODE;
			var subjectKey:String = subject ? getSubjectKey(subject) : String(node.name());
			
			var obj:ValueMap = getValueMapOfs(subjectKey, className);
			if (obj == null) return new classDef();  // no Value map found, attempting direct instantiate.
			
			var classInstance:*;
			
			// Typed-Specific Constructor Injection
			var constructInfo:IConstructorInfo = ConstructorInfoCache.getConstructorInfoCache(className, classDef);
			var len:int = constructInfo.constructorParamsLength;
			var requiredLen:int = constructInfo.constructorParamsRequired;
			var typedArray:Array = constructInfo.getTypedConstructorParams();
		
			var dict:Dictionary = new Dictionary(true);
			if (len > 0) {
				var applyConstructorParams:Array = new Array(len);
	
				var constructHash:Array = obj.constructorValues;
				
				for (var i:int = 0; i < len; i++ ) {
	
					var type:String = typedArray[i];
					if ( dict[type]) {
						type = type + "*" + (dict[type] + 1);
						dict[type] = dict[type] + 1;
					}
					else dict[type] = 1;
					
				
					//todo  consider * occurances of similar types
					var attribValPair:AttributeValuePair =  constructHash[type]; 
					
					 
					if (attribValPair == null) {
						if ( i >= requiredLen ) continue;  
						else {
							throw new Error("NodeClassSpawnerManager parseNode() failed. No constructor parameter mapping for index:"+i+ " under "+className);
						}
					}
					if (type == null) type = attribValPair.typeParam;
					
				
					var isCompulsory:Boolean = attribValPair.compulsory || i < requiredLen;
					
					var gotDefineAttrib:Boolean = node['@' + attribValPair.attribute] != undefined;
					var attribValue:String =  gotDefineAttrib ? node['@' + attribValPair.attribute] : null;
					
					if (!gotDefineAttrib && !isCompulsory) continue; 
				
					type = type.toLowerCase();
					
					var value:* = resolveValue(attribValPair.value, attribValue, type, attribValPair.methodParams, additionalBinding );
					if (value == null) {
						trace("NodeClassSpawnerManager :: warning! Resolved constructor value is null", attribValPair , type);
					}
					applyConstructorParams[i] = value;
				}
				classInstance = ConstructorUtils.instantiateClassConstructor(classDef, applyConstructorParams);
			}
			else classInstance = new classDef();
			
			performInjections(node, propMapCache, obj, className, classInstance, additionalBinding);
			
			return classInstance;
		}
		
		
		
		protected function performInjections(node:XML, propMapCache:IPropertyMapCache, obj:ValueMap, className:String, classInstance:*, additionalBinding:Function):void {
			// Setter injection
			
			var propertyMap:Object = propMapCache.getPropertyMapCache(className) || propMapCache.getPropertyMap(classInstance);
			applyNodeProperty(obj.setterValues, propertyMap, node, classInstance, additionalBinding);
			
			// Method injection
			var typedArray:Array = obj.methodValues;
			var len:int = typedArray.length;
			
			
			for (var i:int = 0; i < len; i++ ) {
				var attribValPair:AttributeValuePair = typedArray[i];
				var funcDef:IFunctionDef = (attribValPair.value as IFunctionDef) || (attribValPair.value = FunctionDefCreator.create(classInstance, attribValPair.typeParam, false, attribValPair.value));
				var applyConstructorParams:Array = node["@"+attribValPair.attribute]!=undefined ?  node["@"+attribValPair.attribute].toString().split(funcDef.delimiter) : attribValPair.methodParams.concat();  // todo: consider inline attribute
		
				for (var u:String in applyConstructorParams) {
					applyConstructorParams[u] = validateType(applyConstructorParams[u],  additionalBinding);
				}
				FunctionDefInvoker.invoke(funcDef, applyConstructorParams, classInstance[attribValPair.typeParam]); 
			}
		}
		

		/**
		 * Parses an XML node with a class attribute containing the class definition, and
		 * attempts to instantiate it with spawnClassWithNode().
		 * @param	node	  The class node to be parsed 
		 * @param	subject	  The base registered context subject
		 * @param	domain	  Supplies an additional domain from which to retrieve the class.
		 * @param   additionalBinding	Supplies an additional binding method to perform resolving of values.
		 * 							    If the resolved value returns null, it'll still use the default binding resolve method.
		 * @return	The instantiated class (or null if unsuccessful).
		 */
		public function parseNode(node:XML, subject:*= null, domain:ApplicationDomain = null, additionalBinding:Function=null):* {
			
			var classAttrib:String = node["@class"];
			if (!Boolean(classAttrib)) {
				throw new Error("NodeClassInstantiator parseNode failed! No class attribute found:"+node.toXMLString());
			}
			var curDomain:ApplicationDomain = ApplicationDomain.currentDomain;
			
			var classDef:Class = domain ? domain.hasDefinition(classAttrib) ? domain.getDefinition(classAttrib) as Class : curDomain.hasDefinition(classAttrib) ? curDomain.getDefinition(classAttrib) as Class : null   : curDomain.hasDefinition(classAttrib) ? curDomain.getDefinition(classAttrib) as Class : null;

			if (classDef == null) {
				throw new Error("NodeClassInstantiator parseNode failed! No class definition found:"+node.toXMLString() );
			}
			
			return spawnClassWithNode(classDef, node, subject, additionalBinding);
			
		}
		
		private function applyNodeProperty(setterHash:Object, propertyMap:Object, node:XML, classInstance:Object, additionalBinding:Function):void {
			var type:String;
			var value:*;
			var attribValue:String;
			
			for (var i:String in setterHash) {
				
				
				var attribValPair:AttributeValuePair = setterHash[i];
				if ( i === "var") {		
					var attribList:XMLList = node.attributes();
					for each (var attrib:XML in attribList) {
						var attribName:String = attrib.name();
						attribValue = attrib.toXMLString();
						type = propertyMap[attribName]
						if (type) {
							value = additionalBinding != null ? validateType(additionalBinding(attribValue), null) || validateType( typeHelper.getType(attribValue, type), additionalBinding )  : validateType( typeHelper.getType( attribValue, type), additionalBinding );
							classInstance[attribName] = value;
						}
					}
					
					continue;
				}
				type = propertyMap[i];
				
				if ( type ) {
					var isDefined:Boolean = node['@' + attribValPair.attribute] != undefined;
					attribValue = isDefined ? node['@' + attribValPair.attribute] : null;
					if (isDefined || attribValPair.compulsory) {
						value = resolveValue(attribValPair.value, attribValue, type, attribValPair.methodParams, additionalBinding );
						if (value == null) {
							trace("NodeClassSpawnerManager :: critical warning! Resolved setter value is null", attribValPair , type);
						}
						classInstance[i] = value;
						
					}
				}
				else {
					trace("NodeClassInstantiator:: Warning! mapped setter property '"+i+"' for:"+classInstance+ " failed!");
				}
			}
		}
		
		private function resolveValue(value:*, attributeValue:String, type:String, methodParams:Array = null, addBinding:Function=null ):* {
			return value is Function && type!="function" ? methodParams!=null ?  attributeValue!=null ? value.apply(null, methodParams.concat( attributeValue.split( (methodParams.delimiter||"$$$") ))) : value.apply(null, methodParams.concat() ) : value(attributeValue) : value is String ? addBinding!=null ? validateType(addBinding(attributeValue || value), null) ||validateType( typeHelper.getType( (attributeValue || value), type), addBinding )  : validateType( typeHelper.getType( (attributeValue || value), type), addBinding )  : value;
		}
		
		private function bind2(value:*,  additionalBinding:Function):* {
			if (additionalBinding != null) {
				var chkValue:* = additionalBinding(value);
				return chkValue!=null ? chkValue : bind(value)
			}
			else return bind(value);
		}
		
		private function validateType(val:*, additionalBinding:Function):* {
			return val is String ? bind2(val, additionalBinding) : val;
		}		
	
	}


}

import sg.camogxml.utils.CloneObject;

internal class ValueMap {
	
	public var setterValues:Object = { };
	public var methodValues:Array = [];
	public var constructorValues:Array = [];
	
	public function ValueMap() {

	}
	public function setConstructorValue(key:String, value:*):void {
		//if  ( constructorValues[key] != null ) constructorValues[constructorValues.indexOf(constructorValues[key])] = value
		//else constructorValues.push(value);
		constructorValues[key] = value;
		
		
	}
	
	public function clone():ValueMap {
		var ret:ValueMap =  new ValueMap();
		ret.setterValues = CloneObject.cloneObj(setterValues);
		ret.constructorValues = CloneObject.cloneArr(constructorValues);
		ret.methodValues =  CloneObject.cloneArr(methodValues);
		return ret;
	}
	
	public function merge(other:ValueMap):ValueMap {
		var valueMap:ValueMap = clone();
		var hash:Object;
		var arr:Array;
	
		var i:String;
		
		hash = other.setterValues;
		for ( i in hash) {
			valueMap.setterValues[i] = hash[i];
		}
	
		arr = other.constructorValues;
		for (i in arr) {
			valueMap.constructorValues[i] = arr[i];
		}
		
		arr = other.methodValues;
		for (i in arr) {
			valueMap.methodValues[i] = arr[i];
		}
		
		return valueMap;
	}
	
}

internal class AttributeValuePair {
	public var attribute:String;
	public var value:*;
	public var compulsory:Boolean;
	public var typeParam:String;
	public var methodParams:Array;
	
	public function AttributeValuePair(attribute:String, value:*, compulsory:Boolean, methodParams:Array = null, typeParam:String=null) {
		this.value = value;
		this.attribute = attribute;
		this.compulsory = compulsory;
		this.typeParam = typeParam;
		this.methodParams = methodParams;
	}
	
	public function toString():String {
		return "AttributeValuePair:" + attribute + " || " + value;
	}
	

}


