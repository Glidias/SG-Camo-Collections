package sg.camo.scrollables {
	import sg.camo.interfaces.IScrollable;
	
	/**
	* A Base Helper class to retrieve "snaps to item-length" measurements.
	* <br/><br/>
	* If scroll ratio is perfect zero, will floor snap, else if perfect 1, will ceiling snap,
	* else, calculate round-off.
	* 
	* @author Glenn Ko
	*/
	public class SnapGuide extends ScrollGuide {
		

		
		public function SnapGuide(targ:IScrollable) {
			super(targ);
		}

		override protected function getDestScrollH (ratio:Number):Number {
			var toSnap:Number = super.getDestScrollH(ratio);  //return toSnap;
			var magSnap:Number = toSnap < 0 ? -toSnap : toSnap;
			var rem:Number = magSnap  % itemLength;
			var floor:Boolean = ratio == 0 ? true : ratio == 1 ?  false : rem < itemLength * .5; 
			rem = floor  ? rem : itemLength - rem;
			var vec:int = floor ? -1 : 1;
			return itemLength > 0 ?   toSnap - vec * rem : toSnap;
		}

		override protected function getDestScrollV(ratio:Number):Number {
			var toSnap:Number = super.getDestScrollV(ratio);  //return toSnap;
			var magSnap:Number = toSnap < 0 ? -toSnap : toSnap;
			var rem:Number = magSnap  % itemLength;
			var floor:Boolean = ratio == 0 ? true : ratio == 1 ?  false : rem < itemLength * .5; 
			rem = floor  ? rem : itemLength - rem;
			var vec:int = floor ? -1 : 1;
			return itemLength > 0 ?   toSnap - vec * rem : toSnap;
		}
		

		protected final function $getDestScrollH(ratio:Number):Number {
			return super.getDestScrollH(ratio);
		}

		protected final function $getDestScrollV(ratio:Number):Number {
			return super.getDestScrollV(ratio);
		}

		
	}
	
}