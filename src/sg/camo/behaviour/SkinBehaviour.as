package sg.camo.behaviour {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.interfaces.IAncestorSprite;
	import camo.core.events.CamoDisplayEvent;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IResizable;
	
	/**
	* Sets up a target "skin" DisplayObject to resize together with it's target DisplayObjectContainer.
	* <br/><br/>
	* In order for the skin to resize together with it's targetted container, the targetted DisplayObjectContainer
	* must dispatch a CamoDisplayEvent.DRAW event to notify the SkinBehaviour of any size changes. (This should also
	* happen when the container gets added to the stage as well). The skin than resizes to fit the targetted DisplayObjectContainer
	* by reading off the container's width and height directly.
	* <br/><br/>
	* By default, <code>camo.core.display.AbstractDisplay</code> already dispatches CamoDisplay.DRAW events during content updates,
	* so classes extending from AbstractDisplay will have no problems using this behaviour.
	* <br/><br/>
	* If the DisplayObject skin happens to adopt the <code>IResizable</code> interface, the <code>resize()</code> 
	* method of that interface is used to resize that skin rather than it's regular width/height setters.
	* 
	* @see camo.core.events.CamoDisplayEvent
	* @see camo.core.display.AbstractDisplay
	* @see sg.camo.interfaces.IResizable
	* 
	* @author Glenn Ko
	*/
	public class SkinBehaviour implements IBehaviour {
		
		public static const NAME:String = "SkinBehaviour";
		
		/** @private */  
		protected var _skin:DisplayObject;
		/** @private */  
		protected var _resizable:IResizable;	// cached resizable interface reference for skin (if available)
		/** @private */ 
		protected var _disp:DisplayObjectContainer;
		
		/**  Default <code>addChild</code> depth to use if skin has no parent 
		 *  Set this to lower than zero if you do not wish to for the skin to be reparented in such a case. 
		 * Set this higher than zero to inject skin at the topmost layer. 
		 * */
		public var injectedSkinDepth:Number = 0;
		
		/**
		 * Constructor
		 * @param	skin	(DisplayObject) Sets skin by constructor parameter (required to set before activation ).
		 */
		public function SkinBehaviour(skin:DisplayObject = null ) {
			_skin = skin;
		}
		
		/**
		 * Sets skin manually by setter (required to set before activation )
		 */
		public function set skin(disp:DisplayObject):void {
			setSkin(skin);
			
		}
		public function get skin():DisplayObject {
			return _skin;
		}
		
		/** @private */
		protected function setSkin(skin:DisplayObject):void {
			if (skin == null) {
				return;
			}
			_skin = skin;
			
			if (_disp == null) return;
			if (skin.parent != null) return;
			if (injectedSkinDepth < 0) return;
			var prop:int =  _disp is IAncestorSprite ? (_disp as IAncestorSprite).$numChildren : _disp.numChildren;
			var targDepth:int = injectedSkinDepth > 0 ? prop - 1 : 0;
			var func:Function = _disp is IAncestorSprite ? (_disp as IAncestorSprite).$addChildAt : _disp.addChildAt;
			func(skin, targDepth );	
			return;
		}
		
		/**
		 * 
		 * @param	targ	The target DisplayObjectContainer to listen for CamoDisplayEvent.DRAW events to perform resizing.
		 */
		public function activate(targ:*):void {
			_disp = (targ as DisplayObjectContainer);
			if (_disp == null) {
				throw( new Error("SkinBehaviour activate() halt. targ as DisplayObjectContainer is null!") );
				return;
			}
			_skin = _skin != null ? _skin : _disp is IAncestorSprite ? (_disp as IAncestorSprite).$getChildByName("skin") : _disp.getChildByName("skin");
			setSkin(_skin);
			AncestorListener.addEventListenerOf(_disp, CamoDisplayEvent.DRAW, drawHandler,0);
		}
		
		/**
		 * Resizes skin to fit container
		 * @param	e
		 */
		protected function drawHandler(e:Event):void {
			if (_resizable) {
				_resizable.resize(_disp.width, _disp.height);
				return;
			}
			// else use regular width/height setters for skin
			_skin.width = _disp.width;
			_skin.height = _disp.height;	
		}
		
		/**
		 * Disposes both behaviour and skin.
		 */
		public function destroy():void {
			if (_disp) AncestorListener.removeEventListenerOf(_disp, CamoDisplayEvent.DRAW, drawHandler);
			_disp = null;
			if (_skin is IDestroyable) (_skin as IDestroyable).destroy();
			_skin = null;
			_resizable = null;
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
	}
	
}