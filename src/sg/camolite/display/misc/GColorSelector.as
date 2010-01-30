package sg.camolite.display.misc
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.ILabler;
	import sg.camo.behaviour.SelectionBehaviour;
	import sg.camo.behaviour.WrapHLayoutBehaviour;
	import sg.camolite.display.GListDisplay;
	/**
	 * Still under construction, currently only supports static color swatches.
	 * 
	 * @author Glenn Ko
	 */
	public class GColorSelector extends GListDisplay implements ILabler
	{
		
		protected var _colorSets:Object = { };
		protected var _isDefaultColorSet:Boolean = true;
		
		public function GColorSelector() 
		{
			super();	
			addBehaviour(new WrapHLayoutBehaviour( 0));
	
			addBehaviour( new SelectionBehaviour() );
			
			//testing
		//	setLabels(0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF24, 0xFFFFFF, 0xEEFF00, 0xEEFF00, 0xEEFF00, 0xEEFF00, 0xEEFF00);
		}
		
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return GColorSelector;
		}
		
		protected function setToColorSet(id:String):void {
			var arr:Array = _colorSets[id];
			if (arr == null) {
			}
			
			while (numChildren > 0) { // temp, just clear and create new instance
				var child:DisplayObject = removeChildAt(0);
				if (child is IDestroyable) (child as IDestroyable).destroy();
			}
			_isDefaultColorSet = id === "";
			
			setLabels.apply(null, arr);
		}
		
		protected function addColorSwatch(color:uint):void {
			var i:int = numChildren;
			var disp:DisplayObject = addListItem("color" + i, "color" + i);
			var spr:Sprite = disp as Sprite;
			var swatch:DisplayObject = spr != null ?  spr.getChildByName("swatch") : null;
			swatch = swatch != null ? swatch : disp;
					
			var trans:ColorTransform = new ColorTransform();
			trans.color = color;
			swatch.transform.colorTransform = trans;
		}
		
		// generates list items of Color swatches. 
		// Requires: Looks for a child name of called "swatch" for list item, otherwise, colors the entire asset.
		public function setLabels( ...args ):Array {
			var len:int = args.length;
			for (var i:int = 0; i < len; i++) {
				var chk:Object = args[i];
				if  (chk is uint) {
					addColorSwatch(chk as uint);
				}
				else if (chk is String) {  
				
				}
				else if (chk is Bitmap) {
					//swatch.graphics.   // to do, process bitmap data types
				}
				else if (chk is BitmapData) {
					
				}
				else if (chk is XML) {
					_colorSets[chk.@id] = xmlListToColorArray(chk.color);
				}
				else if (chk is XMLList) {
					_colorSets[""] = xmlListToColorArray(chk as XMLList);
					setToColorSet("");
				}
			}
			return null;
		}
		
		protected function xmlListToColorArray(xmlList:XMLList ):Array {
			var len:int = xmlList.length();
			var arr:Array = [];
			for (var i:int = 0; i < len; i++) {
				arr.push( stringToUint(xmlList[i]) );
			}
			return arr;
		}
		

		
		private static function stringToUint(value : String) : uint
		{

			value = value.substr( - 6, 6 );
			var color : uint = Number( "0x" + value );
			return color;
			
		}
		
		
		
		
		
	}

}