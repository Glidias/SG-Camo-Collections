package sg.camolite.display {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import sg.camo.events.SelectionEvent;
	import sg.camo.interfaces.IList;
	import sg.camo.interfaces.ISelectable;
	import sg.camo.interfaces.IText;
	import sg.camo.behaviour.SelectionBehaviour;
	import sg.camo.interfaces.ITextField;
	import sg.camolite.display.GOpener;
	
	import flash.events.MouseEvent;
	
	/**
	* Standard UI Dropdown
	* @author Glenn Ko
	*/
	public class GDropDown extends GOpener implements IList, IText {
		
		/** @private */
		protected var _iList:IList;
		/** @private */
		protected var _textField:TextField;
		/** @private */
		protected var _textSetter:IText;
		/** @private */
		protected var _pStage:Stage;
		/** @private */
		protected var _curSelected:DisplayObject;
		
		public static var _CUR_OPENED:GDropDown;
		
		public function GDropDown(customDisp:Sprite=null) {
		
			super(customDisp);
			_iList = display as IList;
			addEventListener( SelectionEvent.SELECT, selectionHandler, false , 0, true);
			addBehaviour( new SelectionBehaviour() );
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GDropDown;
		}
		
		private var _isOpening:Boolean = false; 
		/** @private */
		override protected function openBtnClickHandler(e:MouseEvent):void {
			if (_CUR_OPENED && _CUR_OPENED != this) {
				_CUR_OPENED.doClose();
				_CUR_OPENED = null;
			}
			if (_isOpen) return;
			
			doOpen();
			
			e.stopPropagation();
			
		}
		/** @private */
		override protected function doOpen():void {
			super.doOpen();
			_CUR_OPENED = this;
			_pStage = stage;
			_pStage.addEventListener(MouseEvent.CLICK, closeFromStageHandler, false, 0, true);
		}
		/** @private */
		override protected function doClose():void {
			super.doClose();
			closeStage();
		}
		/** @private */
		protected function closeFromStageHandler(e:Event):void {
			doClose();
			_CUR_OPENED = null;
		}
		/** @private */
		protected function closeStage():void {
			if (_pStage != null) {
				_pStage.removeEventListener(MouseEvent.CLICK,closeFromStageHandler);
				_pStage = null;
			}
		}
		
		override public function destroy():void {
			super.destroy();
			closeStage();
		}
		
		/** @private */
		protected function selectionHandler(e:SelectionEvent):void {
			_curSelected = e.curSelected as DisplayObject;
			if (_curSelected is IText) text = (_curSelected as IText).text;
		}
		
		public function set text(str:String):void {
			_textField.text = str;
			if (_textSetter) _textSetter.text = str;
		}
		public function get text():String {
			return _textField.text;
		}
		/** <b>[Stage instance]</b> to hook up text label */
		public function set txtLabel(txtField:TextField):void {
			_textField = txtField;
		}
		public function get txtLabel():TextField {
			return _textField;
		}
		
		public function set textHolder(val:ITextField):void {
			txtLabel = val.textField;
		}
		
		public function set textSetter(value:IText):void 
		{
			_textSetter = value;
		}
		
		
		public function addListItem (label:String, id:String):DisplayObject {
			return _iList.addListItem(label, id);
		}
		public function removeListItem (id:String):DisplayObject {
			return _iList.removeListItem(id);
		}
		
		
		
		
		
	}
	
}