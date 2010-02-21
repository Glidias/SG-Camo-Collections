package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import camo.core.events.CamoChildEvent;
	import camo.core.events.CamoDisplayEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import sg.camo.ancestor.AncestorListener;
	import sg.camo.behaviour.AbstractLayout;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDisplayBase;
	import sg.camo.interfaces.IDiv;
	import sg.camo.notifications.GDisplayNotifications;
	/**
	 * This is a layout behaviour applied to a container
	 * that can layout any elements implementing the IDiv interface,
	 * in order to create flow-based or pin-based liquid layouts with z-indexing support. 
	 * It is loosely based on xHTML's implementation on CSS.
	 * 
	 * @see sg.camo.interfaces.IDiv
	 * @author Glenn Ko
	 */
	public class DivLayoutBehaviour extends AbstractLayout
	{
		/** @private Casted DisplayObjectContainer to IDiv interface, if available. */
		protected var _containerWidth:Number;
		protected var _containerHeight:Number;
		
		/** @private Casted IDisplayBase interface for container, if available. */
		protected var _dispBase:IDisplayBase;
		
		/** @private */ protected var _absDict:Dictionary = new Dictionary();
		/** @private */ protected var _flowDict:Dictionary = new Dictionary();
		/** @private */ protected var _firstNode:DivNode;
		/** @private */ protected var _lastNode:DivNode;
		/** @private */ protected var _highestDict:Dictionary = new Dictionary();
		
		public static const ABSOLUTE:String = "absolute";
		public static const INLINE:String = "inline";
		public static const BLOCK:String = "block";	
		
		/** @private */ protected var _firstPositive:ZChildNode;
		/** @private */ protected var _firstNegative:ZChildNode;
		/** @private */ protected var _zDict:Dictionary = new Dictionary();
	
		/**
		 * Automatically prepends any newly added children at a particular flow layout index (if available).
		 * If set to a negative value, it'll turns off prepending ability (which is by default, not enabled).
		 */
		public function set prependFlowIndex(val:Number):void {
			_prependFlowIndex = int(val);
			_prepend =  val >= 0;
		}
		public function get prependFlowIndex():Number {
			return _prependFlowIndex;
		}
		/** @private */  protected var _prepend:Boolean = false;
		/** @private */  protected var _prependFlowIndex:int = -1;
		

		/**
		 * Enforce a fixed depth index when adding children to display flow if the added IDiv's z-index 
		 * is at default value (ie.neutral zero or undefined)
		 * Using negative values for addChildDepth doesn't perform any re-arrangements of display list depths for 
		 * flow children, which is is the case by default;
		 */
		public function set addChildDepth(val:Number):void {
			_addChildDepth = int(val);
		}
		public function get addChildDepth():Number {
			return _addChildDepth;
		}
		protected var _addChildDepth:int = -1;

		
		/**
		 * This handler processes new z-index changes of children or adding/removing of new children to display container
		 * which might have different z-index settings.
		 * @param	e		The CamoChildEvent automatically passed to the handler during each CamoChildEvent.ADD_CHILD occurance
		 * 					from the container.
		 * @param   child	If no CamoChildEvent is supplied, a valid child reference must be provided.
		 * @see import camo.core.events.CamoChildEvent
		 */
		protected function addChildInterruptDepthHandler(e:CamoChildEvent=null, child:DisplayObject = null):void {
			child = e ?  e.child : child;
			if (!(child is IDiv)) return;
			
			var div:IDiv = child as IDiv;
			var referNode:ZChildNode;
			var firstNode:ZChildNode;
			
			if ( Boolean(div.zIndex) ) {
				
				var isPositive:Boolean = div.zIndex > 0;
				var absIndex:int = isPositive ? int(div.zIndex) : int(-div.zIndex);
				
				firstNode = isPositive ? _firstPositive : _firstNegative;
				var tailDepth:int = isPositive ? _disp.numChildren - 1 : 0;
				var tarIndex:int;
				var vec:int = isPositive ? 1 : -1;
				
				if (!firstNode) {
					if (isPositive) {
						_firstPositive = new ZChildNode(child, absIndex, div.zIndex);
						_zDict[child] = _firstPositive;
					}
					else {
						_firstNegative =  new ZChildNode(child, absIndex, div.zIndex);
						_zDict[child] = _firstNegative;
					}
					_disp.setChildIndex(child, tailDepth); 
				}
				else {
					var myNode:ZChildNode  = new ZChildNode(child, absIndex, div.zIndex);
					
					referNode = appendZNodeFrom(myNode, firstNode);
					if (referNode) {
						tarIndex = _disp.getChildIndex(referNode.child) + vec;
						tarIndex = tarIndex < 0 ? 0 : tarIndex > _disp.numChildren - 1 ? _disp.numChildren - 1 : tarIndex;
						
						if (myNode.next == null) {
							_disp.setChildIndex(child, tailDepth);
						}
						else {
							_disp.setChildIndex(child, tarIndex);
						}
					}
					else {
						vec = isPositive ? 0 : 1;
						_disp.setChildIndex(child, _disp.getChildIndex(firstNode.child)+ vec );
					}
				}
				return;
			}
			else if (_firstPositive || _firstNegative) {
				var depthTop:int = _firstPositive ? _disp.getChildIndex(_firstPositive.child )  : int.MAX_VALUE;
				var depthMiddle:int =  (div.position === ABSOLUTE || _addChildDepth < 0) ?   _disp.numChildren - 1 :  validateDepth(_disp, _addChildDepth);
				var depthBottom:int = _firstNegative ? _disp.getChildIndex(_firstNegative.child ) + 1 : 0; 	
				_disp.setChildIndex( child, validateZIndexes(depthBottom, depthMiddle, depthTop)  );
				return;
			}
			
			
			if (div.position === ABSOLUTE || _addChildDepth < 0) return;

			_disp.setChildIndex(child, validateDepth(_disp, _addChildDepth) );
		}
		
		protected static function validateDepth(cont:DisplayObjectContainer, val:int):int {
			return val > cont.numChildren - 1 ? cont.numChildren - 1 : val < 0 ? 0 : val;
		}
		protected static function validateZIndexes(bottom:int, middle:int, top:int):int {
			return middle > bottom ? middle < top ? middle : top : bottom;
		}
		protected function appendZNodeFrom(zChildNode:ZChildNode, fromNode:ZChildNode):ZChildNode {
			_zDict[zChildNode.child] = zChildNode;
			
			var targIndex:int = zChildNode.zIndex;
			var isPositive:Boolean = fromNode === _firstPositive;
		
			var prevNode:ZChildNode;

			while (fromNode) {
				if (fromNode.zIndex > targIndex) break;
				
				prevNode = fromNode;
				fromNode = fromNode.next;
			}
			
			if (prevNode) {   // append from prev node
				zChildNode.next = prevNode.next;
				prevNode.next = zChildNode;
				return prevNode;
			}
			else {  // prepend from beginning node
				zChildNode.next = fromNode;
				if (isPositive) _firstPositive = zChildNode
				else _firstNegative = zChildNode;
			}
			
		
			return null;
		}
		
		protected function removeZNode(zChildNode:ZChildNode):ZChildNode {
			var prevNode:ZChildNode;
			var fromNode:ZChildNode = zChildNode.savedZIndex > 0 ? _firstPositive  : _firstNegative;
			while ( fromNode) {
				if (fromNode === zChildNode) {
					if (prevNode) {
						prevNode.next = fromNode.next;
						fromNode.next = null;
					}
					else {
						var isPositive:Boolean = fromNode === _firstPositive;
						if (isPositive) _firstPositive = fromNode.next
						else _firstNegative = fromNode.next;
					}
					delete _zDict[zChildNode.child];
					return zChildNode;
				}
				
				prevNode = fromNode;
				fromNode = fromNode.next;
			}
			trace( "[DivLayoutBehaviour] warning! No ZChildNode found during removeZNode():"+fromNode, prevNode );
			delete _zDict[zChildNode.child];
			
			return null;
		}
		
		/**
		 * Processes any z index change from any display object that dispatches a 
		 * GDisplayNotifications.Z_INDEX_CHANGE bubble to container.
		 * @see sg.camo.notifications.GDisplayNotifications
		 * @param	e
		 */
		protected function onZIndexChange(e:Event):void {
			if (e.target === _disp) return;
			
			e.stopPropagation();
			var div:IDiv = e.target as IDiv;
			if (!div) return;
			
			var zNode:ZChildNode = _zDict[div];
			if (zNode) {
				removeZNode(zNode);
			}
	
			
			addChildInterruptDepthHandler( null, div as DisplayObject );
		}
		
		
		override public function destroy():void {
			if (_disp) {
				AncestorListener.removeEventListenerOf(_disp, CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler);
				AncestorListener.removeEventListenerOf(_disp, GDisplayNotifications.Z_INDEX_CHANGE, onZIndexChange);
			}
			super.destroy();
			_zDict = null;
		}
		
		

		public static const NONE:String = AlignValidation.NONE;
		public static const LEFT:String = AlignValidation.LEFT;
		public static const MIDDLE:String = AlignValidation.MIDDLE;
		public static const RIGHT:String = AlignValidation.RIGHT;
		public static const TOP:String = AlignValidation.TOP;
		public static const BOTTOM:String = AlignValidation.BOTTOM;
		
		protected var _textAlignStr:String = AlignValidation.NONE; 
		protected var _textAlignRatio:Number = AlignValidation.VALUE_NONE;
		
		
		/** @private */ protected var _lineHeight:Number = 0;
		/** @private */ protected var _align:String = LEFT;
		
		/**
		 * Sets line height for inline elements for every break to a block
		 * element or wrapping to next line.
		 */
		public function set lineHeight(val:Number):void {
			_lineHeight = val;
			if (_disp) InvalidateDisplay.invalidate(_disp);
		}
		public function get lineHeight():Number {
			return _lineHeight;
		}

		/**
		 * Sets horizontal alignment for inline elements
		 */
		public function set textAlign(val:String):void {
			_textAlignStr = val;
			_textAlignRatio = AlignValidation.toAlignRatio(val);
			if (_disp) InvalidateDisplay.invalidate(_disp);
		}
		public function get textAlign():String {
			return _textAlignStr;
		}
		

		public function DivLayoutBehaviour() 
		{
			super(this);
		}
		
		override public function activate(targ:*):void {
			super.activate(targ);
			_dispBase = targ as IDisplayBase;
			if (!_disp) return;
			updateContainerDimensions();
			AncestorListener.addEventListenerOf(_disp, CamoChildEvent.ADD_CHILD, addChildInterruptDepthHandler, 1, true);
			
			AncestorListener.addEventListenerOf(_disp, GDisplayNotifications.Z_INDEX_CHANGE, onZIndexChange);
		}
		
		/** @private */
		protected function updateContainerDimensions():void {
			_containerWidth = _dispBase ? _dispBase.__width : _disp.width;
			_containerHeight = _dispBase ? _dispBase.__height : _disp.height;
		}
		
		/**
		 * 
		 * @param	e
		 */
		override protected function addChildHandler(e:CamoChildEvent):void {
			
			var child:DisplayObject = e.child;
			var div:IDiv = child is IDiv ? child as IDiv : child is IBehaviouralBase ? (child as IBehaviouralBase).getBehaviour("DivBehaviour") as IDiv : null;
			if (div == null) return;  // do nothing if can't find div implemenation for child
			
	
			if (div.position === ABSOLUTE) {
				_absDict[child] = div; 
				positionAbsolute( div );
				return;
			}
				
			var node:DivNode = new DivNode(div);
			_flowDict[child] = node;
			
			if ( !_firstNode) {  // add first node
				_firstNode = node;
				_lastNode = node;
				processFirstNode(node);
			}
			else if (_prepend) {
				if (_prependFlowIndex <= 0) {
					node.next = _firstNode;
					_firstNode.prev = node;
					_firstNode = node;
					processFirstNode(node);
					processNode(node.next, node);
				}
				else {
					
					var validNode:DivNode = _firstNode;
					var targNode:DivNode = _firstNode;
					var count:int = 0;
					while (targNode) {
						validNode = targNode;
						count++;
						if (count == _prependFlowIndex) break;
						targNode = targNode.next;
					}
					node.prev = validNode;
					node.next = validNode.next;
					validNode.next = node;
					
					
					processNode(node, node.prev);
					_lastNode = node.next ? _lastNode : node;
				}
			}
			else  {   // consider previous node 
		
				_lastNode.next = node;
				node.prev = _lastNode;
				processNode(node, _lastNode)
		
				_lastNode = node;

			}
			
			updateContainerDimensions();
		}
		
		protected function processFirstNode(node:DivNode):void {
			var div:IDiv = node.div;
			var mY:Number = div.displayFlow === INLINE ?  0 : div.marginTop;
			node.moveTo(0, mY);
			if (div.displayFlow === INLINE) {
				_highestDict[String(node.rowIndex)] = div;
			}
		}
		
		protected function updateHighestDivFrom(node:DivNode):void {
							//trace("NEED TO RESOLVE");
							var bNode:DivNode = node.prev || node;
							var bHighestHeight:Number = 0;
							var bCurIndex:int = node.rowIndex;
							var bPrevNode:DivNode = bNode;
							var bHighestNode:DivNode = bNode;
							while (bNode) {
								if (bNode.rowIndex != bCurIndex) break;
								var isHigher:Boolean = bNode.div.height > bHighestHeight;
								bHighestHeight = isHigher ?  bNode.div.height : bHighestHeight;
								bHighestNode =  isHigher ? bNode :  bHighestNode;
								bPrevNode = bNode;
								bNode = bNode.prev;
							}
							_highestDict[String(node.rowIndex)] = bHighestNode.div; 
		}
			protected function updateVAlignFrom(node:DivNode):void {
						
							var bNode:DivNode = node.prev;
							//trace("Updating v align from:"+node.rowIndex, bNode);
							var bHighestHeight:Number = _highestDict[String(node.rowIndex)].height;
							var bCurIndex:int = node.rowIndex;
					
							var rightBound:Number = bNode ? bNode.x + bNode.div.width : 0;

							var gotTextAlign:Boolean = _textAlignRatio != AlignValidation.VALUE_NONE;
							
							var xOffset:Number = gotTextAlign ? (_containerWidth - rightBound) * _textAlignRatio : 0; 
							
						
							var totalWidthSpan:Number = 0;
							while (bNode) {
								if (bNode.rowIndex != bCurIndex) break;
								var vertAlign:Number = AlignValidation.toVAlignRatio(bNode.div.verticalAlign);
								if (vertAlign != AlignValidation.VALUE_NONE) 
									bNode.vAlignOffset = (bHighestHeight - bNode.div.height) * vertAlign;
								if (gotTextAlign) bNode.hAlignOffset = xOffset;
							
								bNode = bNode.prev;
							}			
		}
		
		
		protected function processNode(node:DivNode, prevNode:DivNode):void {
		
				var div:IDiv = node.div;
				//if (div.position === ABSOLUTE) return;
				var bNode:DivNode;
				var add:Number;
				var mX:Number;
				var mY:Number;
				var highestDiv:IDiv ;
				var lastDiv:IDiv = prevNode.div;
				var isInline:Boolean = div.displayFlow === INLINE && lastDiv.displayFlow === INLINE;
				if (isInline) {  
					node.rowIndex = prevNode.rowIndex;
					highestDiv = _highestDict[String(node.rowIndex)];
						
					mX = prevNode.x + lastDiv.marginRight + lastDiv.width + div.marginLeft;
					
					
					if (mX + div.width > _containerWidth) {  
	
						if (div === highestDiv) {
							updateHighestDivFrom(node);
							highestDiv = _highestDict[String(node.rowIndex)];
						}
						
						// break and resolve valign prevs
						
						updateVAlignFrom(node);
						mX = 0;
						mY = highestDiv.y + highestDiv.height + _lineHeight;
						node.rowIndex++;  
						node.moveTo(mX, mY);
						
						_highestDict[String(node.rowIndex)] = div;
					
					}
					else { //trace("setting inline...");
						mY = highestDiv.y;
						node.moveTo(mX, mY);
						if (div.height > highestDiv.height) {
							_highestDict[String(node.rowIndex)] = div;
							//trace("succeeding height of row index:"+node.rowIndex);
						}
					}
				}
				else {  //trace("Auto break from/to block");
					add = div.displayFlow != INLINE ? div.marginTop : 0;
					
					
	
					if (lastDiv.displayFlow != INLINE) {
						mX = 0;
						mY = prevNode.y + lastDiv.marginBottom + lastDiv.height + add
						node.moveTo(mX, mY);
					}
					else {
						 // break and resolve valign prevs
						//trace("Updating:" + node.prev.);
						//trace("BLOCK:" + node.div.displayFlow);
						node.rowIndex = prevNode.rowIndex;
						updateVAlignFrom(node);
						
						mX = 0;
						highestDiv = _highestDict[String(prevNode.rowIndex)];
						mY= highestDiv.y + highestDiv.height + add +  _lineHeight;
						node.moveTo(mX, mY);
					
					}
					node.rowIndex = prevNode.rowIndex  + 1;
					_highestDict[String(node.rowIndex)] = div;
				}
		}
		
		protected function removeDivFromFlow(node:DivNode):void {
				var prevNode:DivNode;
				if (node === _firstNode) {
					_firstNode = node.next;
					node.next = null;
					node.prev = null;
					if (_firstNode) {
						_firstNode.prev = null;
					}
					else return;
					processFirstNode(_firstNode);
					node = _firstNode.next;
					if (node) node.prev = _firstNode;
					prevNode = _firstNode;
					while (node) {
						processNode(node, prevNode );
						prevNode = node;
						node = node.next;
					}
				}
				else {
				
					var nextNode:DivNode = node.next;
					prevNode = node.prev;
					if (node.div.displayFlow === INLINE && _highestDict[String(node.rowIndex)]===node.div ) {
						updateHighestDivFrom(node);
						updateVAlignFrom(node);
					}
					node.prev = null;
					node.next = null;
					prevNode.next = nextNode;
					if (nextNode) nextNode.prev = prevNode
					else return;
					
					node = nextNode;
					while (node) {
						processNode(node, prevNode );
						prevNode = node;
						node = node.next;
					}
				}
		}
		
		override protected function removeChildHandler(e:CamoChildEvent):void {
			
			
			var child:DisplayObject = e.child;
			
			if (_flowDict[child]) {
				removeDivFromFlow( _flowDict[child]);
				delete  _flowDict[child];
			}
			else if (_absDict[child]) {
				
				delete _absDict[child];
			}
			
			updateContainerDimensions();
		}
		override protected function reDrawHandler(e:CamoDisplayEvent):void {
			if (!e.bubbles) return;  // assumed non-bubbling events denote non-size/layout changed events
			
			var node:DivNode;
			var nextNode:DivNode;
			if (e.target === _disp) {  // Assume resize change of main container, update everything
				var i:*;
				updateContainerDimensions();
	
				//trace("Updating container width:"+_containerWidth);
				for (i in _absDict) {
					positionAbsolute(_absDict[i]);
				}
				
				if (_firstNode) {
					processFirstNode(_firstNode);
					node = _firstNode.next;
					var prevNode:DivNode = _firstNode;
					while (node) {
						processNode(node, prevNode );
						prevNode = node;
						node = node.next;
					}
				}
				return;
			}
			var target:Object = e.target;
			var div:IDiv;
			if (_flowDict[target]) {
				var divNode:DivNode = _flowDict[target];
				div = divNode.div;
				if (div.position === ABSOLUTE) {
				
					removeDivFromFlow(divNode);
					delete _flowDict[target];
	
					divNode.next = null;
					divNode.prev = null;
					_absDict[target] = div; 
					positionAbsolute(div);
					updateContainerDimensions();
					return;
				}
				else {
					
					divNode = _flowDict[target];
					if (divNode === _firstNode) {
						processFirstNode(divNode);
						node = divNode.next;
						prevNode = divNode;
					}
					else {
						node = divNode;
						prevNode = divNode.prev;
					}
					while (node) {
						processNode(node, prevNode );
						prevNode = node;
						node = node.next;
					}
					updateContainerDimensions();
				}
			}
			else if (_absDict[target]) {
				positionAbsolute( _absDict[target] );
			}
		}
		
		/**
		 * @private
		 * Positions div by absolute positioning relative off parent container's edge. 
		 * @param	div
		 */
		protected function positionAbsolute(div:IDiv):void {
			div.x = isNaN(div.right) ? div.left : _containerWidth - div.right - div.width;
			div.y = isNaN(div.bottom) ? div.top : _containerHeight - div.bottom - div.height;
		}
		
		
	}

}



