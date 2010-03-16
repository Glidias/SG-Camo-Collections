package sg.camo.behaviour 
{
	/**
	 * Static class defining conventions used by behaviours to align stuff through
	 * string-based settings.

	 * @author Glenn Ko
	 */
	public class AlignValidation
	{
		public static const NONE:String = "none";
		public static const LEFT:String = "left";
		public static const MIDDLE:String = "middle";
		public static const CENTER:String = "center";
		public static const CENTRE:String = "centre";
		public static const RIGHT:String = "right";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		public static const VALUE_NONE:Number = -1;
		
	
		/**
		 * Validates and converts a string value to an align ratio number
		 * for horizontal alignment.
		 * @return	An align ratio value
		 */
		public static function toAlignRatio(str:String):Number {
			var ratio:Number = Number(str);
			if ( !isNaN(ratio) ) {
				if (ratio >=0 && ratio <= 1) return ratio;
			}
			switch (str) {
				case NONE: return VALUE_NONE;
				case LEFT: return 0;
				case MIDDLE: 
				case CENTRE: 
				case CENTER: return .5;
				case RIGHT: return 1;
				default:break;
			}
			return VALUE_NONE;
		}
		
		/**
		 * Validates and converts a string value to an align ratio number
		 * for vertical alignment.
		 * @return	An align ratio value
		 */
		public static function toVAlignRatio(str:String):Number {
			var ratio:Number = Number(str);
			if ( !isNaN(ratio) ) {
				return ratio;
			}
			switch (str) {
				case NONE: return VALUE_NONE;
				
				case MIDDLE: return .5;
				case TOP: return 0;
				case BOTTOM:  return 1;
				default:break;
			}
			return VALUE_NONE;
		}
		
		
	}

}