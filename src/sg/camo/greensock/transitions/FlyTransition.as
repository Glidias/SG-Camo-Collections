package sg.camo.greensock.transitions 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import sg.camo.greensock.CreateGSTweenVars;
	import sg.camo.interfaces.ITransitionModule;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FlyTransition implements ITransitionModule
	{
		
		public var tweenClass:Class = TweenLite;
		
		protected var _targ:DisplayObject;
		
		public var fromDuration:Number = .5;
		public var fromLeft:Number = Number.NaN;
		public var fromRight:Number  = Number.NaN;
		public var fromTop:Number = Number.NaN;
		public var fromBottom:Number = Number.NaN;
		protected var _fromVars:Object;
		public function set fromVars(obj:Object):void {
			_fromVars  = CreateGSTweenVars.createVarsFromObject(obj);
		}
		
		public var toDuration:Number = .5;
		public var toLeft:Number = Number.NaN;
		public var toTop:Number = Number.NaN;
		public var toBottom:Number = Number.NaN;
		public var toRight:Number = Number.NaN;
		
		protected var _toVars:Object;
		public function set toVars(obj:Object):void {
			_toVars = CreateGSTweenVars.createVarsFromObject(obj);
		}
		
		
		public function FlyTransition(targ:DisplayObject, obj:Object) 
		{
			_targ = targ;	
		}
		

		
		public function get transitionInPayload():* {
			var parent:DisplayObject = _targ.parent;
			if (parent == null) {
				trace("Fly transition In payload failed. No parent space");
				return null;
			}
			
			var fromVars:Object = { };
			if ( !isNaN(fromLeft) ) fromVars.x = -_targ.width - fromLeft;
			if ( !isNaN(fromTop)) fromVars.y = -_targ.height - fromTop;
			if (!isNaN(fromBottom)) fromVars.y = parent.height + fromBottom;
			if (!isNaN(fromRight)) fromVars.x  = parent.width + fromRight;
			
			if (_fromVars) {
				for (var i:String in _fromVars) {
					fromVars[i] = _fromVars[i];
				}
			}

			return tweenClass["from"](_targ, fromDuration, fromVars);
		}
		

		public function get transitionOutPayload():* {
			var parent:DisplayObject = _targ.parent;
			if (parent == null) {
				trace("Fly transition Out payload failed. No parent space");
				return null;
			}
			
			var toVars:Object = { };
			if (toLeft) toVars.x = -_targ.width - toLeft;
			if (toTop) toVars.y = -_targ.height - toTop;
			if (toBottom) toVars.y = parent.height + toBottom;
			if (toRight) toVars.x  = parent.width + toRight;
			
			if (_toVars) {
				for (var i:String in _toVars) {
					toVars[i] = _toVars[i];
				}
			}
			return tweenClass["to"](_targ, toDuration, toVars);
		}
		

		public function get transitionType():* {
			return tweenClass;
		}
		
	}

}