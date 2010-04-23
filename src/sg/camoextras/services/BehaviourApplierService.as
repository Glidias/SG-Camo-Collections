package sg.camoextras.services
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IBehaviour;
	import sg.camo.interfaces.IBehaviouralBase;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IPropertyApplier;
	/**
	 * Behaviour applier service to apply behaviours through XML nodes and inline attributes for each node
	 * to a display render (and other display object references under it), and also provides
	 * a possible reference to those behaviours if "behaviourKey" attribute is specified for the behaviour node to
	 * allow for a name-based lookup through IBehaviouralBase's getBehaviour(name:String) method.
	 * 
	 * @author Glenn Ko
	 */
	
	[Inject(name="gxml", name="gxml", name="gxml.attribute", name="gxml")]
	public class BehaviourApplierService implements IBehaviouralBase, IDestroyable
	{
		
		protected var _behaviourDict:Dictionary;
		
		public function BehaviourApplierService(xml:XML, displayRender:IDisplayRender, propApplier:IPropertyApplier, behaviourSource:IBehaviouralBase) 
		{
			if (xml == null) return;
			_behaviourDict = new Dictionary();
			
			var xmlList:XMLList = xml.*;
			var len:int = xmlList.length();
			for (var i:int = 0; i < len; i++) {
				var axml:XML = xmlList[i];
				if (axml.@behaviourName == undefined)  {
					trace("BehaviourApplierService:: no behaviourName specified for:"+axml.toXMLString());
					continue;
				}
		
				var beh:IBehaviour = behaviourSource.getBehaviour( axml.@behaviourName );
				if (beh == null) {
					trace("BehaviourApplierService:: could not find behaviour for:" + axml.toXMLString());
					continue;
				}
			
				var targ:DisplayObject = axml.@id != undefined ? displayRender.getRenderedById(axml.@id) :  displayRender.rendered;
				if (targ == null) {
					trace("BehaviourApplierService:: could not find DisplayObject target for:" + axml.toXMLString());
					continue;
				}
				
				var key:* = axml.@behaviourKey != undefined ? axml.@behaviourKey.toString() : true;
				_behaviourDict[beh] = key;
				if (key is String) _behaviourDict[key] = beh;
				
				var obj:Object = { };
				var attName:String;
				var attributes:XMLList = axml.attributes();
				var alen:int = attributes.length();
				while (--alen > -1) {
					attName = String( attributes[alen].name() );
					obj[attName] = attributes[alen].toString();
				}
				attributes = axml.*;
				alen = attributes.length();
				while (--alen > -1) {
					attName = String( attributes[alen].name() );
					obj[attName] = attributes[alen].toString();
				}
				propApplier.applyProperties(beh, obj);
				
				
				beh.activate(targ);
				
			}
		}
		
		public function addBehaviour(beh:IBehaviour):void {
			// not being implemented. Use xml to define behaviours to add upon construction.
		}
		public function removeBehaviour(beh:IBehaviour):void {
			if (_behaviourDict[beh]) {
				if ( _behaviourDict[beh] is String) delete _behaviourDict[ _behaviourDict[beh]   ];
				beh.destroy();
			}
			else trace("BehaviourApplierService:: removeBehaviour could not find matching behaviour in registry!");
		}
		public function getBehaviour(behName:String):IBehaviour {
			return _behaviourDict[behName];
		}
		
		/**
		 * Quickly disposes off class and all behaviours. The class is no longer usable after this
		 */
		public function destroy():void {
			for (var i:* in _behaviourDict) {
				if ( !(i is String) ) {
					i.destroy();
				}
			}
			_behaviourDict = null;
		}
	
		

		
	}

}