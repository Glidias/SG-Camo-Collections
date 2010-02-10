package sg.camogxml.render 
{
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDomainModel;
	/**
	 * Provides a behaviour source retrieval mechanism with provided application domain.
	 * 
	 * @author Glenn Ko
	 */
	public class GXMLBehaviours implements IBehaviouralBase, IDomainModel, IDestroyable, IDefinitionGetter
	{
		protected var _appDomain:ApplicationDomain;
		protected var _domainPrefix:String = "sg.camo.behaviour.";
		protected var _behHash:Dictionary = new Dictionary();

		public function GXMLBehaviours(appDomain:ApplicationDomain=null, xml:XML = null) 
		{
			_appDomain = appDomain ? appDomain : ApplicationDomain.currentDomain;
			if (xml != null) modelXML = xml;
		}
		public function set domainPrefix(str:String):void {
			_domainPrefix = str.charAt(str.length - 1) === "." ? str : str + ".";
		}
		public function get domainPrefix():String {
			return _domainPrefix.substr(0, _domainPrefix.length - 1);
		}
		
		// -- IDomainModel injection
		public function set appDomain(domain:ApplicationDomain):void {
			_appDomain = domain;
		}
		
		/**
		 * Pre-caches behaviour class definitions based on given XML format, to allow
		 * for adding definitions to stack
		 */
		public function set modelXML(xml:XML):void {
			var behList:XMLList = xml.children();
			_domainPrefix =  xml.@domainPrefix != undefined ? xml.@domainPrefix + "." : "sg.camo.behaviour.";
			
			for each(var node:XML in behList) {
				var classAttrib:String = node["@class"];
				if ( !Boolean(String(classAttrib)) )  {
					trace("GXMLBehaviours set modelXML() failed with no class attribute:"+node);
					continue;
				}

				var tryClass:Class = _hasDefinition(classAttrib) ? _getDefinition(classAttrib) : $hasDefinition(classAttrib) ? $getDefinition(classAttrib) : null;
				if (tryClass == null) {
					trace("GXMLBehaviours set modelXML() failed with no found class for:" + _domainPrefix+classAttrib);
					continue;
				}
				var key:String = node.@id || classAttrib;
				_behHash[key] = tryClass;
			}
		}
		
		// -- IDefinitionGetter

		public function getDefinition(behName:String):Object {
			return _behHash[behName] ? _behHash[behName]  :  _hasDefinition(behName) ? _getDefinition(behName) : $hasDefinition(behName) ? $getDefinition(behName) : DummyBehaviour;
		}
		public function hasDefinition(behName:String):Boolean { 
			return _behHash[behName] || _hasDefinition(behName) || $hasDefinition(behName);
		}
		public function get definitions():Array {
			var retArr:Array = [];
			var hash:Object = _behHash;
			for (var i:* in hash) {
				retArr.push(i);
			}
			return retArr;
		}
						
		// -- Helpers
		
		// -- To retrieve from specific domain and cache behaviour class
		/** @private */
		protected function _getDefinition(str:String):Class {
			var gotDot:Boolean = str.indexOf(".") > -1;
			var domainPrefix:String = gotDot ? "" : _domainPrefix;
			var key:String = gotDot ? domainPrefix + str : str;
			var retClass:Class =  _appDomain.getDefinition(domainPrefix + str) as Class;
			if (retClass) _behHash[key]  = retClass;
			return retClass;
		}
		/** @private */
		protected function _hasDefinition(str:String):Boolean {
			var domainPrefix:String = str.indexOf(".") > -1 ? "" : _domainPrefix;
			trace(domainPrefix + str);
			return _appDomain.hasDefinition(domainPrefix + str);
		}
		
		// -- To retrieve from current application domain and cache behaviour class
		/** @private */
		protected function $getDefinition(str:String):Class {
			var retClass:Class = ApplicationDomain.currentDomain.getDefinition(_domainPrefix +str) as Class;
			if (retClass) _behHash[str]  = retClass;
			return retClass;
		}
		/** @private */
		protected function $hasDefinition(str:String):Boolean {
			return ApplicationDomain.currentDomain.hasDefinition(_domainPrefix + str);
		}
		

		
		// -- IBehaviouralBase
		
		public function addBehaviour(beh:IBehaviour):void {
			//  not impl
		}
		public function removeBehaviour(beh:IBehaviour):void {
			//  not impl
		}
		public function getBehaviour(behName:String):IBehaviour {
			return _behHash[behName] ? new (_behHash[behName])() as IBehaviour :  _hasDefinition(behName) ? new (_getDefinition(behName))() as IBehaviour : $hasDefinition(behName) ? new ($getDefinition(behName))() as IBehaviour : new DummyBehaviour(behName);
		}
		
		
		// -- IDestroyable
		
		public function destroy():void {
			_behHash = null;
		}
		
		
	}
}


import sg.camo.interfaces.IBehaviour;


internal class DummyBehaviour implements IBehaviour {
	
	public function DummyBehaviour(behRequest:String="{some request}"):void {
		trace("GXMLBehaviours DummyBehaviour created:. No behaviour found for: " +  behRequest);
	}
	
	public function get behaviourName():String {
		return "DummyBehaviour";
	}
		
	public	function activate(targ:*):void {
		
	}
	public function destroy():void {
		
	}
}
