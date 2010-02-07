package sg.camo.greensock.transitions 
{
	import com.greensock.core.TweenCore;
	import com.greensock.TweenLite;
	import flash.utils.ByteArray;
	
	/**
	 * Utility packet to defer instantiation of tweenlite instances for list items.
	 * Also supports !mark prefix for variables to immediately render those initial values 
	 * on the targetted object.
	 * 
	 * @author Glenn Ko
	 */
	public class TweenPacket
	{
		public var target:Object;
		public var duration:Number;
		private var myVars:Object;
		private var initVars:Object;
		
		private var _twClass:Class;


		public function TweenPacket(target:Object, duration:Number, vars:Object, tweenClass:Class) 
		{
			this.target = target;
			this.duration = duration;
			
			var myBA : ByteArray = new ByteArray( );
			myBA.writeObject( vars );
			myBA.position = 0;
			myVars = myBA.readObject();

			_twClass = tweenClass;
	
			for (var i:String in myVars) {
				if ( i.charAt(0) != "!" ) continue;
				var initProp:String = i.substr(1);
				if (initVars == null) initVars = { };
				initVars[initProp] = target[initProp];
				target[initProp] = myVars[i];
				myVars[initProp] = myVars[i];
				delete myVars[i];
			}
		}
		
		public function get tween():* {
			if (initVars!=null) {
				for (var i:String in initVars) {
					target[i] = initVars[i];
				}
			}
			return new _twClass(target, duration, myVars);
		}
		
	}

}