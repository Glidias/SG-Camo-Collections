package sg.camogaia.behaviour {
	import com.gaiaframework.api.IAsset;
	import com.gaiaframework.api.IMovieClip;
	import com.gaiaframework.api.INetStream;
	import com.gaiaframework.api.IDisplayObject;
	import com.gaiaframework.debug.GaiaDebug;
	import com.gaiaframework.events.AssetEvent;
	import com.gaiaframework.events.NetStreamAssetEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.NetStatusEvent;
	import flash.media.Video;

	import sg.camo.interfaces.IBehaviour;
	import sg.camogaia.api.IAssetPlayer;

	
	/**
	* Plays movieclips, FLVs, etc within a target container.
	* 
	* 
	* @author Glenn Ko
	*/
	public class AssetPlayerBehaviour implements IBehaviour, IAssetPlayer {
		
		/**
		 * The target container referernce
		 */
		protected var _targContainer:DisplayObjectContainer;
		/**
		 * A string-based hash of assets being registered by id. 
		 * This therefore implies that a unique id is required for each asset.<br/>
		 * <i>POSSIBLE TODO: Dictionary impl with weak keys?</i>
		 */
		protected var assets:Object = { };
		
		public static const NAME:String = "AssetPlayerBehaviour";

		/** @private */ protected var _curAsset:IAsset;
		/** @private */ protected var _curDisp:DisplayObject;
		/** @private */ protected var _curLoadAsset:IAsset;
	
		
		
		public function AssetPlayerBehaviour() {
			
		}
		
		public function get behaviourName():String {
			return NAME;
		}
		public function activate(targ:*):void {
			_targContainer = (targ as DisplayObjectContainer);
			if (_targContainer == null) {
				GaiaDebug.log("AssetPlayerBehaviour activate() halt. targ as DisplayObjectContainer is null!");
				return;
			}
			
		}
		
		/**
		 * @private
		 * @param	asset
		 */
		protected function clearCurAsset(asset:IAsset):void {
			if (asset is INetStream) {
				clearNsAsset(asset as INetStream);
			}
			else if (asset is IDisplayObject) {
				clearDisplayAsset(asset as IDisplayObject);
			}
			if (_curDisp!=null && _targContainer.contains(_curDisp) ) _targContainer.removeChild(_curDisp);
			_curDisp = null;
		}
		


		
		/**
		 * @private
		 * @param	asset
		 */
		protected function setVideo(asset:INetStream):void {
			asset.addEventListener(NetStreamAssetEvent.METADATA, onMetaData, false, 0, true);
			asset.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			asset.addEventListener(NetStreamAssetEvent.CUEPOINT, onCuePoint, false, 0, true);
			asset.play();
			_curDisp = new Video();
			fillContainer();
		}
		/**
		 * @private
		 * @param	asset
		 */
		protected function setDisplayObject(asset:IDisplayObject):void {
			_curDisp = asset.loader.content;
			fillContainer();
			if (_curDisp is MovieClip) {
				// start from 2nd frame onwards (assuming movieclip is stopped at 1st frame)
				(_curDisp  as MovieClip).gotoAndPlay(2); 
			}
		}
		/**
		 * @private
		 */
		protected function fillContainer():void {
			_curDisp.visible = true;
			_targContainer.addChild(_curDisp);
			
		}
		
		/**
		 * @private
		 * @param	asset
		 */
		protected function clearNsAsset(asset:INetStream):void {
			asset.close();
			asset.removeEventListener(NetStreamAssetEvent.METADATA, onMetaData, false);
			asset.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
			asset.removeEventListener(NetStreamAssetEvent.CUEPOINT, onCuePoint, false);
		}
		
		/**
		 * @private
		 * @param	asset
		 */
		protected function clearDisplayAsset(asset:IDisplayObject):void {
			if (_curDisp is MovieClip) {
				(_curDisp as MovieClip).gotoAndStop(1);
			}
		}
		

		// -- IAssetPlayer
		
		/**
		 * Adds asset to assets hash list for playing. (Each asset requires a unique id for the player.)
		 * @param	asset	An asset with a unique id to register it to the local hash
		 */
		public function addAsset(asset:IAsset):void {
			assets[asset.id] = asset;
		}
		
		/**
		 * Plays asset by id.
		 * @param	id	The id of asset to search for
		 */
		public function playAsset(id:String):void {
			var asset:IAsset = assets[id] as IAsset;
			if (asset == null) {
				GaiaDebug.log("AssetPlayerBehaviour playAsset() halt. targ as IAsset is null! id:"+id);
				return;
			}
			//
			if (_curAsset != null) {
				if (_curAsset.id === id) {
					return;
				}
				clearCurAsset(_curAsset);
			}
			
			
			_curAsset = asset;
			
			if (_curLoadAsset != null) {
				clearLoadAsset();
			}
				
			if (asset.getBytesTotal() > 0 && asset.getBytesLoaded() == asset.getBytesTotal() ) {
				processAsset(asset);
			//	GaiaDebug.log("Processing asset");
			}
			else {
				_curLoadAsset = asset;
				asset.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetLoaded, false, 0, true);
				asset.load();
			//	GaiaDebug.log("Loading asset:" + asset);
			}	
			
		}
		
		/**
		 * @private
		 */
		protected function clearLoadAsset():void {
			if (_curLoadAsset == null) return;  // double assertion check
			
			_curLoadAsset.abort();
			_curLoadAsset.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetLoaded);
			_curLoadAsset = null;
		}
		
		/**
		 * @private
		 * @param	asset
		 */
		protected function processAsset(asset:IAsset):void {
			if (asset is INetStream) {
					setVideo(asset as INetStream);
				}
			else if (asset is IDisplayObject) {
					setDisplayObject( asset as IDisplayObject);
				}
				
		}
		
		/**
		 * @private
		 * @param	e
		 */
		protected function onAssetLoaded(e:AssetEvent):void {
		
			processAsset(_curLoadAsset);
			_curLoadAsset = null;
		}
		
		/**
		 * This can be overwritten by extended classes to handle NetStatus events
		 * @param	e
		 */
		protected function onNetStatus(e:NetStatusEvent):void {
			/*
			if (e.info.code  == "NetStream.Play.Stop") {
			}*/
		}
		
		/**
		 * This can be overwritten by extended classes to handle cue point events
		 * @param	e
		 */
		protected function onCuePoint(e:NetStreamAssetEvent):void {
			/*
			name The name given to the cue point when it was embedded in the FLV file. 
			parameters A associative array of name/value pair strings specified for this cue point. Any valid string can be used for the parameter name or value. 
			time The time in seconds at which the cue point occurred in the video file during playback. 
			type The type of cue point that was reached, either navigation or event. 
			*/
			//e.info.
		}
		
		/**
		 * @private
		 * @param	e
		 */
		protected function onMetaData(e:NetStreamAssetEvent):void {
			e.target.removeEventListener(NetStreamAssetEvent.METADATA, onMetaData);
			
			var video:Video  = _curDisp as Video;
			var nsAsset:INetStream = _curAsset as INetStream;
			video.width = e.info.width;
			video.height = e.info.height;
			video.clear();
			video.attachNetStream(nsAsset.ns);
			

			
			nsAsset.play(0);
		}
		
		
		public function destroy():void {
			if (_curLoadAsset != null) {
				clearLoadAsset();
			}
			if (_curAsset != null) {
				clearCurAsset(_curAsset);
				_curAsset  = null;
			}
			_targContainer = null;
			assets = null;
		}
		
		
		
	}
	
}