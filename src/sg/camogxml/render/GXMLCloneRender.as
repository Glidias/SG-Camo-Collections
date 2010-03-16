package sg.camogxml.render
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.ISelectorSource;
	
	/**
	 * A clonable GXML render for replicating copies of itself en-masse. 
	 * 
	 * @author Glenn Ko
	 */
	
	 [Inject(name='gxml',name='gxml',name='gxml',name='',name='textStyle')]
	public class GXMLCloneRender extends GXMLRender implements IRenderFactory
	{
		
		protected var _isCloned:Boolean = false;
		
		public function GXMLCloneRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier)
		{
			super(definitionGetter, behaviours, stylesheet, propApplier, textPropApplier );
		}
		
		internal function set isCloned(boo:Boolean):void {
			_isCloned = boo;
		}
	
		protected var _curClone:GXMLCloneRender;
		
		protected function get cloneInstance():GXMLCloneRender {
			return new GXMLCloneRender(definitionGetter, behaviours, stylesheet, null, null);
		}
		
		protected function cloneRender():GXMLCloneRender {
			var clone:GXMLCloneRender = cloneInstance;
			
			clone.dispPropApplier = dispPropApplier;
			clone.behPropApplier = behPropApplier;
			clone.textPropApplier = textPropApplier;
		
			clone.isCloned = true;
		
			_curClone = clone;
			clone.idMap = { }; 
			var clonedRoot:XMLNode = _rootNode.cloneNode(true);
			var disp:DisplayObject = reRenderNode(clonedRoot);

			if ( disp is DisplayObjectContainer && !isTerminalNode(clonedRoot) ) createCloneChild(clonedRoot.firstChild, disp as DisplayObjectContainer);
			clone.firstChild = clonedRoot;
			clone.rendered = disp;
			_curClone = null;
			
			return clone;
		}
		
		public function set rendered(val:DisplayObject):void {
			_rendered = val;
		}
		
		override public function get rendered():DisplayObject {
			return _isCloned ? super.rendered :  _rootNode ?  createRender().rendered : null;
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
		
		
		override protected function applyBehaviourProperties(beh:IBehaviour, behLookupName:String, node:XMLNode, pseudoNamespace:String=null, pseudoState:String=null):Object {
			var behProps:Object = super.applyBehaviourProperties(beh, behLookupName, node, pseudoNamespace, pseudoState);
			var attrib:Object = node.attributes;
			var arr:Array = attrib.behaviourProps as Array || (attrib.behaviourProps = []);		
			
			
			arr.push(behProps);
			
			return behProps;
		}
		
		
		protected function reRenderNode(node:XMLNode):DisplayObject {
			
			var attrib:Object = node.attributes;
			
			
			if (!attrib.rendered) return null;
			
			if (attrib.id) _curClone.idMap[attrib.id] = node;
			
			var obj:Object = new attrib.renderedClass();//new (definitionGetter.getDefinition(node.nodeName))();
			
			var i:String;
			
			dispPropApplier.applyProperties( obj, attrib.cachedDisplayProps )
			attribPropApplier.applyProperties( obj, attrib.cachedAttributes);
			
			
			if (attrib.cachedTextProps) 	{
				var txtField:TextField = findTextField(obj);
				textPropApplier.applyProperties( txtField, attrib.cachedTextProps  );
				if (node.firstChild && node.firstChild.nodeValue) {
					txtField.text = node.firstChild.nodeValue;
				}
			}
			

			
			
			// apply cached behaviours and props

			if (attrib.behaviours) {
				
				var arrBeh:Array = attrib.behaviours;
				var arr2Beh:Array = attrib.behaviourProps;
				var count:int = 0;
				var len:int = arrBeh.length;
				while (count < len) {
					var beh:IBehaviour = behaviours.getBehaviour( arrBeh[count] );
					var behProps:Object = arr2Beh[count];
					behPropApplier.applyProperties(beh, behProps);
					if (obj is IBehaviouralBase) (obj as IBehaviouralBase).addBehaviour(beh)
					else  {
						beh.activate(obj);
						_behCache[beh] = true;
						
					}
					count++;
				}
					
					
				
			}
			
			attrib.rendered = obj;
			
			return obj as DisplayObject;
		}

		override public function parseXML(source:String):void {
			if (_parsed) return;
			super.parseXML(source);
		}
	
		
		// Overwritten helpers
		

		override protected function injectDisplayBehaviours(disp:DisplayObject, props:Object, node:XMLNode):Array {
	
			var arr:Array = super.injectDisplayBehaviours(disp, props, node);
			if (arr!=null) node.attributes.behaviours = arr;
			return arr;
		}

		
		override protected function injectTextFieldProps(disp:DisplayObject, props:Object, node:XMLNode):Object {
			var props:Object = super.injectTextFieldProps(disp, props, node);
			if (props) node.attributes.cachedTextProps = props;
			return props;
			
		}
		
		override protected function injectDisplayProps(disp:DisplayObject, props:Object, node:XMLNode):void {
			super.injectDisplayProps(disp, props, node);
			node.attributes.cachedDisplayProps = props;
			node.attributes.cachedAttributes = _curInlineAttributes;
			for (var i:String in _curInlineAttributes) {
				node.attributes.cachedDisplayProps[i] = _curInlineAttributes[i]
				
			}
		
			node.attributes.renderedClass = Object(disp).constructor;
		}
		
		// Overwritten destructors
		
		/**
		 * 
		 * @param	boo
		 */
		override public function destroyRecurse(boo:Boolean=false):void {
			super.destroyRecurse(boo);
		}
		
		
	}

}