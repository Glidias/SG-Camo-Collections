package sg.camo.behaviour 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.IEventDispatcher;
	import sg.camo.interfaces.IBehaviour;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import sg.camo.interfaces.IImg;
	import sg.camo.interfaces.ISrc;
	import sg.camo.ancestor.AncestorListener;
	
	/**
	 * Allow loading of image through loader ISrc url request or direct IImg reference.
	 * @author Glenn Ko
	 */
	public class LoadImgBehaviour implements IBehaviour, ISrc, IImg
	{
		
		protected var _loader:Loader; 
		protected var _src:String;
		
		public static const DEPTH_LOWEST:int = 0;
		public static const DEPTH_HIGHEST:int = -1;
		
		public var imgDepth:int = -1;
		private var _displayCache:DisplayObject;
		
		public static const NAME:String = "LoadImgBehaviour";
		
		private var _targetContainer:DisplayObjectContainer;
		
		public function LoadImgBehaviour() 
		{
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		public function activate(targ:*):void {
			_targetContainer = targ as DisplayObjectContainer;
			if (_targetContainer == null) {
				throw new Error("LoadImgBehaviour failed. Target isn't DisplayObjectContainer.");
				return;
			}
			
			if (_displayCache != null) {
				addDisplayCacheImage();
			}

			if (_targetContainer.stage) loadImage();
			else AncestorListener.addEventListenerOf(_targetContainer, Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void {
			AncestorListener.removeEventListenerOf(e.target as IEventDispatcher, Event.ADDED_TO_STAGE, onAddedToStage);
			loadImage();
		}
		
		// -- IImg
		public function get imageBitmap():Bitmap {
			return _displayCache as Bitmap;
		}
		public function set imageBitmap(bmp:Bitmap):void {
			_displayCache = bmp;
			
			if (_targetContainer == null) return;
			addDisplayCacheImage();
		}
		
		protected function addListeners(target : LoaderInfo) : void 
		{
			target.addEventListener(Event.COMPLETE, onImageLoad);
			target.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		}

		protected function removeListeners(target : LoaderInfo) : void 
		{
			target.removeEventListener(Event.COMPLETE, onImageLoad);
			target.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			if (_targetContainer!=null) _loader = null;
		}
		
		protected function onImageLoad(e:Event):void {
	
			var info : LoaderInfo = e.target as LoaderInfo;
			var loader : Loader = info.loader;
			removeListeners(info);
			
			if (_targetContainer == null) return;
			
			_displayCache = loader.content;
			addDisplayCacheImage();
			
			_targetContainer.dispatchEvent(e);
		}
		
		protected function addDisplayCacheImage():void {
			if (imgDepth < 0) _targetContainer.addChild(_displayCache);
			else {
				var targDepth:int = imgDepth < _targetContainer.numChildren ? imgDepth : _targetContainer.numChildren;
				_targetContainer.addChildAt(_displayCache, targDepth);
			}
		}
		
		protected function ioError(e:IOErrorEvent):void {
			throw new Error("ERROR: Could not load src image:"+e.text);
		}

		
		public function set src(url:String):void {
			
			_src = url;
			if (_targetContainer) loadImage();
		
		}
		
		protected function loadImage():void {
			if (_src == null) return;
			
			_loader = new Loader();
			addListeners(_loader.contentLoaderInfo);
			_loader.load ( new URLRequest(_src) );
		}
		
		public function get src():String {
			return _src;
		}
		
		public function destroy():void {
			if (_loader) {
				removeListeners(_loader.contentLoaderInfo);
			}
			_targetContainer = null;
		}
		
	}

}