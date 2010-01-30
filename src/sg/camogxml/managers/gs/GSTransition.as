package sg.camogxml.managers.gs 
{
	import com.greensock.core.TweenCore;
	import com.greensock.TweenLite;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.ITransitionModule;
	import sg.camogxml.managers.gs.data.GSPluginVars;
	
	/**
	 * A GS tween transitioning scheme over a particular target object
	 * @author Glenn Ko
	 */
	public class GSTransition implements ITransitionModule, IDestroyable
	{
		protected var _target:Object;
		protected var _inVars:Object;
		protected var _outVars:Object;
		protected var _pluginVars:GSPluginVars;
		
		public var durationIn:Number = .3;
		public var durationOut:Number = .3;
		public var interruptReversible:Boolean = false;
		public var reverseOnOut:Boolean = false;
		
		public var easeIn:Function = null;
		public var easeOut:Function = null;
		
		protected var _curTween:TweenCore;
		protected var _tweenClass:Class;
		
		protected var _restoreVars:Object = { };
		
		/**
		 * Constructor
		 * @param	target		Required. The targetted instance.
		 * @param   tweenClass	The optional custom TweenCore class to use. (eg. TweenMax)
		 * @param	pluginVars	The set of GSPluginVars to allow for referencing. If left undefined, uses singleton reference of GSPluginVars. 
		 */
		public function GSTransition(target:Object, tweenClass:Class= null, pluginVars:GSPluginVars=null) 
		{
			_target = target;
			_pluginVars = pluginVars || GSPluginVars.getInstance();
			_tweenClass = tweenClass || TweenLite;
		}
		

		
		// -- ITransitionModule
		
		public function get transitionInPayload():* {
			if (checkIsReversible(_curTween)) return _curTween;
			_curTween =  _inVars ? _inVars as TweenCore || createTweenFromVars(_inVars, durationIn, easeIn) : null;
			return _curTween;
		}
		

		public function get transitionOutPayload():* {
			if (reverseOnOut) {
				_curTween.reverse();
				return _curTween;
			}
			if (checkIsReversible(_curTween)) return _curTween;
			_curTween =  _outVars ? createTweenFromVars(_outVars, durationOut, easeOut) : null;
			return _curTween;
		}
		
		public function get transitionType():* {
			return TweenCore;
		}
		
		// -- Protected helpers
		
		protected function createTweenFromVars(vars:Object, duration:Number, ease:Function):TweenCore {
			vars.ease = ease;
			return new _tweenClass(_target, duration, vars) as TweenCore;
		}
		
		protected function createVarsFromObject(obj:Object):Object {
			var retObj:Object = { };
			for (var i:String in obj) {
				if (TweenLite.plugins[i]) {
					retObj[i] = obj[i] is String ? _pluginVars.getPropertyValue(i, obj[i]) : obj[i];
					continue;
				}
				var wildCard:Boolean = i.charAt(0) === "*";
				var prop:String = wildCard ? i.substr(1) : i;
				retObj[prop] = wildCard ? obj[i] : Number(obj[i]);  
		
			}
			return retObj;
		}
		
		/** @private */
		protected function checkIsReversible(tw:TweenCore):Boolean {
			if (tw == null || !interruptReversible) return false;
			if ( tw.active  ) {
				tw.reverse();
				return true;
			}
			return false;
		}
		
		// -- Public methods
		
		public function set initVars(obj:Object):void {
			for (var i:String in obj) { // inline no type-checking
				_restoreVars[i] = _target[i];
				_target[i] = Number(obj[i]);  
				
			}
		}
		
		public function set restoreVars(obj:Object):void {
			for (var i:String in obj) { 
				_restoreVars[i] = Number(obj[i]);  
			}
		}
		
		public function set ease(func:Function):void {
			easeIn = func;
			easeOut = func;
		}
		
		public function set duration(val:Number):void {
			durationIn = val;
			durationOut = val;
		}
		
		public function set fromVars(obj:Object):void {
			var obj:Object = createVarsFromObject(obj);
		
			_inVars = _tweenClass["from"](_target, durationIn, obj );
		}
		
		
		
		public function set inVars(obj:Object):void {
			_inVars = createVarsFromObject( obj );
		}
		
		public function set outVars(obj:Object):void {
			_outVars = createVarsFromObject( obj );
		}
				
		
		
		// -- IDestroyable
		
		public function destroy():void {
			
			for (var i:String in _restoreVars) {
				_target[i] = _restoreVars[i];
			}
			if (_curTween) {
				_curTween.pause();
				_curTween = null;
			}

		}


		
	}

}