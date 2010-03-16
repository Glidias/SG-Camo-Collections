package sg.camo.behaviour 
{
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.ITextField;
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class StateTextBehaviour extends StateBehaviour
	{
		public static const NAME:String = "StateTextBehaviour";
		
		public function StateTextBehaviour() 
		{
			
		}
		
		[Inject(name="textStyle")]
		override public function set propApplier(val:IPropertyApplier):void {
			super.propApplier = val;
		}
		
		[Inject(name="StateTextBehaviour.setPropertiesClass")]
		override public function setPropertiesClass(val:Class=null):void {
			super.setPropertiesClass(val);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override protected function getApplyTargetOf(targ:Object):Object {
			return targ is TextField ? targ  as TextField : targ is ITextField ? (targ as ITextField).textField : targ is DisplayObjectContainer ? (targ as DisplayObjectContainer).getChildByName("txtLabel") as TextField : null;
		}
		
		
		
	}

}