import flash.display.DisplayObject;
import sg.camo.interfaces.IDiv;

internal class DivNode {
	
	public var div:IDiv;
	public var next:DivNode;
	public var prev:DivNode;
	public var rowIndex:int = 0;
	public var x:Number = 0;
	public var y:Number = 0;

	
	public function DivNode(div:IDiv):void {
		this.div = div;
	}
	public function moveTo(x:Number, y:Number):void {
		var nonRelative:Boolean = div.position != "relative";
		this.x = x;
		this.y = y;
		div.x = nonRelative ? x : x + div.left;
		div.y = nonRelative ? y : y + div.top;

	}
	
	public function set vAlignOffset(val:Number):void {
		div.y = div.position != "relative" ? y + val : y + div.top + val;	
	}
	public function set hAlignOffset(val:Number):void {
		div.x = div.position != "relative" ? x + val : x + div.left + val;	
	}
	
	
}

internal class ZChildNode {
	
	public var child:DisplayObject;
	public var zIndex:int;  // absolute value z index
	public var next:ZChildNode;
	public var savedZIndex:int;  // saved actual z index value
	
	public function ZChildNode(child:DisplayObject, zIndex:int, savedZIndex:int):void {
		this.child = child;
		this.zIndex = zIndex;
		this.savedZIndex = savedZIndex;
	}
	
}