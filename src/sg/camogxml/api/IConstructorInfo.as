package sg.camogxml.api 
{
	
	/**
	 * Interface for constructor information, which contains the necessary info required
	 * for instantiating classes with constructor parameters.
	 * 
	 * @author Glenn Ko
	 */
	public interface IConstructorInfo 
	{

		/**
		 * Returns required number of constructor parameters
		 */
		function get constructorParamsRequired():int;
		
		/**
		 * Returns total number of constructor parameters
		 */
		function get constructorParamsLength():int;
		
		/**
		 * Returns an assosiative array of typed constructor parameters, if available.
		 * <br/> 
		 * Note: There's actually a Flash player bug which requires classes to be
		 * instantiated beforehand before describeType() can reflect a constructor's 
		 * parameter types (otherwise, they'll always show up as untyped "*" characters). 
		 * As a result, I've decided to make it a convention that such classes
		 * using "typed-based" constructor application, should manually have to declare a static
		 * method under their class called "constructorParams( ...)" to declare the typed parameters used
		 * in their constructor from which application of values can occur by type-matching. Since not all
		 * parameters in constructors may have unique parameter types from which type-matching can occur, 
		 * I've decided to make this optional for developers creating classes to manually have to type out a static method
		 * to reflect their constructor's parameters if they so wish to support type-matching.<br/><br/> 
		 * For example, GXMLRender manually declares a static method "constructorParams" to reflect it's constructor information:
		 * @see sg.camogxml.render.GXMLRender
		 * 
		 */
		function getTypedConstructorParams():Array;
	}
	
}