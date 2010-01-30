package sg.camolite.display {
	import camo.core.display.AbstractDisplay;
	import flash.geom.Rectangle;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IResizable;
	// Non-wildcard
	//import flash.display.DisplayObject;
	//import flash.display.Sprite;
	// Wildcard import necessary in certain situations instead of the above (for Flash in particular)
	 import flash.display.*;  
	 import sg.camo.interfaces.IReflectClass;
	 
	/**
	* Base class extending from AbstractDisplay that supports a base to add and remove behaviours
	* on itself, including GBase implementation.
	* 
	* @see sg.camo.interfaces.IBehaviour
	* @see sg.camolite.display.GBase
	*
	* @author Glenn Ko
	*/
	public class GBaseDisplay extends AbstractDisplay implements IBehaviouralBase, IResizable, IReflectClass  {
		
		protected var _behaviours:Object = { };
		
		/**
		 * Constructor.
		 * @param	customDisp	 (Optional) A custom sprite you might want to inject to 
		 *   to be set as the <code>display</code> sprite reference.
		 * 
		 */
		public function GBaseDisplay(customDisp:Sprite = null) {
			display = customDisp != null ? $addChild(customDisp) as Sprite : display;
			super(this);
		}
		
		// -- IReflectClass
		
		public function get reflectClass():Class {
			return GBaseDisplay;
		}

		
		/**
		 * <b>[Stage instance]</b> to hook up <code>display</code> sprite reference.
		 */
		public function set displaySprite(spr:Sprite):void {
			display = spr;
		}
		
		
		/**
		 * Sets mask display object of nested child display and adds mask to local displaylist
		 */
		public function set displayMask(disp:DisplayObject):void {
			getDisplaySprite().mask = disp;
			$addChild(disp);
		}
		
		/**
		 * Attempt to create a new <code>display</code> sprite instance if no instance of it is currrently found.
		 * @return	A new Sprite instance or the current <code>display</code> Sprite instance
		 */
		protected function getDisplaySprite():Sprite {
			var chk:Sprite = display!=null ? display : $getChildByName("displaySprite") as Sprite;
			return  chk != null ? chk : createNewDisplaySprite(); 
		}
		/**
		 * Force the creation of a new <code>display</code> sprite reference.
		 * @return	A fresh new Sprite() instance, which is added to the local display list immediately.
		 */
		protected function createNewDisplaySprite():Sprite {
			display = new Sprite();
			$addChild(display);
			return display;
		}
		
		// Public interface IBehaviouralBase
		public function addBehaviour(beh:IBehaviour):void {
			_behaviours[beh.behaviourName] = beh;
			beh.activate(this);
		}
		public function removeBehaviour(beh:IBehaviour):void {
			if (beh == null) return;
			beh.destroy();
			delete _behaviours[beh.behaviourName]
		}
		public function getBehaviour(behName:String):IBehaviour {
			return _behaviours[behName];
		}
		/**
		 * Protected method to allow extended classes to immediately add behaviours to specific
		 * display objects and activate those behaviours immediately. Also registers display behaviour
		 * into it's own internal registry of behaviours (with a unique id based off the display object's name)
		 * to facilitate garbage collection. <br/>
		 * <i>NOTE: It is assumed every registered target display object instance has a unique
		 * name to facilitate this process.<i/>
		 * @param	beh		The behaviour to use and activate over the target.
		 * @param	targ	(DisplayObject) A DisplayObject instance to use as the target.
		 */
		protected function addDisplayBehaviourTo(beh:IBehaviour, targ:DisplayObject):void {
			_behaviours[beh.behaviourName + "_" + targ.name] = beh;
			beh.activate(targ);
		}
		
		/**
		 * Protected method to allow extended classes to remove an assosiated behaviour of a specific
		 * display object.<br/>
		 * <i>NOTE: It is assumed the target has <b>not</b> changed it's name prior to when it was activated,
		 * as this same name is used to retrieve back the assosiated behaviour for the particular display object target.
		 * @param	behaviourName	The assosiated behaviour to remove and dispose off.
		 * @param	targ	(DisplayObject) The targetted DisplayObject instance
		 */
		protected function removeDisplayBehaviourOf(behaviourName:String, targ:DisplayObject):void {  // we assume targ name doesn't change.
			var key:String = behaviourName + "_" + targ.name;
			var beh:IBehaviour = _behaviours[key];
			if (beh == null) {
				return;
			}
			beh.destroy();
			delete _behaviours[key];
		}
		

		public function set spacer(spr:Sprite):void {
			resize(spr.width, spr.height);
			spr.visible = false;
		}
		
		override public function get width():Number {
			return _width > 0 ? _width : display.width > _width ? display.width : _width;  
		}
		
		override public function get height():Number {
			return _height > 0 ?  _height : display.height > _height  ? display.height : _height; 
		}
		
		/**
		 * Define specific width/height measurements through the resize method
		 * @param	w	A valid width higher than 0 to take effect.
		 * @param	h	A valid height higher than 0 to take effect.
		 */
		override public function resize(w:Number, h:Number):void {
			_width = w > 0 ? w : _width;
			_height = h > 0 ? h : _height;
		}
		
		/**
		 * Clears all behaviours as well.
		 */
		override public function destroy():void {
			var hash:Object = _behaviours;
			for (var i:String in hash) {
				(hash[i] as IBehaviour).destroy();
			}
			_behaviours  = null;
			
			super.destroy();
		}
		
		

		
	}
	
}