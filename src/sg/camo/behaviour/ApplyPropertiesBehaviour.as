package sg.camo.behaviour 
{
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPseudoBehaviour;
	/**
	 * Just a pseudo behaviour to apply properties onto target immediately upon
	 * activation.
	 * @author Glenn Ko
	 */
	public class ApplyPropertiesBehaviour extends AbstractProxyBehaviour implements IPseudoBehaviour
	{
		public function set pseudoState(str:String):void { };
		
		
		protected var _properties:Object = { };
		protected var _propApplier:IPropertyApplier;
		
		public static const NAME:String = "ApplyPropertiesBehaviour";
		
		public function ApplyPropertiesBehaviour() 
		{
			super(this);
		}
		
		[Inject(name="Proxy.properties")]
		public function setPropertiesClass(val:Class=null):void {
			if (val!=null) propertiesClass = val;
		}
		public function set propertiesClass(val:Class):void {
			_properties = new val();
		}
		
		[Inject]
		public function set propApplier(val:IPropertyApplier):void {
			_propApplier = val;
		}
		public function get propApplier():IPropertyApplier {
			return _propApplier;
		}
		
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override public function activate(targ:*):void {
			_propApplier.applyProperties(targ, _properties);
		}
		

		override protected function $getProperty(name:*):* {
			return _properties[name];
		}

		override protected function $setProperty(name:*, value:*):void {
			_properties[name] =  value;
		}
		
		
		
	}

}