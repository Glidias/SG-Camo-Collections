package sg.camogxml.utils 
{
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import sg.camogxml.api.IFunctionDef;
	
	/**
	 * Handy utility to generate factory methods, function definitions off a particular class or instance.
	 * 
	 * @see sg.camogxml.api.IFunctionDef
	 * 
	 * @author Glenn Ko
	 */
	public class FunctionDefCreator
	{
		
		private static var CACHED_DEFS:Dictionary = new Dictionary();
		
		/**
		 * Searches for a given method in a particular target class or instance, and returns a function definition of it
		 * @param	target		A target Class or instance. If only a Class is specified, than only the Class' static methods are 
		 * 						searched for.
		 * @param	methodName	The method name to search for.
		 * @param   overload	Manually set this to true to allow you to overload a method with extra parameters 
		 * 						(Since, describeType doesn't check for (...rest) parameters in methods, you have to manually
		 * 						declare that the method is overloadable here)
		 * @param   delimeter	The string delimiter to use when executing parameters of a function in short-form
		 * @return	A IFunctionDef containing information on the method, or null if no method is found.
		 */
		public static function create(target:*, methodName:String, overload:Boolean=false, delimiter:String=","):IFunctionDef {
		
			var classDesc:XML =  describeType( target );
			var methodList:XMLList = classDesc.method.(@name == methodName);
			
			if (methodList.length() > 0) return new FunctionDefinition( target[methodName], methodList[0], overload, delimiter);
			throw new Error("No method found for:"+methodName + " under "+target);
			return null;
		}
		
		/**
		 * Gets and caches a fixed function definition.
		 * @param	target
		 * @param	methodName
		 * @return	
		 */
		public static function get(target:*, methodName:String, overload:Boolean=false, delimiter:String=","):IFunctionDef {
			var className:String = getQualifiedClassName(target);
			return CACHED_DEFS[className + "+" + methodName] || (CACHED_DEFS[className + "+" + methodName] = create(target, methodName, overload, delimiter));
		}
		
		public static function fromXML(node:XML, method:Function=null):IFunctionDef {
			return new FunctionDefinition(method, node, node.@overload == "true", node.@delimiter );
		}
		
		
	}

}
import sg.camogxml.api.IFunctionDef;

internal class FunctionDefinition implements IFunctionDef {
	
	private var _method:Function;
	private var _requiredLength:int = 0;
	private var _params:Array;
	private var _overload:Boolean = false;
	private var _delimiter:String;
	
	
	// extra info
	private var declaredBy:String;
	private var name:String;
	private var _returnType:String;
	
	
	public function FunctionDefinition($method:Function, xml:XML, $overload:Boolean=false, $delimiter:String=",") {
		_method = $method;
		var list:XMLList = xml.parameter;
		var len:int = list.length();
		_params = new Array(len);
		var paramNode:XML;
		for (var i:int = 0; i < len; i++) {
			paramNode = list[i];
			_requiredLength += paramNode.@optional == "true" ? 0 : 1;
			_params[i] =  paramNode.@type;
		}
		_returnType = xml.@returnType;
		_overload = $overload;
		_delimiter = $delimiter;
		
		// extra info
		declaredBy = xml.@declaredBy;
		name = xml.@name;
	}
	
	public function get method():Function {
		return _method;
	}

	public function get overload():Boolean {
		return _overload;
	}
	public function get requiredLength():int {
		return _requiredLength;
	}
	public function getParams():Array {
		return _params.concat();
	}
	public function get delimiter():String {
		return _delimiter;
	}
	

	
	
	public function toString():String {
		return "[FunctionDefinition] "+name+" declaredBy:"+declaredBy+" >> ["+ _params + "] [Overload]:"+_overload+ ",[ReturnType]:"+_returnType;
	}
}