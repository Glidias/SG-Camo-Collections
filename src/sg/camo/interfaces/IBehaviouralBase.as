package sg.camo.interfaces {
	
	/**
	* A behaviour source holder.
	* 
	* @author Glenn Ko
	*/
	public interface IBehaviouralBase {
		
		function addBehaviour(beh:IBehaviour):void;
		function removeBehaviour(beh:IBehaviour):void;
		function getBehaviour(behName:String):IBehaviour;
		
	}
	
}