package sg.camolite.display {
	import flash.display.Sprite;
	import sg.camo.interfaces.IReflectClass;
	import sg.camo.interfaces.IResizable;
	
	/**
	* Base class or implementation for all SG-Camo-Lite display objects extending from native sprites or movieclips.
	* <br/><br/>
	* A "GBase" provides a means for both MovieClips and Sprites to explicitly define their own
	* custom width/heights. In many cases, this can come in useful because movieclip animation, masking, and
	* a whole lot of other factors can change the way <code>width</code> and <code>height</code> is received 
	* from a regular Flash displayObject.
	* 
	* @author Glenn Ko
	*/
	public class GBase extends Sprite implements IResizable, IReflectClass {
		
		/** Custom width. If set to lower than zero, it means no custom width measurement is supplied */
		protected var _width:Number = -1;
		/** Custom height. If set to lower than zero, it means no custom height measurement is supplied*/
		protected var _height:Number = -1;
		
		public function GBase() {
			super();
		}
		
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GBase;
		}
		
		/**
		 * Sets custom width value
		 */
		override public function set width(val:Number):void {
			_width = val;
		}
		
		/**
		 * Sets custom height value
		 */
		override public function set height(val:Number):void {
			_height = val;
		}
		
		/**
		 * Gets width
		 */
		override public function get width():Number {
			return _width > -1 ? _width : super.width;
		}
		/**
		 * Gets height
		 */
		override public function get height():Number {
			return _height > -1 ? _height : super.height;
		}
		
		/**
		 * Sets custom width and height values
		 * @param	w	A valid number higher or equal to 0 to take effect.
		 * @param	h   A valid number higher or equal to 0 to take effect.
		 */
		public function resize(w:Number, h:Number):void {
			_width = w >= 0 ? w : _width;
			_height = h >= 0 ? h : _height;
		}
		/**
		 * <b>[Stage instance]</b> to sets custom width and height (with <code>resize()</code> method) based on 
		 * spacer sprite's dimensions.
		 * (The spacer sprite is set to invisible by default)
		 */
		public function set spacer(spr:Sprite):void {
			resize(spr.width, spr.height);
			spr.visible = false;
		}
		
	}
	
}