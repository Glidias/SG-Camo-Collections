package sg.camo.greensock.adaptors 
{
	import com.greensock.TweenLite;
	import sg.camo.adaptors.AbstractApplierAdaptor;
	import sg.camo.interfaces.IPropertyMapCache;
	import sg.camo.interfaces.ITypeHelper;
	import sg.camo.greensock.CreateGSTweenVars;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	
	[Inject(name = '', name = '', name = 'GSTweenPropertyApplier.defaultTweenClass')]
	public class GSTweenPropertyApplier extends AbstractApplierAdaptor
	{
		protected var _defaultTweenClass:Class;
		
		public function GSTweenPropertyApplier(propMapCache:IPropertyMapCache, typeHelper:ITypeHelper, defaultTweenClass:Class=null) 
		{
			super(this,  propMapCache, typeHelper);
			_defaultTweenClass = defaultTweenClass || TweenLite;
		}
		
		override public function applyProperties(target:Object, properties:Object):void {
			var classe:Class;
			
			var props:Object = { };
			for (var i:String in properties) {
				if (i.charAt(0) != "/") props[i] = properties[i];
			}
			
			if (props.tweenClass) {
				classe = (props.tweenClass as Class) || getDefinitionByName(props.tweenClass) as Class;
				delete props.tweenClass;
			}
			else classe = _defaultTweenClass
			
			var duration:Number = .5; 
			if (properties.initDuration != null) {
				duration = Number(properties.initDuration);
				delete properties.initDuration;
				delete props.initDuration;
			}
			else if (props.duration) {
				duration = Number(props.duration);
				delete props.duration;
			}
			
			delete props.selectorName;
			delete props.styleName;
			
			var vars:Object = CreateGSTweenVars.createVarsFromObject(props);
			
			
			if (duration > 0) {
				classe["to"](target, duration, vars);
			}
			else {
				classe["to"](target, .1, vars).complete();
			}
			
			//new classe(target, duration,vars);
		}
		
		
		
	}

}