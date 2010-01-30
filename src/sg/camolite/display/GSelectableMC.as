package sg.camolite.display
{
	import flash.events.Event;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.notifications.GDisplayNotifications;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	
	import sg.camo.interfaces.ISelectable;
	import sg.camo.interfaces.IResizable;
	
	import flash.display.Sprite;

	
	/**
	 * A basic MovieClip that stores it's own selected state.
	* <br/><br/>
	* Also incorporates <code>GBase</code> structure.
	* @see sg.camolite.display.GBase
	* 
	 * @author Glenn Ko
	 */
	public class GSelectableMC extends MovieClip implements ISelectable, IResizable, IReflectClass
	{
		
		/**  @private */
		protected var _selected:Boolean = false;
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		
		/** @private */
		protected var _selectEventType:String;
		
		/**
		 * Constructor
		 * @param	initEventType	Defaulted to MouseEvent.CLICK. The type of event to listen to which triggers a selection notification
		 */
		public function GSelectableMC(initEventType:String=null) 
		{
			super();
			_selectEventType = initEventType  ? initEventType : MouseEvent.CLICK;
			addEventListener (_selectEventType, selectionClickHandler, false, 0, true);
		}
		
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GSelectableMC;
		}
		
		/**
		 * Resets listener to a new type for triggering a selection click
		 */
		public function set selectEventType(type:String):void {
			removeEventListener(_selectEventType, selectionClickHandler);
			addEventListener(type, selectionClickHandler, false, 0, true);
		}
		
		public function destroy ():void {
			removeEventListener (_selectEventType, selectionClickHandler, false);
			super.destroy ();
		}
		

		public function set spacer(spr:Sprite):void {
			resize(spr.width, spr.height);
			spr.visible = false;
		}
		
		override public function get width():Number {
			return _width > 0 ? _width : super.width;
		}
		override public function get height():Number {
			return _height > 0 ? _height : super.height;
		}
		public function resize(w:Number, h:Number):void {
			_width = w > 0 ? w : _width;
			_height = h > 0 ? h : _height;
		}
		
		/**
		 * Dispatches DisplayNotifications.SELECT event in response to a some "selection click".
		 * @param	e	
		 */
		protected function selectionClickHandler (e:MouseEvent):void {
			dispatchEvent ( new Event (GDisplayNotifications.SELECT, true) );
		}
		
		public function set selected (bool:Boolean):void {
			_selected = bool;
		}
		public function get selected ():Boolean {
			return _selected;
		}
		
		
	}
	
}