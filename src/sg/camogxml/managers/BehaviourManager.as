package sg.camogxml.managers 
{
	import flash.display.Shape;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camogxml.api.IDTypedStack;
	/**
	 *  A stack of behaviour sources for the application, from which a behaviour can be retrieved.
	 * 
	 * @see sg.camo.interfaces.IBehaviour
	 * 
	 * @author Glenn Ko
	 */
	public class BehaviourManager extends DefinitionsManager implements IDTypedStack, IBehaviouralBase
	{
		
		private var liveBehaviours:Dictionary = new Dictionary(); 
		
		public function BehaviourManager() 
		{
			super();
		}
		
		/**
		 * Adds a behaviour directly to the manager based on an actual live instance.
		 * <br/> <br/>
		 * Behaviours can be added as an actual live instance, assuming the behaviour instance itself 
		 * can manage their own activate() process through some built-in class factory/cloning/pooling/management
		 * process to allow the same behaviour to be applied to multiple instances.
		 * <br/><br/>
		 * Live behaviours are extremely unique and only 1 instance of it is normally used in an application.
		 * It would replace any behaviour definitions in the stack that uses the same name, and will 
		 * always be "locked" down to using that live behaviour instead.
		 * 
		 * @param	beh		A live behaviour instance to add to the manager
		 */
		public function addBehaviour(beh:IBehaviour):void {
			liveBehaviours[beh.behaviourName] = beh;
		}
		/**
		 * Removes a live behaviour
		 * @param	beh
		 */
		public function removeBehaviour(beh:IBehaviour):void {
			delete liveBehaviours[beh.behaviourName];
		}
		
		/**
		 * Retrieves behaviour instance. If a live behaviour is found, it is used over anything else. Otherwise,
		 * attempts to instantiate a static behaviour through a linked class reference given a certain behaviour name.
		 * @param	behName
		 * @return
		 */
		public function getBehaviour(behName:String):IBehaviour {
			return liveBehaviours[behName] ? liveBehaviours[behName] : (new (getDefinition(behName))() as IBehaviour) || new DummyBehaviour(behName);
		}
		
		
		override public function getDefinition(str:String):Object {
			
			var chkClass:Class = super.getDefinition(str) as Class;
			if (chkClass == null) throw new Error("BehaviourManager getDefinition failed for:"+str);
			return chkClass;
		}
		

		
	}

}

import sg.camo.interfaces.IBehaviour;


internal class DummyBehaviour implements IBehaviour {
	
	public function DummyBehaviour(behRequest:String="{some request}"):void {
		throw new Error("BehaviourManager DummyBehaviour created:. No behaviour found for: " +  behRequest);
	}
	
	public function get behaviourName():String {
		return "DummyBehaviour";
	}
		
	public	function activate(targ:*):void {
		
	}
	public function destroy():void {
		
	}
}