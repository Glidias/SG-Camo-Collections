package sg.camo.interfaces 
{
	
	/**
	* IScrollProxy interface is a "decorator" interface that targets a particular set of IScrollable content to
	* run a particular scrolling implementation on behalf of the IScrollable content itself. 
	* <br/><br/>
	* This allows many different types of scrolling implementations to work on varying types of scrollable content, since they are
	* factored out to different "decorator" classes, which can be re-used again or altered differently if required.
	* 
	* @author Glenn Ko
	*/
	public interface IScrollProxy extends IScrollable
	{
		function destroy():void;
		function set target (val:IScrollable):void
		function get target():IScrollable;
	
	}
	
}