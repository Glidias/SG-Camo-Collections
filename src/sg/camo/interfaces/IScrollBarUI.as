package sg.camo.interfaces {
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	/**
	* Public interface that can optionally be implemented by scrollbar UI components to allow direct
	* access to the scrollbar's common inner parts and settings, and also for manually updating/resetting it.
	* 
	* @author Glenn ko
	*/
	public interface IScrollBarUI  {
		
		// scroll bar parts
		function set scrollTrack(spr:Sprite):void;
		function get scrollTrack():Sprite;
		function set scrollScrub(spr:Sprite):void;
		function get scrollScrub():Sprite;
		function set scrollUp(obj:InteractiveObject):void
		function get scrollUp():InteractiveObject;
		function set scrollDown(obj:InteractiveObject):void;
		function get scrollDown():InteractiveObject;
		
		// update/resetting of scrollbar
		function updateScrollbar():void;
		function resetScrollbar():void;
		
		// hold/move intervals for scrollUp/scrollDown buttons
		function set holdInterval(delay:Number):void;
		function get holdInterval():Number;
		function set moveInterval(delay:Number):void;
		function get moveInterval():Number;
		
		// fit scrollbar to content
		function get autoFit():Boolean;	
		function set autoFit(fit:Boolean):void;
		// fit scroll scrub height to scroll track based on content
		function get autoFitScrub():Boolean;
		function set autoFitScrub(fit:Boolean):void;
		
		
	}
	
}