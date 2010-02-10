package sg.camolite.display.impl
{
	import camo.core.display.CamoDisplay;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import sg.camo.interfaces.IReflectClass;
	/**
	 * Flash linkage-library based CamoDisplay class base. Uses ancestor child at depth level zero
	 * as the contents to be inserted into display.
	 * @author Glenn Ko
	 */
	public class CamoContainer extends CamoDisplay implements IReflectClass
	{
		
		public function CamoContainer() 
		{
			super();
			
			$addEventListener(Event.ADDED_TO_STAGE, onInitialAddToStage, false , 1, true);
		}
		
		public function get reflectClass():Class {
			return CamoContainer;
		}
		
		protected function onInitialAddToStage(e:Event):void {
			$removeEventListener(Event.ADDED_TO_STAGE, onInitialAddToStage);		
			// assumption made to retrieve ancestor child which must be at depth zero
			var ancChild:DisplayObject = $getChildAt(0);
			if (!ancChild || ancChild ===display || ancChild === maskShape) return;
			width = ancChild.width ;
			height = ancChild.height;
			addChild(ancChild);
		}
		
	}

}