package sg.camo.greensock.transitions 
{
	import camo.core.events.CamoChildEvent;
	import com.greensock.core.TweenCore;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.greensock.CreateGSTweenVars;
	import sg.camo.notifications.GDisplayNotifications;
	import sg.camo.greensock.GSPluginVars;
	
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
		public var containerFirst:Boolean = false;
		
		/**  @private */ protected var timeline:TimelineLite;
		/** @private */ protected var _oldTween:TweenCore;
		/**  @private */ protected var _forEachVars:Object = {};
		/**  @private */ protected var _isFrom:Boolean = false;
		/**  @private */ protected var _oldIn:Boolean = false;
		/**  @private */ protected var _oldOut:Boolean = false;
		
		
		private var $listenAdd:String;
		private var $listenRemove:String;
		
		protected var listItemPacketTimeline:Array = [];
		protected var dictItems:Dictionary = new Dictionary();
		
		
		/**
		 * Constructor
		 * @param	target		  Required. The targeted list container should also be an IEventDispatcher.
		 * @param  tweenClass		The optional custom TweenLite class to use. (eg. TweenMax)					
		 * @param	listenAdd	  Listens for a particular CamoChildEvent in the bubbling phase on the 
		 * 						targetted container to denote adding of list item into the timeline.
		 * @param	listenRemove  Listens for a particular CamoChildEvent in the bubbling phase on the 
		 * 						targetted container to denote a removal of a list item into the timeline.
		 * 	@param   timelineClass	A custom timeline TimelineLite Class to use .
		 */															
		public function GSListTransition(target:Object, tweenClass:Class=null, pluginVars:GSPluginVars=null, listenAdd:String=GDisplayNotifications.ADD_LIST_ITEM, listenRemove:String=GDisplayNotifications.REMOVE_LIST_ITEM, timelineClass:Class = null ) 
		{
			super(target, tweenClass, pluginVars);
			timelineClass = timelineClass || TimelineLite;
			timeline = new timelineClass() as TimelineLite;
			listenAdd = listenAdd || GDisplayNotifications.ADD_LIST_ITEM;
			listenRemove = listenRemove || GDisplayNotifications.REMOVE_LIST_ITEM;
			
			
			// Main list container duration is set to zero by default. 
			this.duration = 0;
		
			var disp:IEventDispatcher = target as IEventDispatcher;
		
			$listenAdd = listenAdd;
			$listenRemove = listenRemove;
			if (disp == null) return;
			AncestorListener.addEventListenerOf(disp, listenAdd, addItemHandler);
			AncestorListener.addEventListenerOf(disp, listenRemove, removeItemHandler);
		}
		
		public function get listenAdd():String {
			return $listenAdd;
			
		}
		public function get listenRemove():String {
			return $listenRemove;
		}
		
		
		
		// -- Public methods
		
		public function set forEachFromVars(val:Object):void {
			_forEachVars = CreateGSTweenVars.createVarsFromObject(val, _pluginVars);
			_isFrom = true;
			
		}
		public function set forEachInVars(val:Object):void {
			_forEachVars = CreateGSTweenVars.createVarsFromObject(val, _pluginVars);
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
				
				var twp:TweenPacket = _isFrom ? new TweenPacket( targetToAdd, forEachDuration, reverseVars(_forEachVars), _tweenClass) :  new TweenPacket(targetToAdd, forEachDuration, _forEachVars, _tweenClass);
				listItemPacketTimeline.push(twp);
		
				dictItems[targetToAdd] = twp;
			}
			
			//trace("Add");
		}
		/** 
		 * Splices item from timeline of transition list
		 * */
		protected function removeItemHandler(e:Event):void {
		
			var targetToRemove:Object = e is CamoChildEvent ? (e as CamoChildEvent).child : null;
			if (targetToRemove == null) {
				trace("GSListTransition::removeItemHandler() Exception, target to remove from CamoCHildEvent is null or event isn't CamoChildEvent");
				return;
			}
			
			var packet:TweenPacket = dictItems[targetToRemove];
			if (packet != null) {
				if ( listItemPacketTimeline.length > 0 && listItemPacketTimeline[listItemPacketTimeline.length - 1] === packet ) {
					listItemPacketTimeline.pop();
				}
				else {
					var chkIndex:int = listItemPacketTimeline.indexOf(packet);
					if (chkIndex > -1) {
						listItemPacketTimeline.splice(chkIndex, 1);
					}
					else {
						trace("GSListTransition::removeItemHandler() Exception, index of packet not found");
					}
				}
			}	
				
			var arr:Array = timeline.getTweensOf( targetToRemove );
			if (arr.length < 1) {
				trace("GSListTransition::removeItemHandler() Exception, timeline can't find tween of:" + targetToRemove);
				return;
			}
				
			var removedTween:TweenCore = arr[0] as TweenCore;
			timeline.kill();
			timeline.clear(arr);
			timeline.shiftChildren( -(removedTween.duration + stagger), false, removedTween.startTime);
			if (timeline.duration > 0 ) timeline.resume();
			
		}
		
		// -- ITransitionModule
		
		override public function get transitionInPayload():* {
			var len:int = listItemPacketTimeline.length;
			if (len > 0) {
					
				for (var i:int = 0; i < len; i++) {
					var packet:TweenPacket = listItemPacketTimeline[i];
					delete dictItems[packet.target]
					timeline.append( packet.tween, stagger );
					
				}
			}
			listItemPacketTimeline = [];

			if (_oldTween) {
				timeline.remove(_oldTween);
				_oldTween = null;
			}
		
			var oldTween:TweenCore = super.transitionInPayload;
			if (oldTween) {
				if (containerFirst) timeline.prepend(oldTween)
				else timeline.insert(oldTween);
				_oldTween = oldTween;
			}

			_curTween = timeline;
	
			
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