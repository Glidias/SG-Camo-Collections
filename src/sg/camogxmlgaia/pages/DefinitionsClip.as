package sg.camogxmlgaia.pages 
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import sg.camo.interfaces.IDefinitionGetter;
	/**
	 * This is a template base document class you can use as the src content for any 
	 * BehavioursDomainAsset/DefinitionsDomainAsset to conveniently register 
	 * definitions/behaviours to the CGG framework.
	 * 
	 * @see sg.camogxmlgaia.assets.domain.BehavioursDomainAsset
	 * @see sg.camogxmlgaia.assets.domain.DefinitionsDomainAsset
	 * 
	 * @author Glenn Ko
	 */
	public class DefinitionsClip extends MovieClip implements IDefinitionGetter
	{
		protected var _myDefinitionNames:Array  = [];
		protected var _definitionDict:Dictionary = new Dictionary();
		
		public function DefinitionsClip() 
		{
			
		}
		
		/**
		 * Call this from the timeline or extended document classes to register definitions.
		 * @param	definition		 The definition to register
		 * @param   definitionName   The registered definition name is the last splitted name from the target's
		 * 							 fully qualified class name if less undefined.
		 */
		public function registerClass(definition:Class, definitionName:String = null):void {
			definitionName = definitionName || getQualifiedClassName(definition).split("::").pop();
			_definitionDict[definitionName] = definition;
		}
		
		/**
		 * Register multiple definitions in bulk (usually class definitions only).
		 *  The registered definition name is the last splitted name from the target's fully
		 *  qualified class name.
		 * @param	...args	
		 */
		public function registerDefinitions(...args):void {
			for (var i:String in args) {
				var def:Object = args[i];
				_definitionDict[getQualifiedClassName(def).split("::").pop()] = def;
			}
		}
		/**
		 * Register multiple definitions in definition/definition-name pairs.
		 * @param	...args	
		 */
		public function registerDefinitionPairs(...args):void {
			var i:int = 0;
			while (i < args.length) {
				var def:Object = args[i];
				var defName:String = args[i + 1];
				_definitionDict[defName] = def;
				i+=2;
			}
		}
		
		

		// -- IDefinitionGetter
		
		public function getDefinition(str:String):Object {
			return _definitionDict[str]
		}

		public function hasDefinition(str:String):Boolean {
			return _definitionDict[str] != null;
		}
		

		public function get definitions():Array {
			var arr:Array = [];
			for (var i:String in _definitionDict) {
				arr.push(i);
			}
			return arr;
		}
		

		
		
	}

}