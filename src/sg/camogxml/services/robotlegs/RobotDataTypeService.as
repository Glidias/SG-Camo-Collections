package sg.camogxml.services.robotlegs 
{
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import org.robotlegs.core.IInjector;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.ISelectorSource;
	
	import sg.camogxml.services.ResolveDataTypeService;
	
	import sg.camo.interfaces.INodeClassSpawner;
	import sg.camo.interfaces.INodeClassSpawnerManager;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camo.interfaces.ITypeHelperUtil;
	import sg.camogxml.api.IPropertyBinder;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	[Inject]
	public class RobotDataTypeService extends ResolveDataTypeService
	{
		
		protected var injector:IInjector;
		
		public function RobotDataTypeService(injector:IInjector, appDomain:ApplicationDomain = null, mapDomain:Boolean = false) 
		{
			super(appDomain);
			this.injector = injector;
			if (mapDomain && applicationDomain) injector.mapValue(ApplicationDomain, applicationDomain);
		}
		
		[Inject]
		override public function setNodeSpawners(nodeClassSpawner:INodeClassSpawner, manager:INodeClassSpawnerManager=null):void {
			super.setNodeSpawners(nodeClassSpawner, manager);
			injector.mapValue(INodeClassSpawner, nodeClassSpawner);
			if (manager) injector.mapValue(INodeClassSpawnerManager, manager);
		}
		
		[Inject]
		override public function setPropertyMapCacheAndTypeHelper(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper, typeHelperUtil:ITypeHelperUtil=null, autoMapTypes:Boolean=true):void {
			super.setPropertyMapCacheAndTypeHelper(propMapCache, typeHelper, typeHelperUtil, autoMapTypes)
			injector.mapValue( IPropertyMapCache, propMapCache);
			injector.mapValue( ITypeHelper, typeHelper);
			if (typeHelperUtil) {
				injector.mapValue( ITypeHelperUtil, typeHelperUtil);
				typeHelperUtil.registerFunction( "org.robotlegs.core::IInjector", getDefaultInjector);
			}
		}
		
		public function getDefaultInjector(val:String):IInjector {
			return injector;
		}
		
		[Inject(name='',name='textStyle',name='tweenStyle',name='composite',name='gxml.attribute',name='gxml.behaviour')]
		override public function setPropertyAppliers(propApplier:IPropertyApplier, textPropApplier:IPropertyApplier, tweenPropApplier:IPropertyApplier=null, compositePropApplier:IPropertyApplier=null, attribPropApplier:IPropertyApplier=null, behPropApplier:IPropertyApplier=null):void {
			super.setPropertyAppliers(propApplier, textPropApplier, tweenPropApplier, compositePropApplier, attribPropApplier, behPropApplier);
			injector.mapValue( IPropertyApplier, propApplier);
			injector.mapValue( IPropertyApplier, textPropApplier, "textStyle");
			injector.mapValue( IPropertyApplier, tweenPropApplier, "tweenStyle");
			injector.mapValue( IPropertyApplier, compositePropApplier, "composite");
			injector.mapValue( IPropertyApplier, attribPropApplier, "gxml.attribute");
			injector.mapValue( IPropertyApplier, behPropApplier, "gxml.behaviour");
		}
		
		[Inject(name='gxml',name='gxml',name='gxml',name='gxml')]
		override public function setGXMLSources(defGetter:IDefinitionGetter=null, styleGetter:ISelectorSource=null, behaviourSrc:IBehaviouralBase=null, renderSrc:IDisplayRenderSource = null):void {
			super.setGXMLSources(defGetter, styleGetter, behaviourSrc, renderSrc);
			if (defGetter) injector.mapValue(IDefinitionGetter, defGetter, "gxml");
			if (styleGetter) injector.mapValue(ISelectorSource, styleGetter, "gxml");
			if (behaviourSrc) injector.mapValue(IBehaviouralBase, behaviourSrc, "gxml");
			if (renderSrc)injector.mapValue(IDisplayRenderSource, renderSrc, "gxml");
		}
		
		
		
		[Inject]
		override public function setPropertyBinder(binder:IPropertyBinder=null):void {
			super.setPropertyBinder(binder);
			injector.mapValue( IPropertyBinder, binder);
		}
		
		
	}

}