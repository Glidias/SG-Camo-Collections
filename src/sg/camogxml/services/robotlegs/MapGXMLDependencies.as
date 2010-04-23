package sg.camogxml.services.robotlegs 
{
	import org.robotlegs.core.IInjector;
	import sg.camo.interfaces.INodeClassSpawner;
	import sg.camo.interfaces.INodeClassSpawnerManager;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camo.interfaces.ITypeHelperUtil;
	import sg.camogxml.api.IPropertyBinder;
	/**
	 * A portable service to help map common GXML dependencies to a robotlegs injector
	 * @author Glenn Ko
	 */
	
	[Inject]
	public class MapGXMLDependencies
	{
		
		public var injector:IInjector;
		
		public function MapGXMLDependencies(injector:IInjector) 
		{
			this.injector = injector;
		}
		
		public function mapNodeSpawners(nodeClassSpawner:INodeClassSpawner, manager:INodeClassSpawnerManager):void {
			injector.mapValue(INodeClassSpawner, nodeClassSpawner);
			if (manager) injector.mapValue(INodeClassSpawnerManager, manager);
		}
		
		public function mapPropertyMapCacheAndTypeHelper(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper, typeHelperUtil:ITypeHelperUtil=null):void {
			injector.mapValue( IPropertyMapCache, propMapCache);
			injector.mapValue( ITypeHelper, typeHelper);
			if (typeHelperUtil) injector.mapValue( ITypeHelperUtil, typeHelperUtil);
		}
		
		public function mapPropertyAppliers(propApplier:IPropertyApplier, textPropApplier:IPropertyApplier, tweenPropApplier:IPropertyApplier, compositePropApplier:IPropertyApplier, attribPropApplier:IPropertyApplier, behPropApplier:IPropertyApplier):void {
			injector.mapValue( IPropertyApplier, propApplier);
			injector.mapValue( IPropertyApplier, textPropApplier, "textStyle");
			injector.mapValue( IPropertyApplier, tweenPropApplier, "tweenStyle");
			injector.mapValue( IPropertyApplier, compositePropApplier, "composite");
			injector.mapValue( IPropertyApplier, attribPropApplier, "gxml.attribute");
			injector.mapValue( IPropertyApplier, behPropApplier, "gxml.behaviour");
		}
		
		
		public function mapPropertyBinder(binder:IPropertyBinder):void {
			injector.mapValue(IPropertyBinder, binder);
		}
		
		
		 
		
	}

}