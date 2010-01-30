package sg.camogxml.managers 
{
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDisplayRender;
	import sg.camo.interfaces.IDisplayRenderSource;
	import sg.camogxml.api.IDTypedStack;
	/**
	 * A set of retrievable display renders  based on a stack of IDisplayRenders instances.
	 * @author Glenn Ko
	 */
	public class DisplayRenderManager implements IDTypedStack, IDisplayRenderSource
	{
		protected var _idHash:Dictionary = new Dictionary();
		protected var _listHash:Dictionary = new Dictionary();
		
		public function DisplayRenderManager() 
		{
			
		}
		public function get stackType():Class {
			return IDisplayRender;
		}
		public function addItemById(item:*, id:String):void {
			if (item is IDisplayRenderSource) addDisplayRenderSource(item, id);
			if (item is IDisplayRender) addDisplayRender(item, id);
		}
		public function removeItemsById(id:String):void {
			removeDisplayRenders(id);
		}
		public function cloneStack(id:String = null):IDTypedStack {
			return null;
		}

		
		public function addDisplayRender(dispRender:IDisplayRender, id:String):void {
			var chkDict:Dictionary = _idHash[id] || createNewHash(id);
			var ider:String = dispRender.renderId;
			var node:Node = new Node( dispRender );
			var chkList:TailList = _listHash[ider] || createNewList(ider, node);
			if (!chkList.isNew) chkList.appendNode(node);
			chkDict[node] = chkList;	
		}
		public function addDisplayRenderSource(dispRenderSrc:IDisplayRenderSource, id:String):void {
			var payload:Array  = dispRenderSrc.getDisplayRenders();
			for (var i:String in payload) {
				trace("adding item:"+payload[i].renderId);
				addDisplayRender( payload[i], id);
			}
		}
		
		private function createNewHash(id:String):Dictionary {
			var hash:Dictionary = new Dictionary();
			_idHash[id] = hash;
			return hash;
		}
		private function createNewList(ider:String, node:Node):TailList {
			var list:TailList = new TailList(ider, node);
			_listHash[ider] = list;
			return list;
		}
		
		public function removeDisplayRenders(id:String):void {
			var chkDict:Dictionary = _idHash[id];
			if (!chkDict) return;
			
			for (var i:* in chkDict) {
				var list:TailList = chkDict[i];
				list.removeNode(i);
				if (list.tail == null) delete _listHash[list.id]; 
			}
			delete _idHash[id];
		}
		
		public function getDisplayRenders():Array {
			var retArr:Array =  [];
			var hash:Dictionary = _listHash;
			for (var i:* in hash) {
				retArr.push( hash[i].tail );
			}
			return retArr;
		}
		
		// -- IDisplayRenderSource
		public function getRenderById(id:String):IDisplayRender {
			var list:TailList = _listHash[id];
			return list ? list.tail.data : null;  // return dummy shape class
		}
		
	}

}
import sg.camo.interfaces.IDisplayRender;

internal class Node {
	
	public var next:Node;
	public var prev:Node;
	public var data:IDisplayRender;
	
	public function Node(data:IDisplayRender) {
		this.data = data;
	}
	
}


internal class TailList {
	
	public var tail:Node; 	
	public var id:String;
	/**
	 * A "stack" linked list which is only interested in the tail node and retrieving data from it.
	 */
	public function TailList(id:String, tail:Node):void {
		this.tail = tail;
		this.id = id;
	}
	
	public function appendNode(node:Node):void {  // assumes list always have a tail reference
		tail.next = node;
		node.prev = tail;
		tail = node;
	}
	
	private var _isNew:Boolean = true;  // hackish reference to use internally only..
	public function get isNew():Boolean {
		var ret:Boolean = _isNew;
		_isNew = false;
		return ret;
	}
		

	public function removeNode(node:Node):void {
		if (node === tail) {
			tail = node.prev;
			if (tail) tail.next = null;
			//trace("popping:" +tail);
		}
		node.prev = null;
		node.next = null;
		node.data = null;
	}
	
	/**
	* Unlock all ressources for the garbage collector.
	*/
	public function deconstruct():void
	{
		var node:Node = tail;
		var t:Node;
		while (node)
		{
			t = node.prev;
			node.next = null;
			node.prev = null;
			node.data = null;
			node = t;
		}
		tail = null;
	}
}