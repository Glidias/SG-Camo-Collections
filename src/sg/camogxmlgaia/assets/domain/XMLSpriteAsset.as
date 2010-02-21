package sg.camogxmlgaia.assets.domain 
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.SpriteAsset;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * Base SpriteAsset class that can load an additional accompanying xml file.
	 * @author Glenn Ko
	 */
	public class XMLSpriteAsset extends SpriteAsset
	{
		
		protected var xmlLoader:URLLoader;
		protected var _xml:XML;
		
		public function XMLSpriteAsset() 
		{
			
		}	
		
		override public function parseNode(page:IPageAsset):void {
			super.parseNode(page);
			if (_node.@xml != undefined) {
				xmlLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, onXMLComplete, false , 0, true);
			}
		}
		
		protected function onXMLComplete(e:Event):void {
			xmlLoader.removeEventListener(Event.COMPLETE, onXMLComplete);
			_xml = XML(xmlLoader.data);
			xmlLoader = null;
			
		}
		
		override public function destroy():void {
			if (xmlLoader != null) {
				xmlLoader.removeEventListener(Event.COMPLETE, onXMLComplete);
				xmlLoader = null;
			}
			super.destroy();
		}
		
		override public function preload():void {
			super.preload();
			if (xmlLoader ) xmlLoader.load( new URLRequest(_node.@xml) );
		}
		
		
		private var _savedCompleteEvent:Event;
		override protected function onComplete(e:Event):void {
			if (!xmlLoader) {
				super.onComplete(e);
				doComplete();
			}
			else {
				_savedCompleteEvent = e;
				xmlLoader.addEventListener(Event.COMPLETE, finishComplete, false, 1, true);
			}
		}
		
		protected function finishComplete(e:Event):void {
			e.stopImmediatePropagation();
			e.currentTarget.removeEventListener(Event.COMPLETE, finishComplete);
			_xml = XML(e.target.data);
			xmlLoader = null;
			
			super.onComplete(_savedCompleteEvent);
			doComplete();
			_savedCompleteEvent = null;
		}
		
		protected function doComplete():void {
			// to override in extended classes
		}
		
	}

}