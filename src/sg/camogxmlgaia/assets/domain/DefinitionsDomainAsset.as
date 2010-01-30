package sg.camogxmlgaia.assets.domain 
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.SpriteAsset;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDomainModel;
	import sg.camogxmlgaia.api.ISourceAsset;
		
	/**
	 * This Sprite asset composes a IDefinitionGetter instance, also considering asset's application domain as 
	 * and the current node xml as a reference for all definitions to be pre-cached into existing class definition
	 * stacks/manager for GXML Rendering. 
	 * 
	 * @author Glenn Ko
	 */
	
	 
	public class DefinitionsDomainAsset extends SpriteAsset implements ISourceAsset
	{
		/** Default IDefinitionGetter class implementation to use under loader's application domain or (usually) current application domain */
		public static var DEFAULT_IMPLEMENTATION:String = "sg.camogxml.render.GXMLDefinitions";
		/** @private */
		protected var _implementation:String;
		/** @private */
		protected var _definitionGetter:IDefinitionGetter;
		
		
		public function DefinitionsDomainAsset() 
		{
			super();
			_implementation = DEFAULT_IMPLEMENTATION;
		}
		
		public function get sourceType():String {
			return "definition";
		}
		public function get source():* {
			return _definitionGetter;
		}
		
		
		public function get definitionGetter():IDefinitionGetter {
			return _definitionGetter;
		}
		
		override public function parseNode(page:IPageAsset):void {
			super.parseNode(page);
			if ( _node.@implementation!=undefined )  _implementation = _node.@implementation;
		}
		
		
		override protected function onComplete(event:Event):void
		{
			super.onComplete(event);
			var domain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
			
			var defGetter:IDefinitionGetter = domain.hasDefinition(_implementation) ? new (domain.getDefinition(_implementation) as Class)() as IDefinitionGetter :  ApplicationDomain.currentDomain.hasDefinition(_implementation) ? new (ApplicationDomain.currentDomain.getDefinition(_implementation) as Class)() as IDefinitionGetter : null;
			if (defGetter == null) {
				trace("DefinitionsDomainAsset onComplete() halt! No IDefinitionGetter instance found for:"+_implementation);
				return;
			}
			_definitionGetter = defGetter;
			
			
			var domainModel:IDomainModel = defGetter as IDomainModel;
			if (domainModel != null) {
				domainModel.appDomain = domain;
				domainModel.modelXML = node;
			}
			

		}
		
		override public function toString():String
		{
			return "[DefinitionsDomainAsset] " + _id;
		}

		
	}

}