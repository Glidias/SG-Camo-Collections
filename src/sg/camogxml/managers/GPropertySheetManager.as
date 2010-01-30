package sg.camogxml.managers 
{
	import camo.core.property.IPropertySelector;
	import camo.core.property.IPropertySheet;
	import flash.utils.Dictionary;
	import sg.camo.interfaces.IDestroyable;
	import sg.camo.interfaces.ISelectorSource;
	import sg.camogxml.api.IDTypedStack;
	/**
	 * A PropertySheetManager implemented as multiple arbituary lookup stacks for each selector 
	 * name retrieved from any newly added sheets. This manager doesn't store a reference
	 * to the added sheets or selector sources themselves, but simply extracts out the individual 
	 * selectors from each source into it's own local list of named retrieval stacks.
	 * 
	 * @author Glenn Ko
	 */
	public class GPropertySheetManager implements IDestroyable, IDTypedStack, ISelectorSource
	{
		/** @private */ 
		protected var _sampleSheet:IPropertySheet;
		/** @private */
		protected var _idHash:Dictionary = new Dictionary();	
		protected var _lookupHash:Dictionary = new Dictionary();
		
		/**
		 * Constructor
		 * @param	sampleSheetClasse	Sets up sample sheet through a class reference, from which 
		 * a default selector can be generated. 
		 */
		public function GPropertySheetManager(sampleSheetClasse:Class=null) 
		{
			if (sampleSheetClasse == null) return;
			sampleSheetClass = sampleSheetClasse;
		}
		public function get stackType():Class {
			return ISelectorSource;
		}
		public function addItemById(item:*, id:String):void {
			addSelectorSource(item, id);
		}
		public function removeItemsById(id:String):void {
			removeSelectorSources(id);
		}
		public function cloneStack(id:String = null):IDTypedStack {
			return cloneSelectorStack(id);
		}
		
		/**
		 * Sets up a sample sheet through a direct instance reference.
		 */
		public function set sampleSheet(sheet:IPropertySheet):void {
			_sampleSheet = sheet;
		}
		/**
		 * Sets up a sample sheet through a class definition. If the class doesn't implement
		 * the IPropertySheet interface, this method will fail.
		 */
		public function set sampleSheetClass(classe:Class):void {
			var trySheet:IPropertySheet = new classe() as IPropertySheet;
			if (trySheet == null) {
				trace("Warning! set sampleSheetClass() as IPropertySheet failed for:" + classe);
				return;
			}
			_sampleSheet = trySheet;
		}
	

		// -- ISelectorSource
				
		/**
		 * Retrieves a selector from individually named lookup stacks for each selector name in the array.<br/>
		 * The selector names towards the end of the array of parameters takes the highest priority.
		 * @param	... selectorNames	The array of selector names to look up.
		 * @return
		 */
		public function getSelector( ... selectorNames) : Object {
			// Read from camo core interface with encapsulation
			var tempProperties :IPropertySelector = _sampleSheet.createNewPropertySelector();	

			var len:int = selectorNames.length;
		
			for (var i:int = 0; i < len; i++ ) {
				var stack:LookupStack =  _lookupHash[ selectorNames[i] ];
				
				if (stack == null) continue;
				tempProperties.merge( stack.cachedProps );
			}
			return tempProperties;
		}
		
		public function get selectorNames() : Array {
			var retArr:Array = [];
			for (var i:* in _lookupHash) {
				retArr.push(i);
			}
			return retArr;
		}
		
		public function findSelector(selectorName:String):IPropertySelector {
			return _lookupHash[selectorName].tail.data as IPropertySelector;
		}
		
		
		
		public function addSelectorSource(src:ISelectorSource, id:String):void {
			if (_sampleSheet == null) checkSampleSheet(src); 
			
			var sampleSheet:IPropertySheet = _sampleSheet;
			
			var chkDict:Dictionary = _idHash[id] || createNewHash(id);
			var selectorNames:Array = src.selectorNames;

			for each(var selName:String in selectorNames) {
				var node:Node = new Node( src.findSelector( selName ) );
				var stack:LookupStack = _lookupHash[selName] || createNewList(selName, sampleSheet);
				stack.appendNode( node ); 
				chkDict[node] = stack;
			}	
		}	
		private function checkSampleSheet(src:ISelectorSource):void {
			_sampleSheet = src is IPropertySheet ?  new (Object(src).constructor as Class)() as IPropertySheet : null;
		}
		
		private function createNewHash(id:String):Dictionary {
			var hash:Dictionary = new Dictionary();
			_idHash[id] = hash;
			return hash;
		}
		private function createNewList(selName:String, sampleSheet:IPropertySheet):LookupStack {
			var list:LookupStack = new LookupStack(selName, sampleSheet);
			_lookupHash[selName] = list;
			return list;
		}



		public function removeSelectorSources(id:String):void {
			var chkDict:Dictionary = _idHash[id];
			if (!chkDict) return;
		
			for (var i:* in chkDict) {
				var list:LookupStack = chkDict[i];
				list.removeNode(i);
				if (list.tail == null) delete _lookupHash[list.id]; 
			}
			delete _idHash[id];
	
		}


		public function cloneSelectorStack(id:String = null):GPropertySheetManager {
			var meClone:GPropertySheetManager = new GPropertySheetManager();
			meClone.sampleSheet = _sampleSheet;
			var i:*;
			var hash:Object;
			
			if (id == null) {
				hash = _lookupHash;
				for (i in hash) {
					meClone.cloneLookupStack(hash[i]);
				}
				return meClone;
			}
			else { 
				hash = _idHash[id]; 
				for (i in hash) { 
					meClone.addNodeById(i, hash[i]);
				}
				return meClone;
			}
			return meClone;
		}
		/**
		 * @private
		 * Used internally for cloning only
		 */
		public function cloneLookupStack(lookupStack:LookupStack):void {
			_lookupHash[lookupStack.id] = lookupStack.clone();
		}
		/**
		 * @private
		 * Used internally for cloning only
		 */
		public function addNodeById(node:Node, referStack:LookupStack):void {
			var lookupStack:LookupStack = _lookupHash[referStack.id] || createNewList(referStack.id, referStack.sampleSheet);
			lookupStack.appendNode( node.clone() );
		}
		
		

		

		// -- Destructor 
		
		public function destroy():void {
			var hash:Dictionary = _lookupHash;
			for (var i:* in hash) {
				hash[i].deconstruct();
			}
			_sampleSheet = null;
			_idHash = null;
		}
		
		// -- Helpers


		

		

		

		
	}
	
	

}

