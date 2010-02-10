package sg.camolite.display.impl 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import sg.camo.behaviour.LoadImgBehaviour;
	import sg.camo.interfaces.ISrc;
	import sg.camolite.display.GTextMovieClip;
	/**
	 * As2-like movieclip with ability to load content, and built-in  text support
	 *
	 * 
	 * @author Glenn Ko
	 */
	public class GTextMovieClipLoader extends GTextMovieClip implements ISrc
	{
		
		public static const DEPTH_LOWEST:int = LoadImgBehaviour.DEPTH_LOWEST;
		public static const DEPTH_HIGHEST:int = LoadImgBehaviour.DEPTH_HIGHEST;
		
		protected var loadImgBehaviour:LoadImgBehaviour  = new LoadImgBehaviour();
		
		
		public function GTextMovieClipLoader() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			
		}
		
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			loadImgBehaviour.activate(this);
		}
		
		public function set src(str:String):void {
			loadImgBehaviour.src = str;
		}
		public function get src():String {
			return  loadImgBehaviour.src;
		}
		
		public function set imgDepth(val:int):void {
			loadImgBehaviour.imgDepth = val;
		}
		public function get imgDepth():int {
			return loadImgBehaviour.imgDepth;
		}
		
		
		
	}

}