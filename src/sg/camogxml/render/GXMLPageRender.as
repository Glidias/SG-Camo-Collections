package sg.camogxml.render 
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.IRenderPool;
	import sg.camo.interfaces.ISelectorSource;
	/**
	 * Renders a page layout by also using existing modules/IDisplayRenders.
	 * 
	 * Also acts as a IDisplayRenderSource within a page context.
	 * 
	 * @see sg.camo.interfaces.IDisplayRenderSource
	 * @see sg.camo.interfaces.IRenderPool
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject(name='gxml',name='gxml',name='gxml',name='gxml',name='',name='textStyle')]
	public class GXMLPageRender extends GXMLRender implements IDisplayRenderSource
	{
		protected var displayRenderSrc:IDisplayRenderSource;
		protected var localHash:Dictionary = new Dictionary();
		
		/**
		 * 
		 * @param	definitionGetter
		 * @param	stylesheet
		 * @param	behaviours
		 * @param	displayRenderSrc
		 */
		public function GXMLPageRender(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, displayRenderSrc:IDisplayRenderSource, stylesheet:ISelectorSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier) 
		{
			super(definitionGetter, behaviours, stylesheet, propApplier, textPropApplier);	
			this.displayRenderSrc = displayRenderSrc;
		}
		

		
		/**
		 * Retrieves an IDisplayRender module from it's own local hash if possible, otherwise refers to the 
		 * main supplied <code>displayRenderSrc</code> in constructor.
		 * @param	id
		 * @return
		 */
		public function getRenderById(id:String):IDisplayRender {
			return localHash[id] ? localHash[id] : displayRenderSrc.getRenderById(id);
		}
		
		/**
		 * Also sets isActive values for all rendered IDIsplayRender  instances.
		 * */
		override public function set isActive(boo:Boolean):void {
			super.isActive = boo;
			for (var i:* in localHash) {
				localHash[i].isActive = boo;
			}
		}
		
		public function getDisplayRenders():Array {
			var arr:Array = [];
			for (var i:* in localHash) {
				arr.push( localHash[i] );
			}
			return arr;
		}
		

		
		/**
		 * Attempts to retreive available IDisplayRender instance from IDisplayRenderSource by xml node name. If the IDisplayRender instance
		 * happens to be marked as an IRenderPool/IRenderFactory, it'll attempt to draw out another IDisplayRender from the  pooling method defined 
		 * by that IDisplayRender class. The resultant IDIsplayRender (if any) is registered into it's local hash of IDisplayRender instances.
		 * 
		 * @param	node		The xml node being parsed
		 * @param	isTxtNode  Whether node is a text-based node (containing text nodeValue or CDATA)
		 * @return
		 */
		override protected function getRenderedItem(node:XMLNode, isTxtNode:Boolean):* {
			var tryRender:IDisplayRender = displayRenderSrc.getRenderById(node.nodeName);
			if (tryRender is IRenderPool) tryRender = (tryRender as IRenderPool).object
			else if (tryRender is IRenderFactory) tryRender = (tryRender as IRenderFactory).createRender();

			if (tryRender !=null) {
				localHash[tryRender.renderId] = tryRender;
				//if (node.attributes.id) localHash[node.attributes.id] = tryRender;
				var render:DisplayObject = tryRender.rendered; 
				
				attribPropApplier.applyProperties(render, node.attributes);  // only apply attributes
				
				node.attributes.iRenderDestroy  = tryRender as IDestroyable;
				
				
			}
			

			return render || super.getRenderedItem(node, isTxtNode);
		}
		
		override protected function destroyDisplay(disp:DisplayObject, attrib:Object):void {
			if (attrib.iRenderDestroy) {
				attrib.iRenderDestroy.destroy();
				
			}
			else super.destroyDisplay(disp, attrib);
		}
		
		
		override protected function injectDisplayBehaviours(disp:DisplayObject, props:Object, node:XMLNode):Array {
			return disp is IDisplayRenderSource ?  null : super.injectDisplayBehaviours(disp, props, node);
		}

		
		override protected function injectTextFieldProps(disp:DisplayObject, props:Object, node:XMLNode):Object {
			if (disp is IDisplayRenderSource) return null;
			return super.injectTextFieldProps(disp, props, node);
		}
		
		override protected function injectDisplayProps(disp:DisplayObject, props:Object, node:XMLNode):void {
			if (disp is IDisplayRenderSource) return;
			
			super.injectDisplayProps(disp, props, node);
			
		}
		
	}

}