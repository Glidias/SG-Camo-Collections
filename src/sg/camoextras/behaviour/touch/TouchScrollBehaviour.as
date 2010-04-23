package sg.camoextras.behaviour.touch
{
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IScrollable;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TouchScrollBehaviour implements IBehaviour
	{
		protected var _mask:*;
		protected var _scrollContent:DisplayObject;
		protected var _targContainer:DisplayObjectContainer;
		
		public static const ENABLE:String = "touchScrollEnable";
		public static const DISABLE:String = "touchScrollDisable";
		
	
        
                // Scroll factor is length of mouse movement to detect dragging
                public var scrollFactor:Number = 15;
                // use vertical scrolling
                public var useVertical:Boolean = true;
                // use horizontal scrolling
                public var useHorizontal:Boolean = false;
                // dragging flag
                private var isDragging:Boolean = false;
                // last mouse position
                private var lastPos:Point = new Point();
                // first mouse position
                private var firstPos:Point = new Point();
                // first mouse position in panel 
                private var firstPanelPos:Point = new Point();
                // difference of mouse movement
                private var diff:Point = new Point();
                // scroll inhertia power
                private var inertia:Point = new Point();
                // minimum movable length
                private var min:Point = new Point();
                // maximum movable length
                private var max:Point = new Point();
                
                private var panelWidth:Number;
                
                private var panelHeight:Number;
		
				
				
				// private var _scrollBarV:Sprite = new Sprite();
               // private var _scrollBarH:Sprite = new Sprite();
		 
		
		public function TouchScrollBehaviour() 
		{
			
		}
		
		public function get behaviourName():String {
			return "TouchScrollBehaviour";
		}
		

		public function activate(targ:*):void {
			_targContainer = targ as DisplayObjectContainer;
			if (_targContainer == null) throw new Error("Could not find listening DisplayObject target of:"+targ);
			_scrollContent = targ is IScrollable ? (targ as IScrollable).scrollContent : targ is IDisplay ? (targ as IDisplay).getDisplay() : targ is DisplayObject ?  targ : null;
			if (_scrollContent == null) throw new Error("Could not find scroll content of:" + targ);
			
			_mask = targ is IScrollable ? (targ as IScrollable).scrollMask :  _scrollContent.mask || _scrollContent.scrollRect;
			if (_mask == null) throw new Error("Could not find scroll mask of:" + targ);
			
			panelWidth = _mask.width;
			panelHeight = _mask.height;
			
			_targContainer.addEventListener(ENABLE, enableTouchScroll, false , 0, true);
			_targContainer.addEventListener(DISABLE, disableTouchScroll , false , 0, true);
			
			if (_targContainer.stage) handleAddedToStage()
			else _targContainer.addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
	
		}
		
		private var _enabled:Boolean = false;
		private function enableTouchScroll(e:Event):void {
			if (_enabled) return;
			_enabled = true;
			_targContainer.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
		}
		private function disableTouchScroll(e:Event):void {
			if (!_enabled) return;
			_enabled = false;
			_targContainer.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
		}
		
		 private function handleAddedToStage(e:Event = null):void {
			
           _targContainer.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            _targContainer.addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
            _targContainer.removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			_enabled = true;
			// to handle removed from stage as well..
       }
	   
	
	   
	       private function handleMouseUp(e:MouseEvent):void {
			   var stage:Stage = _targContainer.stage;
                        if (stage.hasEventListener(MouseEvent.MOUSE_MOVE)) {
                                stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
                        }
                        isDragging = false;
                        // setting inertia power
                        if (useVertical) {
                                inertia.y = diff.y;
                        }
                        if (useHorizontal) {
                                inertia.x = diff.x;
                        }
                        
                        stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
                }
	   
	     private function handleMouseMove(e:MouseEvent):void {
                        var mouseX:Number = _targContainer.mouseX;
						var mouseY:Number = _targContainer.mouseY;
                        var totalX:Number = mouseX - firstPos.x;
                        var totalY:Number = mouseY - firstPos.y;
                        
                        // movement detection with scrollFactor
                        if (useVertical && Math.abs(totalY) > scrollFactor) {
                                isDragging = true;
                        }
                        if (useHorizontal && Math.abs(totalX) > scrollFactor) {
                                isDragging = true;
                        }
                        
                        if (isDragging) {
                                
                                if (useVertical) {
                                        if (totalY < min.y) {
                                                totalY = min.y - Math.sqrt(min.y-totalY);
                                        }
                                        if (totalY > max.y) {
                                                totalY = max.y + Math.sqrt(totalY - max.y);
                                        }
                                        _scrollContent.y = firstPanelPos.y + totalY;
                                }
                                
                                if (useHorizontal) {
                                        if (totalX < min.x) {
                                                totalX = min.x - Math.sqrt(min.x-totalX);
                                        }
                                        if (totalX > max.x) {
                                                totalX = max.x + Math.sqrt(totalX - max.x);
                                        }
                                        _scrollContent.x = firstPanelPos.x + totalX;
                                }
                                
                        }
						_targContainer.mouseChildren = false;
                }
		
		private function handleMouseDown(e:MouseEvent):void {
			var stage:Stage = _targContainer.stage;
			var mouseX:Number = _targContainer.mouseX;
			var mouseY:Number = _targContainer.mouseY;
			 if (!stage.hasEventListener(MouseEvent.MOUSE_MOVE)) {
                 stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
                   stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
              }
			    inertia.y = 0;
                 inertia.x = 0;
				diff.x = 0;
				diff.y = 0;
	
                        
                 firstPos.x = mouseX;
                  firstPos.y = mouseY;
				  
				  lastPos.x = mouseX;
				  lastPos.y = mouseY;
                        
                        firstPanelPos.x = _scrollContent.x;
                        firstPanelPos.y = _scrollContent.y;
                        
                        min.x = Math.min(-_scrollContent.x, -_scrollContent.width + panelWidth - _scrollContent.x);
                        min.y = Math.min(-_scrollContent.y, -_scrollContent.height + panelHeight - _scrollContent.y);
                        
                        max.x = -_scrollContent.x;
                        max.y = -_scrollContent.y;
                      
						/*
                        _scrollBarV.graphics.clear();
                        if (useVertical) {
                                _scrollBarV.graphics.beginFill(0x888899,1);
                                _scrollBarV.graphics.drawRoundRect(2,0,6, panelHeight * Math.max(0, panelHeight / _scrollContent.height), 8);
                                _scrollBarV.graphics.endFill();
                        }
                        
                        _scrollBarH.graphics.clear();
                        if (useHorizontal) {
                                _scrollBarH.graphics.beginFill(0x888899,1);
                                _scrollBarH.graphics.drawRoundRect(0,2, panelWidth * Math.max(0, panelWidth / _scrollContent.width), 6, 8);
                                _scrollBarH.graphics.endFill();
                        }*/
						
						
                
			  
		}
		
		 private function handleEnterFrame(e:Event):void {
                        var mouseX:Number = _targContainer.mouseX;
						var mouseY:Number = _targContainer.mouseY;
						
                        diff.y = mouseY - lastPos.y;
                        diff.x = mouseX - lastPos.x;
                        
                        lastPos.y = mouseY;
                        lastPos.x = mouseX;
						
						//var disableContainer:Boolean =  (diff.y > 1 || diff.x > 1);
						//_targContainer.mouseChildren = !disableContainer;
						
                        _targContainer.mouseChildren = !isDragging && _enabled;
						
                        if (!isDragging && _enabled) {
                                
                                // movements while non dragging
                                
                                if (useVertical) {
                                        if (_scrollContent.y > 0) {
                                                inertia.y = 0;
                                                _scrollContent.y *= 0.8;
                                                if (_scrollContent.y < 1) {
                                                        _scrollContent.y = 0;
														_targContainer.mouseChildren = true;
                                                }
                                        }
                                        
                                        if (_scrollContent.height >= panelHeight && _scrollContent.y < panelHeight - _scrollContent.height) {
                                                inertia.y = 0;
                                                
                                                var goal:Number = (panelHeight - _scrollContent.height);	
                                                var diff:Number = goal - _scrollContent.y;
                                                
                                                if (diff > 1) {
                                                        diff *= 0.2;
														_targContainer.mouseChildren = false;
                                                }
												else {
													_targContainer.mouseChildren = diff ==0;
												}
                                                _scrollContent.y += diff;
                                        }
                                        
                                        if (_scrollContent.height < panelHeight && _scrollContent.y < 0) {
                                                inertia.y = 0;
                                                _scrollContent.y *= 0.8;
												
                                                if (_scrollContent.y > -1) {
                                                        _scrollContent.y = 0;
														
					
                                                }
                                        }
                                        
										
                                        if (Math.abs(inertia.y) > 1) {
                                                _scrollContent.y += inertia.y;
                                                inertia.y *= 0.75; //0.95;
												
                                        } else {
                                                inertia.y = 0;
                                        }
                                        
										/*
                                        if (inertia.y != 0) {
                                                if (_scrollBarV.alpha < 1) {
                                                        _scrollBarV.alpha = Math.min(1, _scrollBarV.alpha+0.1);
                                                }
                                                _scrollBarV.y = panelHeight * Math.min(1, (-_scrollContent.y / _scrollContent.height));
                                        } else {
                                                if (_scrollBarV.alpha > 0) {
                                                        _scrollBarV.alpha = Math.max(0, _scrollBarV.alpha-0.1);
                                                }
                                        }
										*/
                                }
                                
                                if (useHorizontal) {
                                        if (_scrollContent.x > 0) {
                                                inertia.x = 0;
                                                _scrollContent.x *= 0.8;
                                                if (_scrollContent.x < 1) {
                                                        _scrollContent.x = 0;
														_targContainer.mouseChildren = true;
                                                }
                                        }
                                        
                                        if (_scrollContent.width >= panelWidth && _scrollContent.x < panelWidth - _scrollContent.width) {
                                                inertia.x = 0;
                                                
                                                goal = panelWidth - _scrollContent.width;
                                                diff = goal - _scrollContent.x;
                                                
                                                if (diff > 1) {
                                                        diff *= 0.2;
														_targContainer.mouseChildren = false;
                                                }
												else {
													_targContainer.mouseChildren = diff ==0;
												}
                                                _scrollContent.x += diff;
                                        }
                                        
                                        if (_scrollContent.width < panelWidth && _scrollContent.x < 0) {
                                                inertia.x = 0;
                                                _scrollContent.x *= 0.8;
                                                if (_scrollContent.x > -1) {
                                                        _scrollContent.x = 0;
                                                }
                                        }
                                        
                                        if (Math.abs(inertia.x) > 1) {
                                                _scrollContent.x += inertia.x;
                                                inertia.x *= 0.75;
                                        } else {
                                                inertia.x = 0;
                                        }
                                        
										/*
                                        if (inertia.x != 0) {
                                                if (_scrollBarH.alpha < 1) {
                                                        _scrollBarH.alpha = Math.min(1, _scrollBarH.alpha+0.1);
                                                }
                                                _scrollBarH.x = panelWidth * Math.min(1, (-_scrollContent.x / _scrollContent.width));
                                        } else {
                                                if (_scrollBarH.alpha > 0) {
                                                        _scrollBarH.alpha = Math.max(0, _scrollBarH.alpha-0.1);
                                                }
                                        }
										*/
                                }
								
                                
                        } /*else {
                                
							
                                if (useVertical) {
                                        if (_scrollBarV.alpha < 1) {
                                                _scrollBarV.alpha = Math.min(1, _scrollBarV.alpha+0.1);
                                        }
                                        _scrollBarV.y = panelHeight * Math.min(1, (-_scrollContent.y / _scrollContent.height));
                                }
                                
                                if (useHorizontal) {
                                        if (_scrollBarH.alpha < 1) {
                                                _scrollBarH.alpha = Math.min(1, _scrollBarH.alpha+0.1);
                                        }
                                        _scrollBarH.x = panelWidth * Math.min(1, (-_scrollContent.x / _scrollContent.width));
                                }
                        }*/
                }
		
	
		public function destroy():void {
		
			_targContainer.removeEventListener(ENABLE, enableTouchScroll);
			_targContainer.removeEventListener(DISABLE, disableTouchScroll);
			
			_targContainer.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
            _targContainer.removeEventListener(Event.ENTER_FRAME, handleEnterFrame, false)
            _targContainer.removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			
			if (_targContainer.stage) {
			  _targContainer.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
              _targContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			}

			
		}
		
	}

}