package sg.camo.behaviour 
{
	import sg.camo.interfaces.IBehaviour;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ScrollViewBehaviour implements IBehaviour 
	{
		public static const NAME:String = "ScrollViewBehaviour";
		
		public function ScrollViewBehaviour() 
		{
			
		}
		
		
		public function activate():void {
			
		}

		public function get behaviourName():String {
			return NAME;
		}
		

		public function activate(targ:*):void;
		
		public function destroy():void {
			
		}
		
	}

}