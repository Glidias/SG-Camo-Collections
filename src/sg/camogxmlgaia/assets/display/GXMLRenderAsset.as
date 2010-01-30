package sg.camogxmlgaia.assets.display 
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.XMLAsset;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IRecursableDestroyable;
	import sg.camogxml.api.IGXMLRender;
	import sg.camogxmlgaia.api.IDisplayRenderAsset;
	import sg.camogxmlgaia.api.IGXMLAsset;
	import sg.camogxmlgaia.api.INodeClassAsset;
	import sg.camogxmlgaia.api.INodeClassSpawner;
	/**
	 * Parses GXMLRender under the CGG framework.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLRenderAsset extends XMLAsset implements IDisplayRenderAsset, IGXMLAsset, INodeClassAsset
	{
		/** @private */
		protected var _gxmlRender:IGXMLRender;
		
		public function GXMLRenderAsset() 
		{
			super();
		
		}
		public function renderGXML():void {
			if (_gxmlRender != null) _gxmlRender.renderGXML(xml);
		}
		
		public function spawnClass(spawner:INodeClassSpawner):* {
			_gxmlRender = spawner.parseNode( node, node.@type.toString() ) as IGXMLRender;
			return _gxmlRender;
		}

		public function get displayRender():IDisplayRender {
			return _gxmlRender;
		}
		
		override public function toString():String
		{
			return "[GXMLRenderAsset] " + _id + " : " + _order + " ";
		}
		
		override public function destroy():void {
			super.destroy();
			if (_gxmlRender == null) return;
			
			if (_gxmlRender.rendered) {
				if (_gxmlRender.rendered.parent) {
					_gxmlRender.rendered.parent.removeChild(_gxmlRender.rendered);
				}
			}
			
			if (_gxmlRender is IRecursableDestroyable) (_gxmlRender as IRecursableDestroyable).destroyRecurse(true)
			else if (_gxmlRender is IDestroyable) (_gxmlRender as IDestroyable).destroy();
		}
	
		
	}

}