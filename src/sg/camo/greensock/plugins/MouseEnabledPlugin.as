package sg.camo.greensock.plugins {
	import com.greensock.*;
	
	import flash.display.*;
	import com.greensock.plugins.TweenPlugin;
	
/**
 * Disables mouseEnabled status of the component during the tween.. 
 *   For example, if you want to set <code>mouseEnabled</code> to false
 * at the end of the tween, do:<br /><br /><code>
 * 
 * TweenLite.to(mc, 1, {x:100, mouseEnabled:false});<br /><br /></code>
 * 
 * The <code>visible</code> property is forced to true during the course of the tween. <br /><br />
 * 
 * <b>USAGE:</b><br /><br />
 * <code>
 * 		import com.greensock.TweenLite; <br />
 * 		import com.greensock.plugins.TweenPlugin; <br />
 * 		import sg.camo.greensock.plugins.MouseEnabledPlugin; <br />
 * 		TweenPlugin.activate([MouseEnabledPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
 * 
 * 		TweenLite.to(mc, 1, {x:100, mouseEnabled:false}); <br /><br />
 * </code>
 * 
 * <b>Copyright 2009, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * 
 * 
 * @author Jack Doyle, jack@greensock.com
 * 
 * 
 * 
 * @author Glenn Ko
 */
	public class MouseEnabledPlugin extends TweenPlugin {
		/** @private **/
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		
		/** @private **/
		protected var _target:Object;
		/** @private **/
		protected var _tween:TweenLite;
		/** @private **/
		protected var _mouseEnabled:Boolean;
		/** @private **/
		protected var _initVal:Boolean;
		
		protected var _targContainer:DisplayObjectContainer;
		
		/** @private **/
		public function MouseEnabledPlugin() {
			super();
			this.propName = "mouseEnabled";
			this.overwriteProps = ["mouseEnabled"];
		}
		
		/** @private **/
		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
			_target = target;
			_tween = tween;
			_initVal = _target.mouseEnabled;
			_targContainer = target as DisplayObjectContainer;
			_mouseEnabled = Boolean(value);
			return true;
		}
		
		/** @private **/
		override public function set changeFactor(n:Number):void {
			if (n == 1 && (_tween.cachedDuration == _tween.cachedTime || _tween.cachedTime == 0)) { //a changeFactor of 1 doesn't necessarily mean the tween is done - if the ease is Elastic.easeOut or Back.easeOut for example, they could hit 1 mid-tween. The reason we check to see if cachedTime is 0 is for from() tweens
				_target.mouseEnabled = _mouseEnabled;
				if (_targContainer) _targContainer.mouseChildren = _mouseEnabled;
			} else {
				_target.mouseEnabled = false; //in case a completed tween is re-rendered at an earlier time.
				if (_targContainer) _targContainer.mouseChildren = false;
			}
		}

	}
}