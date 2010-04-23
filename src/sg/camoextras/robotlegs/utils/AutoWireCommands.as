package sg.camoextras.robotlegs.utils 
{
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	import org.robotlegs.core.ICommandMap;
	import flash.utils.describeType;
	
	/**
	 * Utility to help auto wire a whole bunch of commands to event types based on conventions.
	 * Conventions are:
	 * 
	 * 1) A public variable named "event"
	 * 2) Capital underscore casing to CapitalClassCasing+"Command". FOr example: "NAVIGATE_TO"
	 * @author Glenn Ko
	 */
	
	[Inject(name="",name="")]
	public class AutoWireCommands
	{
		
		public var commandMap:ICommandMap;
		public var appDomain:ApplicationDomain;
		public var useClassPrefix:Boolean = false;
		
		public function AutoWireCommands(commandMap:ICommandMap, appDomain:ApplicationDomain=null) {
			this.commandMap = commandMap;
			this.appDomain = appDomain || ApplicationDomain.currentDomain;
		}
		
		
		public function setupCommands(...args):void {
			for each(var classe:Class in args) {
				
			
				var xml:XML = describeType(classe);
				var nameEventList:XMLList =  xml..variable.(@name == "event"); 
				if (nameEventList.length() < 1) {
					throw new Error("Could not find event variable for class:"+ classe + "\n"+ xml.toXMLString());
					return;
				}
				var classType:String = nameEventList[0].@type;
				var classNamer:String = classType.split("::").pop();
				
				var commandClassName:String = getQualifiedClassName(classe).split("::").pop();
				var cmdIndex:int = commandClassName.indexOf("Command");
				var cmdName:String = cmdIndex > -1 ? commandClassName.substr(0, cmdIndex) : commandClassName; 
				var regex:RegExp = /(?<=[a-z])([A-Z])/g;
				var eventClass:Object = appDomain.getDefinition(classType);
				var upperCmdName:String = cmdName.replace(regex, "_$1").toUpperCase();
				var eventType:String = useClassPrefix ? commandClassName + "." + upperCmdName : upperCmdName ;
				if ( eventClass[upperCmdName] != eventType ) {
					throw new Error("eventType:"+eventType+ " doesn't match up, for:"+upperCmdName + " under :"+classe);
				}
				commandMap.mapEvent( eventType, classe, appDomain.getDefinition(classType) as Class )
				
				//var classNamer + "." + "";
			}
		}
		
		private function capitalToUnderScored(str:String):String {
			return "";
		}
		
		
	}

}