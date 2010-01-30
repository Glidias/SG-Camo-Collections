package camo.core.utils 
{
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.IReflectClass;
	
	/**
	 * Handy commands to inspect targets through introspection/reflection. If targetted value is self-inspecting
	 * through the IReflectClass interface signature, it'll refer to the interface's reflected class instead. 
	 * 
	 * @see sg.camo.interfaces.IReflectClass
	 * 
	 * @author Glenn Ko
	 */
	public class ClassInspect
	{
		
		public static function getClassName(value:*):String {
			return value is IReflectClass ? getQualifiedClassName( (value as IReflectClass).reflectClass ) : getQualifiedClassName(value);
		}
		public static function describe(value:*):XML {
			return value is IReflectClass ?  describeType( (value as IReflectClass).reflectClass ) :  describeType(value);
		}
		
	}

}