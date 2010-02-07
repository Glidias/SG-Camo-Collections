package sg.camo.behaviour {
	import flash.display.Sprite;
	import flash.net.URLRequest;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	import flash.net.navigateToURL;
	
	/**
	* Hooks up DisplayObject with buttonMode behaviour to also dispatch a TextEvent.LINK bubbling event upon click.
	* @author Glenn Ko
	*/
	public class HrefBehaviour implements IBehaviour {
		
		/**  Determines "text" value to send in TextEvent.LINK during a  click */
		public var href:String;
		
		/** @private */
		protected var _targDispatcher:IEventDispatcher;
		
		public static const NAME:String = "HrefBehaviour";
		
		public var navigateNow:Boolean = false;
		public var window:String = "_blank";
		
		/**
		 * Constructor
		 * @param	$href	Supply a value for the "text" property of TextEvent.LINK being sent.
		 */
		public function HrefBehaviour($href:String="") {
			href = $href;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates DisplayObject.
		 * @param	targ	(DisplayObject) A valid DisplayObject instance
		 */
		public function activate(targ:*):void {
			_targDispatcher = (targ as IEventDispatcher);
		
			if (_targDispatcher == null) {
				trace("HrefBehaviour activate() halt. targ as IEventDispatcher is null!");
				return;
			}
			var spr:Sprite = _targDispatcher as Sprite;
			if (spr != null) {
				spr.buttonMode = true;
				spr.mouseChildren = false;
			}
			
			
			if (!navigateNow) navigateNow = href.substr(0, 7) === "http://" || href.substr(0, 9) === "mailto://";
			
			_targDispatcher.addEventListener(MouseEvent.CLICK, hrefHandler, false , 0, true);
			
		}
		
		/**
		 * Dispatches TextEvent.LINK upon click
		 * @param	e	
		 */
		protected function hrefHandler(e:Event):void {
			if (navigateNow) {
				navigateToURL( new URLRequest(href), window );
				return;
			}
			_targDispatcher.dispatchEvent( new TextEvent(TextEvent.LINK, true, false, href) );
		}
		
		public function destroy():void {
			_targDispatcher.removeEventListener(MouseEvent.CLICK, hrefHandler);
			_targDispatcher = null;
		}
		
		
		
	}
	
}