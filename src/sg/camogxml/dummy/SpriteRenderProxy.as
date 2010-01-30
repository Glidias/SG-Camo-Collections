package sg.camogxml.dummy 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.ancestor.AncestorChild;
	/**
	 * Dummy IDisplayRender implementation for DisplayObjectContainers.
	 * @author Glenn Ko
	 */
	public class SpriteRenderProxy extends DisplayObjectRenderProxy
	{
		
		/** @private */
		protected var _spr:DisplayObjectContainer;
		
		/**
		 * Constructor
		 * @param	renderId	The renderId to assosiate with the IDisplayRender
		 * @param	spr			The main DisplayObjectContainer reference
		 */
		public function SpriteRenderProxy(renderId:String, spr:DisplayObjectContainer) 
		{
			super(renderId, spr);
			_spr = spr;
			_renderId = renderId;
		}

		/**
		 *  Uses DisplayObjectContainer's getChildByName(id) for the IDisplayRender's getRenderedById(id) implementation.
		 * @param	id		The name of the child instance within the DisplayObjectContainer
		 * @return	A child DisplayObject (if available)
		 */
		override public function getRenderedById(id:String):DisplayObject {
			return AncestorChild.getChildByNameOf(_spr, id);
		}
			
	}

}