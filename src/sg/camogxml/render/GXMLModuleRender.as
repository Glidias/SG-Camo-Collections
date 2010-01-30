package sg.camogxml.render
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.IRenderPool;
	import sg.camo.interfaces.ISelectorSource;
	
	import sg.camogxml.utils.GPropertyApplyerUtil;
	
	/**
	 * A cachable/clonable/poolable GXML render for replicating copies of itself en-masse.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLModuleRender extends GXMLRender implements IRenderFactory, IRenderPool
	{
		
	
		protected var _isCloned:Boolean = true;
		protected var _poolValue:int = 1;
		protected var _renderPool:RenderPool;
		
		
		public function GXMLModuleRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, inlineStyleSheetClass:Class=null)
		{
			super(definitionGetter, behaviours, stylesheet, inlineStyleSheetClass);
		}
		public static function constructorParams(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, inlineStyleSheetClass:Class=null):void { };
		
		
		internal  function set renderPool(val:RenderPool):void {
			_renderPool = val;
		}
		
		public function set poolValue(val:int):void {
			if (_renderPool!=null) {
				trace("GXMLModuleRender set poolValue() failed. RenderPool already created!");
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

		override protected function getBehaviour(behName:String):IBehaviour {
			var retBeh:IBehaviour = behaviours.getBehaviour(behName);
				//trace(behaviours);
				
			
			if (_curProps != null) {	  
				if (_curBehNode != null) { 
					var attrib:Object = _curBehNode.attributes;
					var cached:Object = GPropertyApplyerUtil.applyCachableProperties(retBeh, _curProps);
				//trace(attrib.behaviourProps is Array);
			
					var arr:Array = attrib.behaviourProps as Array || createBehaviourProps(attrib);
					
					arr.push(cached);
				//	trace(arr);
				}
				else  GPropertyApplyerUtil.applyProperties(retBeh, _curProps);
			}
			return retBeh;
			
		}
		
		private function createBehaviourProps(attrib:Object):Array {
			var arr:Array = new Array();
			attrib.behaviourProps = arr;
	
			return arr;
		}

		
		protected var _curClone:GXMLModuleRender;
		
		protected function cloneRender():GXMLModuleRender {
			var clone:GXMLModuleRender = new GXMLModuleRender(definitionGetter, behaviours, stylesheet, _inlineStyleSheetClass);
			_curClone = clone;
			clone.idMap = { }; 
			var clonedRoot:XMLNode = _rootNode.cloneNode(true);
			var disp:DisplayObject = reRenderNode(clonedRoot);
			if ( disp is DisplayObjectContainer) createCloneChild(clonedRoot.firstChild, disp as DisplayObjectContainer);
			clone.firstChild = clonedRoot;
			clone.rendered = disp;
			clone.renderPool = _renderPool;
			_curClone = null;
			return clone;
		}
		
		public function set rendered(val:DisplayObject):void {
			_rendered = val;
		}
		
		// -- IRenderFactory
		public function createRender():IDisplayRender {
			return cloneRender();
		}
		
		
		protected function createCloneChild(node:XMLNode, parent:DisplayObjectContainer):void {
			while (node) {
				var disp:DisplayObject = reRenderNode(node);
				if (disp != null) {
					
					parent.addChild(disp);
				}
				
				var cont:DisplayObjectContainer = disp as DisplayObjectContainer;
				if (cont != null)  {
					if ( !isTerminalNode(node) ) createCloneChild(node.firstChild, cont);
				}
				
				node = node.nextSibling;
			}
		}
		
		
		
		protected function reRenderNode(node:XMLNode):DisplayObject {
			
			var attrib:Object = node.attributes;
			
			
			if (!attrib.rendered) return null;
			
			if (attrib.id) _curClone.idMap[attrib.id] = node;
			
			var obj:Object = new attrib.renderedClass();//new (definitionGetter.getDefinition(node.nodeName))();
			
			//var disp:DisplayObject = obj as DisplayObject;
			var hash:Object;
			

			var i:String;
			hash = attrib.cachedFormatProps;
			if (hash) {
				var txtField:TextField = findTextField(obj);
				
				var txtFormat:TextFormat = new TextFormat();
				for (i in hash) {
					txtFormat[i] =  hash[i];
				}
				
				GPropertyApplyerUtil.applyProperties( txtField, defaultTextFieldProps  );
				txtField.defaultTextFormat = txtFormat;
				
				txtField.text = String(node.firstChild.nodeValue);
			}
			
			
			hash = attrib.displayProps;
			if (hash) {
				for (i in hash) {
					
					obj[i]  = hash[i];  // to do, clone displayObject-typed values through Proxy hash getter
				}
			}
			
			// apply cached behaviours and props
			hash = attrib.behaviours;
			if (hash) {
				var arrBeh:Array = attrib.behaviours;
				var arr2Beh:Array = attrib.behaviourProps;
				var count:int = 0;
				var len:int = arrBeh.length;
				while (count < len) {
					var beh:IBehaviour = behaviours.getBehaviour( arrBeh[count] );
					var behProps:Object = arr2Beh[count];
					for ( var u:String in behProps) {
						beh[u] = behProps[u]; 
					}
					if (obj is IBehaviouralBase) (obj as IBehaviouralBase).addBehaviour(beh)
					else if (forceAddBehaviours) {
						beh.activate(obj);
						attrib.destroyBehaviours[count] = beh;
					}
					count++;
				}
					
					
				
			}
			
			attrib.rendered = obj;
			
			return obj as DisplayObject;
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
			if (_parsed) return;
			super.parseXML(source);
			
			if (_rootNode == null) return;
			
			var attrib:Object = _rootNode.attributes;
			var restoreProps:Object = { };
			//.... TODO: introspect and get all necessary read/write properties, 
			//  and set them to restorePRops based on current rendered instance.
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
			//else {
			//	_isCloned = true;
		//	}
		}
	
		
		// Overwritten helpers
		
		protected var _curBehNode:XMLNode;
		
		override protected function injectDisplayBehaviours(disp:DisplayObject, props:Object, node:XMLNode):Array {
			_curBehNode = node;
			var arr:Array = super.injectDisplayBehaviours(disp, props, node);
			if (arr!=null) node.attributes.behaviours = arr;
			_curBehNode = null;
			return arr;
		}

		
		override protected function injectTextFieldProps(disp:DisplayObject, props:Object, node:XMLNode):Object {
			var cachedProps:Object = super.injectTextFieldProps(disp, props, node);
			if (cachedProps != null) node.attributes.cachedFormatProps = cachedProps;
			return cachedProps;
		}
		
		override protected function injectDisplayProps(disp:DisplayObject, props:Object, node:XMLNode):Object {
			var cachedProps:Object = super.injectDisplayProps(disp, props, node);
			if (cachedProps != null)  node.attributes.displayProps = cachedProps;
			node.attributes.renderedClass = Object(disp).constructor;
			return cachedProps;
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
			_curBehNode = null;
		}
		
		
	}

}