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
		 */
		function getTypedConstructorParams():Array;
	}
	
}