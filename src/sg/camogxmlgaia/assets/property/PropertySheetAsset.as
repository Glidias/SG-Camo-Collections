package sg.camogxmlgaia.assets.property 
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.TextAsset;
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.ISelectorSource;
	import camo.core.property.IPropertySheet;
	import flash.events.Event;
	import sg.camogxmlgaia.api.ISourceAsset;
	
	/**
	 * Standard property sheet asset to instantiate a single property sheet implementation.
	 * @author Glenn Ko
	 */
	public class PropertySheetAsset extends TextAsset implements ISourceAsset
	{
		/** Default IPropertySheet class _implementation to use under loader's application domain or (usually) current application domain */
		public static var DEFAULT_IMPLEMENTATION:String = "camo.core.property.PropertySheet";
		/**
		 * Whether to compress CSS text by default
		 */
		public static var DEFAULT_COMPRESS_TEXT:Boolean = true;
		
		/** @private */
		protected var _implementation:String;
		/** @private */
		protected var _propertySheet:IPropertySheet;
		/** @private */
		protected var _compressText:Boolean;
		
		
		public function PropertySheetAsset() 
		{
			super();
			_implementation = DEFAULT_IMPLEMENTATION;
			_compressText = DEFAULT_COMPRESS_TEXT;
		}
		
		override public function init():void
		{
			super.init();
			isNoCache = true; // hardcoded no caching
		}
		
		override public function parseNode(page:IPageAsset):void {
			super.parseNode(page);
			if ( _node.@implementation != undefined )  _implementation = _node.@implementation;
			if ( _node.@compressText!=undefined )  _compressText = node.@compressText == "false";
		}
		

		// -- ISourceAsset
		public function get sourceType():String {
			return "stylesheet";
		}
		public function get source():* {
			return _propertySheet;
		}
		
		
		
		override protected function onComplete(event:Event):void
		{
			super.onComplete(event);
			var domain:ApplicationDomain = ApplicationDomain.currentDomain;

			var propSheet:IPropertySheet = domain.hasDefinition(_implementation) ? new (domain.getDefinition(_implementation) as Class)() as IPropertySheet :  ApplicationDomain.currentDomain.hasDefinition(_implementation) ? new (ApplicationDomain.currentDomain.getDefinition(_implementation) as Class)() as IPropertySheet : null;
			if (propSheet == null) {
				trace("PropertySheetAsset onComplete() halt! No IPropertySheet instance found for:"+_implementation);
				return;
			}
			_propertySheet = propSheet;
			propSheet.parseCSS(text, _compressText);
		}
		
		override public function toString():String
		{
			return "[IPropertySheetAsset] " + _id;
		}
		
	}

}