import camo.core.property.IPropertySelector;
import camo.core.property.IPropertySheet;

internal class Node {
	
	public var next:Node;
	public var prev:Node;
	public var data:Object;
	
	public function Node(data:Object) {
		this.data = data;
	}
	
	public function clone():Node {
		return new Node(data);
	}
	
}


internal class LookupStack {
	
	public var head:Node;
	public var tail:Node; 	
	public var id:String;
	private var _cachedProps:Object;
	public var sampleSheet:IPropertySheet;
	private var _invalid:Boolean = true;
	
	/**
	 * A "stack" linked list which stores a cache of derived properties from the stack.
	 */
	public function LookupStack(id:String, sampleSheet:IPropertySheet):void {
		this.id = id;
		this.sampleSheet = sampleSheet;
	}
	
	public function clone():LookupStack {
		var cloned:LookupStack = new LookupStack(id, sampleSheet);
		var node:Node = head;
		while (node) {
			cloned.appendNode( node.clone() );
			node = node.next;
		}
		return cloned;
	}

	/**
	 * Returns a cached retrieved property from the current stack. If the stack was invalidated
	 * earlier, will attempt to re-cache a new property selector given the new arrangement of nodes.
	 */
	public function get cachedProps():Object {
		if (_invalid) {
			var newSelector:IPropertySelector = sampleSheet.createNewPropertySelector();
			var node:Node = head;
			while (node) {
				newSelector.merge(node.data);
				node = node.next;
			}
			_cachedProps = newSelector;
			_invalid = false;
		}
		return _cachedProps;
	}
	
	/**
	 * Adds a node to the stack and invalidates it.
	 * @param	node
	 */
	public function appendNode(node:Node):void {
		if (tail == null) {
			head = node;
			tail = node;
			_invalid = true;
			return;
		}
		tail.next = node;
		node.prev = tail;
		tail = node;
		_invalid = true;
	}		

	/**
	 * Removes a node from the stack and invalidates it
	 * @param	node
	 */
	public function removeNode(node:Node):void {
		if (node === tail) {
			tail = node.prev;
			if (tail) tail.next = null;
		}
		if (node === head) head = node.next;
		node.prev = null;
		node.next = null;
		node.data = null;
		_invalid = true;
	}
	
	/**
	 * Unlock all ressources for the garbage collector.
	 */
	public function deconstruct():void
	{
		var node:Node = head;
		var t:Node;
		while (node)
		{
			t = node.next;
			node.next = null;
			node.prev = null;
			node.data = null;
			node = t;
		}
		head = tail = null;
	}
}