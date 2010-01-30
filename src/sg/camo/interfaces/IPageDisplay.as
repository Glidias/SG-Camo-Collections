package sg.camo.interfaces 
{
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	/**
	 * Public interface for GPageDisplay or any page controller view that allows one to customise and add/remove pages to it.
	 * @author Glenn Ko
	 */
	public interface IPageDisplay extends IPaging
	{
		function set txtPageTitle(txtField:TextField):void;
		function addToPage(disp:DisplayObject, index:int=-1, visOnly:Boolean = false):void;
		function addToPageName(disp:DisplayObject, strName:String, visOnly:Boolean = false):void;
		function setPageTitles(...args):void;
		function set initNumPages(num:int):void;
	}

}