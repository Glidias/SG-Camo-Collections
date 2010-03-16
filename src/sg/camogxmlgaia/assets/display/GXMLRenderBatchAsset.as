package sg.camogxmlgaia.assets.display 
{
	import com.gaiaframework.assets.XMLAsset;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camo.interfaces.IRecursableDestroyable;
	import sg.camogxml.api.IGXMLRender;
	import sg.camogxmlgaia.api.IDisplayRenderAsset;
	import sg.camogxmlgaia.api.IGXMLAsset;
	import sg.camogxmlgaia.api.INodeClassAsset;
	import sg.camo.interfaces.INodeClassSpawner;
	import sg.camogxmlgaia.api.ISourceAsset;
	
	import sg.camogxml.render.GXMLRenderPacket;
	
	/**
	 * A DisplayRenderSource asset that manages multiple GXML render batches in 
	 * one XML file with deferred rendering support (only rendering the gxml once requested via
	 * getRenderById() ).
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLRenderBatchAsset extends XMLAsset implements IDisplayRenderSource, ISourceAsset , INodeClassAsset
	{
		/**
		 * Dictionary of GXMLRenderPackets by id.
		 */
		private var _myGXMLRenders:Dictionary
		
		/**
		 * Payload array
		 */
		private var _payload:Array;
		
		
		public function GXMLRenderBatchAsset() 
		{
			super();
		}
		
		override public function init():void {
			super.init();
			_myGXMLRenders = new Dictionary();
		}

		public function getRenderById(id:String):IDisplayRender {
			return _myGXMLRenders[id];
		}
		
		/**
		 * The payload of display renders that could be registered externally
		 * @return
		 */
		public function getDisplayRenders():Array {
			return _payload;
		}
		

		public function get sourceType():String {
			return "render";
		}
		
		public function get source():* {
			return this;
		}
		
		/**
		 * Insantiates multiple GXML renders through NodeClassSpawner
		 * @param	spawner
		 * @return
		 */
		public function spawnClass(spawner:INodeClassSpawner):* {
			
			var xmlRenders:XML = xml;
			
			
			var xmlList:XMLList = xml.*;
			var len:int = xmlList.length();
			_payload = new Array(len);
			for (var i:int = 0; i < len; i++) {
				var node:XML = xmlList[i];
				var gxmlRender:IGXMLRender = spawner.parseNode( node, "gxml" ) as IGXMLRender;
				var packet:GXMLRenderPacket = new GXMLRenderPacket(gxmlRender, node);
				_myGXMLRenders[packet.renderId] = packet;
				_payload[i] =   packet;
			
			}
	
			
			return null;
		}


		
		override public function toString():String
		{
			return "[GXMLRenderBatchAsset] " + _id + " : " + _order + " ";
		}
		
		override public function destroy():void {
			super.destroy();
			for (var i:* in _myGXMLRenders) {
				destroyGXMLRender(_myGXMLRenders[i].gxmlRender);
			}
			_myGXMLRenders = null;
			_payload = null;
		}
		
		protected function destroyGXMLRender(gxmlRender:IDisplayRender):void {
			if (gxmlRender.rendered) {
				if (gxmlRender.rendered.parent) {
					gxmlRender.rendered.parent.removeChild(gxmlRender.rendered);
				}
			}
			if (gxmlRender is IRecursableDestroyable) (gxmlRender as IRecursableDestroyable).destroyRecurse(true)
			else if (gxmlRender is IDestroyable) (gxmlRender as IDestroyable).destroy();
			
		}
		
	
		
	}

}