package sg.camogxml.utils 
{
	/**
	 * A ValueMap provides a means of supplying a set of constructor/setter
	 * values to another class that is to be instantiated.
	 * 
	 * @see sg.camogxml.utils.ValueMapInstantator
	 * 
	 * @author Glenn Ko
	 */
	public class ValueMap
	{
		/** The default setter class to instantiate for all ValueMaps if no setter instance 
		 * was supplied in constructor. 
		 * Class type must be a dynamic object. */
		public static var DEFAULT_SETTER_CLASS:Class = Object;
		
		/** The default array class to instantiate for all ValueMaps if no array instance 
		 * was supplied in constructor.
		 * Class type must be an array. */
		public static var DEFAULT_ARRAY_CLASS:Class = Array;
		
		/**
		 * The hash of setter values to apply to a target. 
		 */
		public var setter:Object;
		/**
		 * The array of constructor values to apply to a target's constructor
		 */
		public var constructor:Array;
		
		
		/**
		 * Constructor. Allows you to inject optional parameters to determine
		 * an already-available type of setter hash or constructor array to use.
		 * @param	$setter		  Optional parameter for a setter hash instance to use
		 * @param	$constructor  Optional parameter for a constructor array instance to use
		 */
		public function ValueMap($setter:Object=null, $constructor:Array=null) 
		{
			setter = $setter || new DEFAULT_SETTER_CLASS();
			constructor = $constructor || new DEFAULT_ARRAY_CLASS();
		}
		

		
		/**
		 * Standard static method to create a string-based ValueMap from XML directly.
		 * @param    xml		The XML to parse into a value map
		 * @param	$setter		  Optional parameter for a setter hash instance to use
		 * @param	$constructor  Optional parameter for a constructor array instance to use
		 * @return  A ValueMap if the XML was successfully parsed, or null if XML was invalid.
		 */
		public static function fromXML(xml:XML, $setter:Object = null, $constructor:Array = null):ValueMap {
			var retMap:ValueMap = new ValueMap($setter, $constructor);
			var mappingList:XMLList = xml.map;
			var constructor:Array = retMap.constructor;
			var setter:Object = retMap.setter;
			var len:int = mappingList.length();
			var typeParam:String;
			for (var i:int = 0; i < len; i++) {
				var node:XML = mappingList[i];
				if (node.@type.toString() === "constructor") {
					if (node.@typeParam != undefined) {
						typeParam = node.@typeParam;
						constructor[typeParam] = i;
						constructor["*" + i] = typeParam;
					}
					constructor.push( node.toString() );
				}
				else {
					if (node.@typeParam == undefined) {
						trace("ValueMap.fromXML() error: No typeParam specified:"+mappingList);
						continue;
					}
					setter[node.@typeParam.toString() ] = node.toString();
				}
			}
			return retMap;
		}
		
		/**
		 * This method can be registered to TypeHelperUtil to allow creating of value maps from
		 * a string xml representation of a value map.
		 * @param	str   Converts string to an XML for parsing into a ValueMap 
		 */
		public static function fromXMLString(str:String):ValueMap {
			return fromXML( XML(str) );
		}
		
	}

}