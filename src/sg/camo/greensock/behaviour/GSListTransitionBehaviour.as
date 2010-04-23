package sg.camo.greensock.behaviour 
{
	import camo.core.events.CamoChildEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import sg.camo.greensock.GSPluginVars;
	import sg.camo.greensock.transitions.GSListTransition;
	import sg.camo.greensock.transitions.GSTransition;
	import sg.camo.greensock.EasingMethods;
	import sg.camo.interfaces.IAncestorSprite;
	

	/**
	 * Default hardcoded GSListTransition instance that runs a over a targetted object through this behaviour.
	 * @author Glenn Ko
	 */
	
	[Inject]
	public class GSListTransitionBehaviour extends GSTransitionBehaviour
	{
		
		public static const NAME:String = "GSListTransitionBehaviour";
		
		// Constructor paramteters	
		public var timelineClass:Class;
		public var listenAdd:String
		public var listenRemove:String;
		
		public var scanListItems:Boolean = false;  
		public var useAncestor:Boolean = true;  // whether to use ancestor depth level when scanning list items
		
		protected var _myListTransition:GSListTransition;
		

		
		public function GSListTransitionBehaviour(pluginVars:GSPluginVars=null) 
		{
			super(pluginVars);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override protected function postActivate():void {
			if (scanListItems) {
				var cont:DisplayObjectContainer = targDispatcher as DisplayObjectContainer; // assume available

				var ancSprite:IAncestorSprite =  useAncestor ? cont as IAncestorSprite : null;
				var len:int = ancSprite ? ancSprite.$numChildren : cont.numChildren;
				var getChildMethod:Function = ancSprite ? ancSprite.$getChildAt : cont.getChildAt;
			
				var listenAdd:String = _myListTransition.listenAdd;
				for (var i:int = 0; i < len; i++) {
					targDispatcher.dispatchEvent( new CamoChildEvent(listenAdd, getChildMethod(i) ) );
				}
			}
			if (renderNow) targDispatcher.dispatchEvent( new Event(eventIn) );
		}
		
		override protected function createGSTransition():GSTransition {
			_myListTransition = new GSListTransition(targDispatcher, tweenClass, gsPluginVars, listenAdd, listenRemove, timelineClass);
			return _myListTransition;
		}

		// Proxy Boiler-plate....GRRRR.... need Proxy property application system.
		public function set forEachEase(str:String):void {
			propMap['forEachEase'] = EasingMethods.getEasingMethod(str);
		}
		
		public function set forEachEaseIn(str:String):void  {
			propMap['forEachEaseIn'] = EasingMethods.getEasingMethod(str);
		}
		public function set forEachEaseOut(str:String):void  {
			propMap['forEachEaseOut'] = EasingMethods.getEasingMethod(str);
		}
		
		
		public function set forEachDuration(val:Number):void {
			propMap['forEachDuration'] = val;
		}
		public function set stagger(val:Number):void  {
			propMap['stagger'] = val;
		}
		
		
		public function set containerFirst(val:Boolean):void {
			propMap['containerFirst'] = val;
		}
		
		public function set forEachInVars(val:Object):void {
			propMap['forEachInVars'] = val;
		}
		public function set forEachFromVars(val:Object):void {
			propMap['forEachFromVars'] = val;
		}
		
		
		
	}

}