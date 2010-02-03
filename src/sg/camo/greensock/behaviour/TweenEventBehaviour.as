package sg.camo.greensock.behaviour 
{
	import com.greensock.TweenLite;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.greensock.EasingMethods;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TweenEventBehaviour implements IBehaviour
	{
		
		public static const NAME:String = "TweenEventBehaviour";
		public var duration:Number = .6;
		
		//public var toTimeScale:Number = 1;
		//public var fromTimeScale:Number = -1;
		protected var _fromVars:Object;
		public function set fromVars(vars:Object):void {
			_fromVars = createVarsFromObj(vars);
		}
		protected var _toVars:Object;
		public function set toVars(vars:Object):void {
			_toVars = createVarsFromObj(vars);
		}
		
		// Whether to perform restore tween/action upon destroy()
		public var restoreDuration:Number = 0;
		protected var _restoreVars:Object;
		public function set restoreVars(vars:Object):void {
			_restoreVars = createVarsFromObj(vars);
		}
		
		// Event info and easing
		public var eventTo:String = MouseEvent.ROLL_OVER;
		public var eventReturn:String = MouseEvent.ROLL_OUT;
		public var easeTo:Function = null;
		public var easeReturn:Function = null;
		public function set ease(func:Function):void {
			easeTo = func;
			easeReturn = func;
		}
	
		
		private var _tweenLite:TweenLite;
		private var _targDispatcher:IEventDispatcher;
		
		
		public function TweenEventBehaviour() 
		{
			
		}
		
		
		public function get behaviourName():String {
			return NAME;
		}
		
		
		
		public function activate(targ:*):void {
			if (_fromVars == null || _toVars == null) {
				throw new Error("TweenEventBehaviour activate() failed! No from/to variables specified");
				return;
			}
			TweenLite.to(targ, .1, _fromVars ).complete();
			_tweenLite = TweenLite.to(targ, duration, _toVars );
			_tweenLite.pause();
			
			var evDisp:IEventDispatcher = targ as IEventDispatcher;
			AncestorListener.addEventListenerOf(evDisp, eventTo, tweenToHandler);
			AncestorListener.addEventListenerOf(evDisp, eventReturn, tweenBackHandler);
			_targDispatcher = evDisp;
		}
		
		/**
		 * Note: Only supports processing to ease and numeric values from strings
		 * @param	obj		Object of string values to convert
		 * @return
		 */
		public static function createVarsFromObj(obj:Object):Object {
			var retObj:Object = { };
			for (var i:String in obj) {
				var val:String = obj[i];
				retObj[i]  = i != "ease" ? val.charAt(0) != "!" ? Number(val) : strToObj(val.substr(1)) : EasingMethods.getEasingMethod(val);
			}
			return retObj;
		}
		
		public static function strToObj(data:String, dataDelimiter : String = "|" ,propDelimiter : String = "@"):Object {
			var dataContainer:Object = { };
			var list : Array = data.split( dataDelimiter );
			var total : Number = list.length;

			for (var i : Number = 0; i < total ; i ++) 
			{
				var prop : Array = list[i].split( propDelimiter );
				dataContainer[prop[0]] = Number( prop[1] );
			}
			
			return dataContainer;
		}
		
		protected function tweenToHandler(e:Event):void {
		
			_tweenLite.restart();
		}
		
		protected function tweenBackHandler(e:Event):void {
			_tweenLite.reverse();
		}
		
		public function destroy():void {
			if (_targDispatcher == null) return;

			AncestorListener.removeEventListenerOf(_targDispatcher, eventTo, tweenToHandler);
			AncestorListener.removeEventListenerOf(_targDispatcher, eventReturn, tweenBackHandler);
			if (_restoreVars) {
				if (restoreDuration == 0)  TweenLite.to(_targDispatcher, .1, _restoreVars ).complete();
				else TweenLite.to(_targDispatcher, restoreDuration, _restoreVars );
				
			}
		}
		
	}

}