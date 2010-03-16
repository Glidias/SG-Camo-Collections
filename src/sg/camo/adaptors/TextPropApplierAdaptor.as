package sg.camo.adaptors 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	/**
	 * Property application system conventions for SG-Camo over any textfield. <br/>
	 * Personally, I'd prefer using a F*CSS IApplicator adaptor to support this under
	 * a ProxyApplierAdaptor instead. However, this version also applies standard
	 * properties over the TextField instance itself.
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
			super(propMapCache, typeHelper);
			if (propMapCache == null) return;
		}
		
		override public function applyProperties(target:Object, properties:Object):void {
			var txtField:TextField =  target as TextField;
			if (!txtField) throw new Error("TextPropApplierAdaptor :: Target must be TextField instance");
			
			var txtFormat:TextFormat = new TextFormat();
			for(var prop:String in properties) {
				if (txtFormat.hasOwnProperty (prop)) {
					var val:* = properties[prop];
					val = (val === "true" || val === "false") ? val==="true" : val;
					txtFormat[prop] =  val;
				}
			}
			
		
			txtField.defaultTextFormat = txtFormat;	
			txtField.setTextFormat(txtField.defaultTextFormat);
			
			super.applyProperties(target, properties);
		}
		
	}

}