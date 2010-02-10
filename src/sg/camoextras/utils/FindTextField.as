package sg.camoextras.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import sg.camo.interfaces.ITextField;
	/**
	 * Utility that attempts to find a valid textfield reference within a particular DisplayObject
	 * @author Glenn Ko
	 */
	public class FindTextField
	{
		/**
		 * Force-find a textfield.
		 * <br/><br/>
		 * First checks given DisplayObject instance to whether it's a TextField. If it is, it returns the DisplayObject immediately.
		 * Else, checks if it's a ITextField, from which a valid TextField reference can be retreived. If still no TextField but the display object
		 * is a DisplayObjectContainer, attempts to make one last attempt to return <code>getChildByName("txtLabel") as TextField</code>. 
		 * @param	disp	The DisplayObject reference of an unknown nature.
		 * @return	A valid TextField reference.
		 */
		public static function find(disp:DisplayObject):TextField {
			return disp is TextField ? disp as TextField : disp is ITextField ? (disp as ITextField).textField : disp is DisplayObjectContainer ? (disp as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
		}
		
	}

}