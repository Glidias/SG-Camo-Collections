package sg.camogxml.managers 
{
	import flash.display.Shape;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDefinitionGetter;
	import sg.camogxml.api.IDTypedStack;
	/**
	 * A set of retrievable class definitions running under multiple named stacks of class nodes.
	 * @author Glenn Ko
	 */
	public class DefinitionsManager implements IDTypedStack, IDefinitionGetter
	{
		protected var _idHash:Dictionary = new Dictionary();
		protected var _listHash:Dictionary = new Dictionary();
		
		public function DefinitionsManager() 
		{
			
		}
		public function get stackType():Class {
			return IDefinitionGetter;
		}
		public function addItemById(item:*, id:String):void {
			addDefinitionGetter(item, id);
		}
		public function removeItemsById(id:String):void {
			removeDefinitionsOf(id);
		}
		public function cloneStack(id:String = null):IDTypedStack {
			return null;
		}
		
		/**
		 * Adds a single  class definition manually
		 * @param	classeOrDef	The class definition or any object definition
		 * @param	ider	A custom definition id for gxml rendering 
		 * @param	id		The id to assosiate this 
		 */
		public function addDefinition(classeOrDef:Object, ider:String, id:String):void {
			var chkDict:Dictionary = _idHash[id] || createNewHash(id);
			var node:Node = new Node( classeOrDef );
			var chkList:TailList = _listHash[ider] || createNewList(ider, node);
			if (!chkList.isNew) chkList.appendNode(node);
			chkDict[node] = chkList;
		}
		
		/**
		 * Retrieves all available definitions from definition getter and dumps
		 * them into individual stacks for quick class definition retrieval 
		 * (retrieves latest definition from each stack).
		 * @param	classe	The IDefintionGetter from which all defintiions are retrieved from
		 * @param	id		The  id to assosiate all retrieved definitions. 
		 * 
		 * @see sg.camogxml.api.IDefinitionStack
		 * */
		public function addDefinitionGetter(iDefGetter:IDefinitionGetter, id:String):void {
			var chkDict:Dictionary = _idHash[id] || createNewHash(id);
			var arrOfDefs:Array = iDefGetter.definitions;
			var len:int = arrOfDefs.length;
			
			for (var i:int = 0 ; i < len; i++) {
				var ider:String = arrOfDefs[i] ;
				var node:Node = new Node( iDefGetter.getDefinition(ider ) );
				var chkList:TailList = _listHash[ider] || createNewList(ider, node);
				if (!chkList.isNew) chkList.appendNode(node);
				chkDict[node] = chkList;
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
		
		/**
		 * @see sg.camogxml.api.IDefinitionStack
		 * */
		public function removeDefinitionsOf(id:String):void {
			var chkDict:Dictionary = _idHash[id];
			if (!chkDict) return;
			//trace("removing defintions of:" + id);
			for (var i:* in chkDict) {
				var list:TailList = chkDict[i];
				//trace("removing node:" + i.data);
				list.removeNode(i);
				if (list.tail == null) delete _listHash[list.id]; 
			}
		
			delete _idHash[id];
		}
		
		public function getDefinition(str:String):Object {
			var list:TailList = _listHash[str];
			return list ? list.tail.data : null;  
		}
		public function hasDefinition(str:String):Boolean {
			return _listHash[str];
		}
		
		/**
		 * Retrieves all class definition names available for use from each stack.
		 */
		public function get definitions():Array {
			var retArr:Array = [];
			for (var i:* in _listHash) {
				retArr.push(i);
			}
			return retArr;
		}
		
	}
	
}

internal class Node {
	
	public var next:Node;
	public var prev:Node;
	public var data:Object;
	
	public function Node(data:Object) {
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