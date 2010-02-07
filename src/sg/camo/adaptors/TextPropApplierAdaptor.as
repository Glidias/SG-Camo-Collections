package sg.camo.adaptors 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * Property application system conventions for SG-Camo over any textfield. <br/>
	 * Personally, I'd prefer using a F*CSS IApplicator adaptor to support this under
	 * a ProxyApplierAdaptor instead.
	 * 
	 * @see sg.camo.adaptors.ProxyApplierAdaptor;
	 * @see sg.fcss.adaptors.ApplicatorProxy;
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject(name='', name='')]
	public class TextPropApplierAdaptor extends PropApplierAdaptor
	{
		
		public function TextPropApplierAdaptor(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper) 
		{
			if (propMapCache == null) return;
			super(this, propMapCache, typeHelper);
		}
		
		override public function applyProperties(target:Object, properties:Object):void {
			if (target is TextField) {
				super.applyProperties(target, properties);
				
				var txtField:TextField = target as TextField;
				var format:TextFormat = new TextFormat();
		
				for(var prop:String in properties) {
					if (format.hasOwnProperty (prop)) {
						var val:* = properties[prop];
						val = (val === "true" || val === "false") ? val === "true"  : val;
						format[prop] =  val;
					}
				}
				
				txtField.defaultTextFormat = format;
			}
			else {
				throw new Error("The supplied target was not a TextField.");
			}
		}
		
	}

}