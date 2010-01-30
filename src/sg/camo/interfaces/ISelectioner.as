package sg.camo.interfaces {
	
	/**
	* An interface that can actively make single selections based on string id.
	* @author Glenn Ko
	*/
	public interface ISelectioner extends ISelection {
		
		function set selection(str:String):void;
		
	}
	
}