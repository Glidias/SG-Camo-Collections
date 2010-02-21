package sg.camo.behaviour 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import sg.camo.interfaces.IBehaviour;
	import flash.events.MouseEvent;
	import flash.events.IEventDispatcher;
	import sg.camo.ancestor.AncestorListener;
	/**
	 * Sets up a targetted dispatching object (normally a holder sprite or just some generic IEventDispatcher) to automatically target a movieclip to scrub forwards/backwards based on the supplied event types.
	 * By default, this behaviour is set to scrub forward continuously during MouseEvent.ROLL_OVER and to start scrubbing backwards during
	 * MouseEvent.ROLL_OUT.
	 * 
	 * @author Glenn Ko
	 */
	public class ScrubBehaviour implements IBehaviour
	{
		
		public static const NAME:String = "ScrubBehaviour";

		/** @private */
		protected var _listenScrubForward:String;
		/** @private */
		protected var _listenScrubBackward:String;
		
		protected var _target:MovieClip;
		protected var _targDispatcher:IEventDispatcher;
		
		/** @private */
		protected var _hasEnterFrame:Boolean = false;
		/** @private */
		protected var _forward:Boolean = false;
		
		/**
		 * Constructor 
		 * @param	$target		(MovieClip) Required if scrubbing movieclip different from target dispatcher. Can inject later with setter <b>before activation</b>.
		 * @param	$listenScrubForward		(String)	Defaulted to MouseEvent.ROLL_OVER. The Event type to listen to for triggering a scrub forward behaviour.
		 * @param	$listenScrubBackward	(String) 	Defaulted to MouseEvent.ROLL_OUT. The Event type to listen to for triggering a scrub backward behaviour.
		 */
		public function ScrubBehaviour($target:MovieClip=null, $listenScrubForward:String=MouseEvent.ROLL_OVER, $listenScrubBackward:String=MouseEvent.ROLL_OUT) {
			_target = $target;
			_listenScrubForward = $listenScrubForward;
			_listenScrubBackward = $listenScrubBackward;
		}
		
		/**
		 * Sets target scrubbing movieclip (required if scrubbing movieclip is different from target dispatcher).
		 */
		public function set target(mc:MovieClip):void {
			_target  = mc;
		}
		
		/**
		 * Re-sets scrubForward event type to listen to for scrub-forward behaviour.
		 */
		public function set listenScrubForward(type:String):void {
			if (_targDispatcher != null) { // already activated
				if (_listenScrubForward != null) {
					AncestorListener.removeEventListenerOf(_targDispatcher, _listenScrubForward, handleScrubForward);
					_listenScrubForward = type;
					AncestorListener.addEventListenerOf(_targDispatcher, _listenScrubForward, handleScrubForward);
					return
				}
			}
			_listenScrubForward = type;
		}
		/**
		 * Re-sets scrubBackward event type to listen to for scrub-backward behaviour.
		 */
		public function set listenScrubBackward(type:String):void {
			if (_targDispatcher != null) { // already activated
				if (_listenScrubBackward != null) {
					AncestorListener.removeEventListenerOf( _targDispatcher, _listenScrubBackward, handleScrubBackward);
					_listenScrubBackward = type;
					AncestorListener.addEventListenerOf( _targDispatcher, _listenScrubBackward, handleScrubBackward);
					return;
				}
			}
			_listenScrubBackward = type;
		}
		
		/**
		 * Triggers when listenScrubForward event type occurs
		 * @param	e	(Event)
		 */
		protected function handleScrubForward(e:Event):void {
			if (!_hasEnterFrame) {
				_hasEnterFrame = true;
				_target.addEventListener(Event.ENTER_FRAME, enterFrameChecker, false, 0, true);
			}
			_forward = true;
		}
		/**
		 * Triggers when listenScrubBackward event type occurs
		 * @param	e	(Event)
		 */
		protected function handleScrubBackward(e:Event):void {
			if (!_hasEnterFrame) {
				_hasEnterFrame = true;
				_target.addEventListener(Event.ENTER_FRAME, enterFrameChecker, false, 0, true);
			}
			_forward = false;
		}
		
		/**
		 * @private
		 * Checks for enter frame state to determine if scrubbing can end.
		 * @param	e	(Event)
		 */
		protected function enterFrameChecker(e:Event):void {
			var tarFrame:Number = _forward ? _target.currentFrame + 1 : _target.currentFrame - 1;
			_target.gotoAndStop(tarFrame);
			if (tarFrame == 1 || tarFrame == _target.totalFrames) {
				_hasEnterFrame = false;
				_target.removeEventListener(Event.ENTER_FRAME, enterFrameChecker);
			}
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		
		/**
		 * Activates target dispatcher and attempts to target movieclip reference.
		 * @param	targ
		 */
		public function activate(targ:*):void {
			var chkDispatcher:IEventDispatcher = (targ as IEventDispatcher);
			if (chkDispatcher == null) {
				trace("ScrubBehaviour activate() halt. targ as IEventDispatcher is null!");
				return;
			}
			_target = _target != null ? _target : targ as MovieClip;
			if (_target == null)  {
				trace("ScrubBehaviour activate() halt. No target movieClip found!");
				return;
			}
			
			_targDispatcher = chkDispatcher;
			AncestorListener.addEventListenerOf(_targDispatcher, _listenScrubForward, handleScrubForward);
			AncestorListener.addEventListenerOf(_targDispatcher, _listenScrubBackward, handleScrubBackward);
		}
		
		public function destroy():void {
			if (_targDispatcher == null || _target == null) return;
			AncestorListener.removeEventListenerOf(_targDispatcher, _listenScrubForward, handleScrubForward);
			AncestorListener.removeEventListenerOf(_targDispatcher, _listenScrubBackward, handleScrubBackward);
			_target.removeEventListener(Event.ENTER_FRAME, enterFrameChecker);
			_targDispatcher = null;
			_target = null;
		}
		
	}

}