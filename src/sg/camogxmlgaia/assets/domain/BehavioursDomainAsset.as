package sg.camogxmlgaia.assets.domain 
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.SpriteAsset;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDomainModel;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IXMLModel;
	import sg.camogxmlgaia.api.ISourceAsset;
	
	/**
	 * This sprite asset usually contains the compiled code-set of various behaviour classes which are loaded 
	 * into it's own application context (or into the current domain), depending on the domain property set 
	 * in the Gaia asset node.
	 * <br/><br/>
	 * This allows you to load pre-compiled behaviours later during the course of the application, or run a different 
	 * sub-set of behaviours at differnet levels of the site.
	 * 
	 * @see sg.camogxml.render.GXMLBehaviours
	 * 
	 * @author Glenn Ko
	 */
	public class BehavioursDomainAsset extends XMLSpriteAsset implements ISourceAsset
	{
		/** Default IBehaviouralBase class _implementation to use under loader's application domain or
		 * (usually) current application domain, if no IDefinitionGetter implementation is found for loaded content. */
		public static var DEFAULT_IMPLEMENTATION:String = "sg.camogxml.render.GXMLBehaviours";
		
		/** @private */
		protected var _implementation:String;
		/** @private */
		protected var _behaviourBase:IBehaviouralBase;
		/** @private */
		protected var _defGetter:IDefinitionGetter;
		
		
		
		public function BehavioursDomainAsset() 
		{
			super();
			_implementation = DEFAULT_IMPLEMENTATION;
		}
		
		public function get sourceType():String {
			return "behaviour";
		}
		public function get source():* {
			return _behaviourBase || _defGetter;
		}
		
		override public function parseNode(page:IPageAsset):void {
			super.parseNode(page);
			if ( _node.@implementation !=undefined )  _implementation = _node.@implementation;
		}
		

		
		override protected function doComplete():void
		{
			if (loader.content is IDefinitionGetter) {
				_defGetter = loader.content as IDefinitionGetter;
				return;
			}
			
			
			var domain:ApplicationDomain = loader.contentLoaderInfo.applicationDomain;
			
			var behBase:IBehaviouralBase = domain.hasDefinition(_implementation) ? new (domain.getDefinition(_implementation) as Class)() as IBehaviouralBase :  ApplicationDomain.currentDomain.hasDefinition(_implementation) ? new (ApplicationDomain.currentDomain.getDefinition(_implementation) as Class)() as IBehaviouralBase : null;
			if (behBase == null) {
				trace("BehavioursDomainAsset onComplete() halt! No IBehaviouralBase instance found for:"+_implementation);
				return;
			}
			_behaviourBase = behBase;
			_defGetter = _behaviourBase as IDefinitionGetter;
			
			var domainModel:IDomainModel = behBase as IDomainModel;
			
			if (domainModel != null) {
				domainModel.appDomain = domain;
				domainModel.modelXML = _xml || node;
			}
		}
		
		override public function toString():String
		{
			return "[BehavioursDomainAsset] " + _id;
		}

		
	}

}