package sg.camo.behaviour 
{
	
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import sg.camo.interfaces.ITextField;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FindTarget
	{
		
	
		public static function getPseudoTarget(targ:Object, str:String):* {
			switch (str) {
				case "display": return targ is IDisplay ? (targ as IDisplay).getDisplay() : null;
				case "textField":
				case "text": return targ is TextField ? targ : targ is ITextField ? (targ as ITextField).textField : targ is DisplayObjectContainer ? (targ as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
				default: return targ;
			}
		}
		
		public static function findTextField(targ:Object):TextField {
			// duplicate of "text" above with casting
			 return targ is TextField ? targ as TextField : targ is ITextField ? (targ as ITextField).textField : targ is DisplayObjectContainer ? (targ as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
		}

		public static function find(targ:Object, searchStr:String):* {
			var searchArr:Array = searchStr.split(".");
			var curObj:Object = targ;
			var prop:String;
			var len:int = searchArr.length;
			for (var i:int = 0 ; i < len; i++) {
				searchStr = searchArr[i];
				var searchIndex:int;
		
				searchIndex = searchStr.indexOf("(");
				if (searchIndex > 0) {
					curObj = curObj[searchStr.substr(0, searchIndex)]();
					continue;
				}
				
				
				curObj = curObj[searchStr];
				
			}
			
			return curObj;
			
		}
		
		
		
		
	}

}