package sg.camo.adaptors 
{
	import flash.text.TextField;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITextField;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	
	[Inject(name = '', name = 'textStyle', name='')]
	public class CompositePropertyApplier implements IPropertyApplier
	{
		
		public var propApplier:IPropertyApplier
		public var textPropApplier:IPropertyApplier;
		public var propMapCache:IPropertyMapCache;
		
		public function CompositePropertyApplier(propApplier:IPropertyApplier, textPropApplier:IPropertyApplier, propMapCache:IPropertyMapCache) 
		{
			this.propApplier = propApplier;
			this.textPropApplier = textPropApplier;
			this.propMapCache = propMapCache;
		}
		
		/**
		 * Applies properties to both target and nested textfield instance in target (if available). 
		 * It is assumed the properties is a cloned object whose keys can afford to be deleted.
		 * @param	target		The target
		 * @param	properties	 A cloned object of values to apply to the target
		 */
		public function applyProperties(target:Object, properties:Object):void {
			propApplier.applyProperties(target, properties);
			
			var findField:Object = target is TextField ? target : target is ITextField ? (target as ITextField).textField : null;
			if (findField) {
				var propMap:Object = propMapCache.getPropertyMap(target);
				for (var i:String in properties) {
					if (propMap[i]) delete properties[i];
				}
				textPropApplier.applyProperties(findField, properties);
			}
		}
		
		
		
	}

}