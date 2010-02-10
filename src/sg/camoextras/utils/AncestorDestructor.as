package sg.camoextras.utils 
{
	import sg.camo.interfaces.IAncestorSprite;
	import sg.camo.interfaces.IDestroyable;
	/**
	 * Utility to automatically force-clean-up all of IAncestorSprite's own display list children.
	 * @author Glenn Ko
	 */
	public class AncestorDestructor
	{
	
		/**
		 * Searches  ancestor sprite's own display list for any IDestroyable items to perform cleaning-up.
		 * @param	ancSprite
		 */
		public static function destroyAncestorSprite(ancSprite:IAncestorSprite):void {
			var i:int = ancSprite.$numChildren;
			while (--i > -1) {
				var chkDestroy:IDestroyable = ancSprite.$getChildAt(i) as IDestroyable;
				if (chkDestroy != null) chkDestroy.destroy();
			}
		}
		
	}

}