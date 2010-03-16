package sg.camo.behaviour 
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import sg.camo.interfaces.IBehaviour;
	
	/**
	 * Base boiler-plate class for proxy behaviours
	 * @author Glenn Ko
	 */
	public class AbstractProxyBehaviour extends Proxy implements IBehaviour
	{
		
		public function AbstractProxyBehaviour(self:AbstractProxyBehaviour) 
		{
			if (self != this) throw new Error("AbstractProxyBehaviour cannot be instantiated directly!")
		}
		
		public function get behaviourName():String {
			throw new Error("AbstractProxyBehaviour cannot have a behaviour name! Please override.");
		}
		
		
		
		public function activate(targ:*):void {
			
		}
		
		
		public function destroy():void {
		
		}
		
		
		// -- Proxy
		
		override flash_proxy function callProperty (name:*, ...rest) : * {
		
		}
		
		
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			return $deleteProperty(name);
		}
		protected function $deleteProperty(name:*):Boolean {
			return false;
		}


		override flash_proxy function getProperty(name : *) : *
		{
			return $getProperty(name);
		}
		protected function $getProperty(name:*):* {
			return null;
		}



		override flash_proxy function setProperty(name : *, value : *) : void
		{ 
			$setProperty(name, value);
		}
		protected function $setProperty(name:*, value:*):void {
			
		}
		
		// -- Object
		
		public function toString():String {
			return "["+behaviourName+"]"
		}
		
	}

}