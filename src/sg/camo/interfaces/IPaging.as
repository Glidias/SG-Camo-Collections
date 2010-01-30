package sg.camo.interfaces {
	
	/**
	* Basic interface for page handling
	* @author Glenn Ko
	*/
	public interface IPaging {
		
		 function gotoPage(index:int):Boolean;
		 function gotoPageByString(str:String):Boolean;
		 function nextPage():Boolean;
		 function prevPage():Boolean;
		
	}
	
}