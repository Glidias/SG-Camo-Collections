package sg.camogxml.managers.gs 
{
	import camo.core.events.CamoChildEvent;
	import com.greensock.core.TweenCore;
	import com.greensock.TimelineLite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.notifications.GDisplayNotifications;
	import sg.camogxml.managers.gs.data.GSPluginVars;
	
	/**
	 * A list transition scheme to support staggered transitonings of list items on a GS timeline.
	 * When this class is instantiated, it listens for any specific add/remove CamoChildEvent notifications
	 * from the targetted list container to determine the entire list of items to be transtioned in/out on a GS timeline 
	 * together with it's list container.
	 * Everytime a list item is added, it appends a new tween to the timeline and everytime a list item
	 * is removed, it splices the list item from the timeline.
	 * 
	 * @author Glenn Ko
	 */
	public class GSListTransition extends GSTransition
	{
		public var forEachEaseIn:Function = null;
		public var forEachEaseOut:Function = null;
		public var forEachDuration:Number = .3;
		public var stagger:Number = 0;

		/**
		 * Whether the container must tween in/out first before the items transition in, or do it concurrently.
		 */
		public var containerFirst:Boolean = true;
		
		/**  @private */ protected var timeline:TimelineLite;
		/** @private */ protected var _oldTween:TweenCore;
		/**  @private */ protected var _forEachVars:Object = {};
		/**  @private */ protected var _isFrom:Boolean = false;
		/**  @private */ protected var _oldIn:Boolean = false;
		/**  @private */ protected var _oldOut:Boolean = false;
		
		private var $listenAdd:String;
		private var $listenRemove:String;
		
		/**
		 * Constructor
		 * @param	target		  Required. The targeted list container should also be an IEventDispatcher.
		 * @param  tweenClass		The optional custom TweenLite class to use. (eg. TweenMax)					
		 * @param	listenAdd	  Listens for a particular CamoChildEvent in the bubbling phase on the 
		 * 						targetted container to denote adding of list item into the timeline.
		 * @param	listenRemove  Listens for a particular CamoChildEvent in the bubbling phase on the 
		 * 						targetted container to denote a removal of a list item into the timeline.
		 * 	@param   timelineClass	A custom timeline TimelineLite Class to use .
		 */												//			
		public function GSListTransition(target:Object, tweenClass:Class=null, pluginVars:GSPluginVars=null, listenAdd:String=GDisplayNotifications.ADD_LIST_ITEM, listenRemove:String=GDisplayNotifications.REMOVE_LIST_ITEM, timelineClass:Class = null ) 
		{
			super(target, tweenClass, pluginVars);
			timelineClass = timelineClass || TimelineLite;
			timeline = new timelineClass() as TimelineLite;
			listenAdd = listenAdd || GDisplayNotifications.ADD_LIST_ITEM;
			listenRemove = listenRemove || GDisplayNotifications.REMOVE_LIST_ITEM;
			
			
			// Main list container duration is set to zero by default. If set to higher, will perform transitioning
			// of main list container as well, which is not just the items.
			this.duration = 0;
		
			var disp:IEventDispatcher = target as IEventDispatcher;
		
			$listenAdd = listenAdd;
			$listenRemove = listenRemove;
			if (disp == null) return;
			AncestorListener.addEventListenerOf(disp, listenAdd, addItemHandler);
			AncestorListener.addEventListenerOf(disp, listenRemove, removeItemHandler);
		}
		
		
		// -- Public methods
		
		public function set forEachFromVars(val:Object):void {
			_forEachVars = createVarsFromObject(val);
			_isFrom = true;
		}
		public function set forEachInVars(val:Object):void {
			_forEachVars = createVarsFromObject(val);
			_isFrom = false;
		}
		
		public function set forEachEase(val:Function):void {
			forEachEaseIn = val;
			forEachEaseOut = val;
		}
		
		/** 
		 * Appends item to timeline of transition list
		 * */
		protected function addItemHandler(e:Event):void {
			var targetToAdd:Object = e is CamoChildEvent ? (e as CamoChildEvent).child : null;
			if (targetToAdd != null) {
				var tw:TweenCore = _isFrom ? _tweenClass["from"](targetToAdd, forEachDuration, _forEachVars) :  new _tweenClass(targetToAdd, forEachDuration, _forEachVars) ;
				
				timeline.append(tw, stagger);
			}
		}
		/** 
		 * Splices item from timeline of transition list
		 * */
		protected function removeItemHandler(e:Event):void {
			var targetToAdd:Object = e is CamoChildEvent ? (e as CamoChildEvent).child : null;
			if (targetToAdd != null) {
				var arr:Array = timeline.getTweensOf( targetToAdd );
				if (arr.length < 1) return;
				var removedTween:TweenCore = arr[0] as TweenCore;
				timeline.clear(arr);
				timeline.shiftChildren(-(removedTween.duration + stagger), false, removedTween.startTime);
			}
		}
		
		// -- ITransitionModule
		
		override public function get transitionInPayload():* {
			if (_oldTween) {
				timeline.remove(_oldTween);
				_oldTween = null;
			}
			if (durationIn > 0) {
				var oldTween:TweenCore = _oldIn ? null : super.transitionInPayload;
				_oldIn = true;
				_oldOut = false;
				if (oldTween != null) {
					if (containerFirst) timeline.prepend(oldTween)
					else timeline.insert(oldTween);
					_oldTween = oldTween;
				}
			}
			_curTween = timeline;
			//_curTween.pause();
			checkIsReversible(_curTween);
			return _curTween;
		}
		

		override public function get transitionOutPayload():* {
			if (_oldTween) {
				timeline.remove(_oldTween);
				_oldTween = null;
			}
			if (durationOut > 0) {
				var oldTween:TweenCore =  _oldOut ? null : super.transitionOutPayload;
				_oldOut = true;
				_oldIn = false;
				if (oldTween != null) {
					if (containerFirst) timeline.prepend(oldTween)
					else timeline.insert(oldTween);
					_oldTween = oldTween;
				}
			}
			_curTween = timeline;
			//_curTween.pause();
			checkIsReversible(_curTween);
			return _curTween;
		}
		

		
		/**
		 * Clears listeners and de-activates transition scheme generation. 
		 */
		override public function destroy():void {
			var disp:IEventDispatcher = _target as IEventDispatcher;
			if (disp != null) {
				AncestorListener.removeEventListenerOf(disp, $listenAdd, addItemHandler);
				AncestorListener.removeEventListenerOf(disp, $listenRemove, removeItemHandler);
			}
			super.destroy();
			timeline.clear();
		}
		
	
		
	}

}