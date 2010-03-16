package sg.camo.behaviour 
{
	import camo.core.display.IDisplay;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import sg.camo.interfaces.IPropertyApplier;
	import sg.camo.interfaces.IPseudoBehaviour;
	import sg.camo.interfaces.ITextField;
	/**
	 * The ButtonStateBehaviour is a pseudo behaviour class that allows you to apply any set of properties
	 * to define the normal, hover and press states of a given target object. Properties prefixed with
	 * a "!" indicate hover state values, while properties prefixed with a "*" indicate press state values. Any
	 * other value is treated as a normal state value. When the behaviour is activated, it applies normal
	 * state values to the object as well.
	 * 
	 * @usage In CSS/GXML, this is done through a IPropertyApplier that allows applying ALL properties over dynamic Proxy classes:
	 * <code>
	 * 		.someBtnClass>text!buttonTween {
	 * 			tint:#000000;
	 *  		!tint:#ff0000;
	 *          *tint:#ffee22;
	 * 		}
	 * 
	 * </code>
	 * 
	 * @usage In As3, you can do this standalone, setting any properties you wish
	 * <code>
	 * 		 private var _myBtnStateBehaviour:ButtonStateBehaviour = new ButtonStateBehaviour();
	 *		_myBtnStateBehaviour.propApplier = new GSTweenPropertyApplier(); 
	 * 		_myBtnStateBehaviour.tint = "#000000";   // assumes TintPlugin is already enabled to process tint values
	 * 		_myBtnStateBehaviour["!tint"] = "#ff0000";
	 * 		_myBtnStateBehaviour["*tint"] = "#ffee22";
	 * 		_myBtnStateBehaviour.activate(_myBtn);
	 * </code>
	 * 
	 * Make sure you set the required dependencies such as a 'propApplier' (IPropertyApplier)
	 * instance to allow for applying properties over the object. Different IPropertyApplier implementations
	 * handle processing of props and target differently, allowing for applying tweening effects/text formats, etc.
	 * depending on the type of property applier being used.
	 * 
	 * @see sg.camo.greensock.adaptors.GSTweenPropertyApplier
	 * @see sg.camo.greensock.adaptors.PropApplierAdaptor
	 * @see sg.camo.greensock.adaptors.TextPropApplierAdaptor
	 * 
	 * @author Glenn Ko
	 */
	public class ButtonStateBehaviour extends AbstractProxyBehaviour implements IPseudoBehaviour
	{
		public static const NAME:String = "ButtonStateBehaviour";
		
		protected var _normalProps:Object;
		protected var _hoverProps:Object;
		protected var _pressProps:Object;
	
		protected var _propertiesClass:Class = Object;
		protected var _propApplier:IPropertyApplier;
		
		protected var _displayObject:DisplayObject;
		protected var _applyTarget:Object;
		
		protected var _pseudoState:String = "";
		
		[CamoInspectable(description = "Set this to 'textField' or 'display' to attempt to target a sub-instance from which to apply properties upon", type="selection(default|textField|display)")]
		public function set pseudoState(str:String):void { 
			_pseudoState = str;
			if (_displayObject) _applyTarget = getApplyTargetOf(_displayObject);
		};

		[CamoInspectable(description = "Make sure you set an appropiate IPropertyApplier implementation to apply properties on a given target")]
		[Inject]
		public function set propApplier(val:IPropertyApplier):void {
			_propApplier = val;
			if (defaultPropApplier == null) defaultPropApplier = val;
		}
		public function get propApplier():IPropertyApplier {
			return _propApplier;
		}
		
		[Inject]
		[CamoInspectable(description="This is the default property applier being used to apply default state properties to the targetted object during the activate() state.", immutable="true")]
		public var defaultPropApplier:IPropertyApplier;
		
		[Inject(name="Proxy.properties")]
		public function setPropertiesClass(val:Class=null):void {
			if (val!=null) propertiesClass = val;
		}
		public function set propertiesClass(val:Class):void {
			_propertiesClass = val;
		}
		
		public function ButtonStateBehaviour() 
		{
			super(this);
		}
		
		override public function get behaviourName():String {
			return NAME;
		}
		
		override public function activate(targ:*):void {
			_displayObject  = targ as DisplayObject;
			if (_displayObject == null) throw new Error("ButtonStateBehaviour failed! Target isn't display object!");
		
			_applyTarget = getApplyTargetOf(_displayObject);
			
			_displayObject.addEventListener(MouseEvent.ROLL_OVER,  rollOverHandler, false , 0, true);
			_displayObject.addEventListener(MouseEvent.ROLL_OUT,  rollOutHandler, false , 0, true);
			_displayObject.addEventListener(MouseEvent.MOUSE_DOWN,  mouseDownHandler, false , 0, true);
			
			if (_normalProps) {
				defaultPropApplier.applyProperties(_applyTarget, _normalProps);
			}
		}
		
		override public function destroy():void {
			if (_displayObject == null) return;
			_displayObject.removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_displayObject.removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			_displayObject.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_displayObject = null;
		}
		
		/** @private */
		protected var _isOver:Boolean = false;
		
		
		protected function rollOverHandler(e:Event):void {
			_isOver = true;
			if (_hoverProps) _propApplier.applyProperties(_applyTarget, _hoverProps);
		}
		protected function rollOutHandler(e:Event):void {
			_isOver = false;
			if (_normalProps) _propApplier.applyProperties(_applyTarget, _normalProps);
		}
		
		protected function mouseDownHandler(e:Event):void {
			if (_pressProps) _propApplier.applyProperties(_applyTarget, _pressProps);
			_displayObject.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
		}
		
		protected function mouseUpHandler(e:Event):void {
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, mouseUpHandler);
			if (_isOver) {
				if (_hoverProps) _propApplier.applyProperties(_applyTarget, _hoverProps); 
			}
			else {
				if (_normalProps) _propApplier.applyProperties(_applyTarget, _normalProps); 
			}
		}
		
	

		protected function getApplyTargetOf(targ:DisplayObject):Object {
			switch (_pseudoState) {
				case "textField":
				return targ is TextField ? targ : targ is ITextField ? (targ as ITextField).textField || warn('ITextField.textField') : (targ as DisplayObjectContainer).getChildByName("txtLabel") as TextField || warn("getChildByName('txtLabel') as TextField");
				case "display": 
				return targ is IDisplay ? (targ as IDisplay).getDisplay() || warn('IDisplay.getDisplay()') : warn('cast to IDisplay');
				
				default:return targ;
			}
			return targ;
		}
		
		protected function warn(phrase:String):* {
			trace("ButtonStateBehaviour warning:: No target found for " + phrase + "on " +_displayObject + "for pseudo state:"+_pseudoState);
			return _displayObject;
		}
		
		
		override protected function $deleteProperty(name:*):Boolean {
			var obj:Object = getChannelObject(name);
			return delete obj[getPropertyOfObj( obj, name)];
		}
		
		protected function getChannelObject(name:String):Object {
			var prefix:String = name.charAt(0);
			return prefix === "!" ? _hoverProps || (_hoverProps = new _propertiesClass()) : prefix === "*" ? _pressProps || (_pressProps = new _propertiesClass()) : _normalProps || (_normalProps = new _propertiesClass());
		}

		
		override protected function $getProperty(name:*):* {
			var obj:Object = getChannelObject(name);
			return obj[getPropertyOfObj(obj, name)];
		}


		override protected function $setProperty(name:*, value:*):void {
			var obj:Object = getChannelObject(name);
			obj[getPropertyOfObj(obj, name)] = value;
		}
		
		public function getPropertyOfObj(obj:Object,name:String):String {
			return obj === _normalProps ? name : name.substr(1);
		}
		
		
	}

}