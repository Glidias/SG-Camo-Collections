package sg.camogxml.render
{
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.IRenderPool;
	import sg.camo.interfaces.ISelectorSource;
	
	/**
	 * An extended GXMLCloneRender that supports pooling of cloned instances, and returns
	 * factory objects to the pool as the default destructor implementation.
	 * 
	 * @author Glenn Ko
	 */
	
	 [Inject(name='gxml',name='gxml',name='gxml',name='',name='textStyle')]
	public class GXMLPoolRender extends GXMLCloneRender implements IRenderPool
	{
		
	

		protected var _poolValue:int = 1;
		protected var _renderPool:RenderPool;
		
		
		public function GXMLPoolRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier)
		{
			super(definitionGetter, behaviours, stylesheet, propApplier, textPropApplier );
		}
		
		internal  function set renderPool(val:RenderPool):void {
			_renderPool = val;
		}
		
		public function set poolValue(val:int):void {
			if (_renderPool!=null) {
				trace("GXMLPoolRender set poolValue() failed. RenderPool already created!");
				return;
			}
			val = val == 0 ? 1 : val; 
			_poolValue = val;
		}
		public function get poolValue():int {
			return _poolValue;
		}
		
		public function get object():IDisplayRender {
			// required additional measure: 
			// Only allow retrieval from pool if class reference is non-cloned.
			return !_isCloned ? _renderPool.object : this;   
		}
		
		
		override protected function get cloneInstance():GXMLCloneRender {
			return new GXMLPoolRender(definitionGetter, behaviours, stylesheet, null, null);
		}
		
		override protected function cloneRender():GXMLCloneRender {
			var clone:GXMLPoolRender = super.cloneRender() as GXMLPoolRender;
			clone.renderPool = _renderPool;
			return clone;
		}
	
		
		protected function restoreSettings(changedHash:Object = null):void {
			if (changedHash == null) {
				return;
			}
			var restoreProps:Object = attributes.restoreProps;
			var dispObject:Object = _rendered;
			for (var i:String in changedHash) {
				if (restoreProps[i])  dispObject[i] = changedHash[i]; // restore any available props that have changed.
			}
		}
		

		override public function parseXML(source:String):void {
			
			super.parseXML(source);
			
			var attrib:Object = _rootNode.attributes;
			var restoreProps:Object = { };
			//.... TODO: introspect and get all necessary read/write properties, 
			//  and set them to restorePRops based on current rendered instance.
			// This is dumb...restoring properties would be much heavier compared to disposing the instances.
			// (Unless it's a specified set of propreties....)
			attrib.restoreProps = restoreProps;
			
			var tryPoolValue:Number = attrib.pool ? Number(attrib.pool) : _poolValue;
			if (!isNaN(tryPoolValue)) this.poolValue = int(tryPoolValue);
			var poolValue:int = this.poolValue;
			var poolAmount:uint = poolValue < 0 ? -poolValue : poolValue;
			
			poolAmount = poolAmount < 1 ? 1 : poolAmount;
			if (poolAmount > 0) {
				_isCloned = false;
				_renderPool = new RenderPool(_poolValue < 0);
				_renderPool.setFactory(this);
				_renderPool.allocate(poolAmount);
			}
		}
	

		
		// Overwritten destructors
		
		/**
		 * Returns object to pool instead of destroying it.
		 */
		override public function destroy():void {
			if (_renderPool) {
			//	trace("Returning back to pool");
				_renderPool.object = this; // add back to pool instead
			}
		}
		
		/**
		 * Also deconstructs render pool for total garbage collection.
		 * @param	boo
		 */
		override public function destroyRecurse(boo:Boolean=false):void {
			super.destroyRecurse(boo);
			if (_renderPool) {
				if (!_renderPool.deconstructed) {
					_renderPool.deconstruct();
				}
				_renderPool = null;
			}
		}
		

		
	}

}