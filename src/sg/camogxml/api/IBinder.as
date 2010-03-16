package sg.camogxml.api 
{
	
	/**
	 * Cross-platform interface signature for generic bindings to occur on the application-side end.
	 * @author Glenn Ko
	 */
	public interface IBinder 
	{
		/**
		 * 
		 * @param	target			The target that holds a property
		 * @param	targetProperty	A single property of the target
		 * @param	sourcePath		A starting host id and a chain of bindable properties in dot-delimited syntax. (eg. 'hostId.propA.propB.someMethod(12).a' )
		 * 							for the property chain to trigger a binding change on the target's property..
		 */
		function addBinding(target:Object, targetProperty:String, sourcePath:String ):void;
		
	}
	
}