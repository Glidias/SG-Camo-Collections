package sg.camogxml.render 
{
	import flash.display.DisplayObject;
	import flash.xml.XMLNode;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.ISelectorSource;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	
	[Inject(name = 'gxml', name = 'gxml', name = 'gxml', name = 'gxml', name = '', name = 'textStyle', name="gxmlPopulate")]	
	public class GXMLRenderPopulator extends GXMLPageRender
	{
		protected var _referRender:IDisplayRender;
		
		public function GXMLRenderPopulator(definitionGetter:IDefinitionGetter, behaviours:IBehaviouralBase, stylesheet:ISelectorSource, dispRenderSrc:IDisplayRenderSource, propApplier:IPropertyApplier, textPropApplier:IPropertyApplier, referRender:IDisplayRender) 
		{
			super(definitionGetter, behaviours, dispRenderSrc, stylesheet, propApplier, textPropApplier);
			_referRender = referRender;

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
			if (node === _rootNode) return new SpriteDummy();
			else {
				var rendered:DisplayObject = _referRender.getRenderedById(node.nodeName) || super.getRenderedItem(node, isTxtNode);
				attribPropApplier.applyProperties(rendered, node.attributes);  // only apply attributes
			}
			
			return rendered;
		}
		

	}

}
import flash.display.DisplayObject;
import flash.display.Sprite;

internal class SpriteDummy extends Sprite {
	
	public function SpriteDummy() {
		
	}
	
	override public function addChild(child:DisplayObject):DisplayObject {
		return child;
	}
	override public function removeChild(child:DisplayObject):DisplayObject {
		return child;
	}
	
}