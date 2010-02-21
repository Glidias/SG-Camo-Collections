package sg.camogxml.render 
{
	import flash.display.DisplayObject;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IRenderFactory;
	import sg.camo.interfaces.IRenderPool;
	import sg.camogxml.api.IGXMLRender;
	/**
	 * A GXML render  packet wrapper class under an IDisplayRender interface to support deferred 
	 * markup rendering. 
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLRenderPacket implements IDisplayRender, IDestroyable, IRenderPool, IRenderFactory
	{
		public var gxmlRender:IGXMLRender;
		protected var _xml:XML;
		protected var _renderId:String;
		
		public function GXMLRenderPacket(gxmlRender:IGXMLRender, xml:XML) 
		{
			this.gxmlRender = gxmlRender;
			_xml = xml;
			_renderId =  xml.@renderId || xml.name();  // follow conventions of GXMLRender base class
		}
		
		
		// -- IRenderPool signature
		public function get object():IDisplayRender {
			if (!gxmlRender.rendered) gxmlRender.renderGXML(_xml);
			return gxmlRender is IRenderPool ? (gxmlRender as IRenderPool).object : (gxmlRender is IRenderFactory) ? (gxmlRender as IRenderFactory).createRender() : gxmlRender;
		}
		// -- IRenderFactory signature
		public function createRender():IDisplayRender {
			return object;
		}

		
		protected function get instantiateRendered():DisplayObject {
			gxmlRender.renderGXML(_xml);
			return gxmlRender.rendered;
		}
		

		/**  render ID for registering with asset managers. */
		public function get renderId():String {
			return _renderId;
		}
		
		/** the current main display object instance */
		public function get rendered():DisplayObject {
			return gxmlRender.rendered ||  instantiateRendered;
		}
		
		/** retrieves any related/nested display object instance */
		public function getRenderedById(id:String):DisplayObject {
			if (!gxmlRender.rendered) gxmlRender.renderGXML(_xml);
			return gxmlRender.getRenderedById(id);
		}
		
	
		public function restore(changedHash:Object = null):void {
			if (!gxmlRender.rendered) gxmlRender.renderGXML(_xml);
			gxmlRender.restore();
		}
	
		public function set isActive(boo:Boolean):void {
			gxmlRender.isActive = boo;
		}
		public function get isActive():Boolean {
			return gxmlRender.isActive;
		}
		
		public function destroy():void {
			if (gxmlRender is IDestroyable) (gxmlRender as IDestroyable).destroy();
		}
		
	}

}