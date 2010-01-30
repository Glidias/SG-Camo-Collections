package sg.camolite.display 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import sg.camo.interfaces.ILabler;
	import sg.camo.interfaces.IListItem;
	import sg.camo.interfaces.IText;
	import sg.camo.interfaces.ITextField;
	
	/**
	 * A sprite allowing one to set up one main optional text label, and any other accompanying labels consistings
	 * of an array of 'textable' instances such as an array of textfields. Suitable for table rows.
	 * @author Glenn Ko
	 */
	public class GListItemLabler extends GTextSprite implements ILabler, IListItem
	{
		/** @private */
		protected var _labels:DisplayObjectContainer;
		protected var _id:String = "none";
		
		public function GListItemLabler() 
		{
			super();
			if (_textField == null) _textField = new TextField(); // prevent null reference 
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GListItemLabler;
		}
		
		
		public function set id(str:String):void {
			_id = str;
		}
		public function get id():String {
			return _id;
		}
		
		/**
		 * <b>Stage instance</b> to hook up  a container consisting of ONLY 'textable' instances.
		 * @param cont	A DisplayObjectContainer consisting of only IText/ITextFIeld or TextField instances,
		 * or individual sprites containing an instance name of "txtLabel" for the array of textfields.
		 */
		public function set labels(cont:DisplayObjectContainer):void {
			_labels = cont;
		}
		
		public function setLabels( ...args ):Array {
			if (_labels == null) {
				trace("GListItemLabler setLabels() failed! No labels sprite found!");
				return [];
			}
			var i:int = 0;
			var len:int = _labels.numChildren;
			var retArr:Array = [];
			
			while (i < len) {
				var strToShow:String = args[i];
				if (strToShow == null) {
					trace("GListItemLabler setLabels() warning :: Value of label is null!");
					strToShow = "";
				}
				var child:DisplayObject = _labels.getChildAt(i);
				if (child is IText) {
					(child as IText).text = strToShow;
					if (child is ITextField) retArr.push( (child as ITextField).textField );
				}
				else {
					var txtField:TextField =  	findTextField(child);
					if (txtField) {
						txtField.text = strToShow
						retArr.push(txtField);
					}
					else trace("GListItemLabler setLabels() warning :: No IText or TextField found!");
				}
				i++;
			}
			return retArr;
		}
		
		/**
		 * @see sg.camoextras.utils.FindTextField
		 * @param	disp
		 * @return
		 */
		public static function findTextField(disp:DisplayObject):TextField {
			return disp is TextField ? disp as TextField : disp is ITextField ? (disp as ITextField).textField : disp is DisplayObjectContainer ? (disp as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
		}
		
		
	}

}