/**
 * VERSION: 0.52
 * DATE: 12/21/2009
 * AS3
 * UPDATES AND DOCUMENTATION AT: http://www.TweenLite.com
 **/
package com.greensock.easing {
/**
 * Most easing equations give a smooth, gradual transition between the start and end values, but RoughEase provides
 * an easy way to get a rough, jagged effect instead. You can define an ease that it will use as a template (like a
 * general guide - Linear.easeNone is the default) and then it will randomly plot points wander from that template. 
 * The strength parameter controls how far from the template ease the points are allowed to go (a small number like
 * 0.1 keeps it very close to the template ease whereas a larger number like 2 creates much larger jumps). You can
 * also control the number of points in the ease, making it jerk more or less frequently. And lastly, you can associate
 * a name with each RoughEase instance and retrieve it later like RoughEase.byName("myEaseName"). Since creating 
 * the initial RoughEase is the most processor-intensive part, it's a good idea to reuse instances if/when you can.<br /><br />
 * 
 * <b>EXAMPLE CODE</b><br /><br /><code>
 * import com.greensock.TweenLite;<br />
 * import com.greensock.easing.RoughEase;<br /><br />
 * 
 * TweenLite.from(mc, 3, {alpha:0, ease:RoughEase.create(1, 15)});<br />
 * 
 * //or create an instance directly<br />
 * var rough:RoughEase = new RoughEase(1.5, 30, true, Strong.easeOut, "superRoughEase");<br />
 * TweenLite.to(mc, 3, {y:300, ease:rough.ease});
 * 
 * //and later, you can find the ease by name like:<br />
 * TweenLite.to(mc, 3, {y:300, ease:RoughEase.byName("superRoughEase")});
 * </code><br /><br />
 * 
 * <b>Copyright 2009, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */	 
	public class RoughEase {		
		/** @private **/
		private static var _all:Object = {}; //keeps track of all instances so we can find them by name.
		/** @private **/
		private static var _count:uint = 0;
		
		/** @private **/
		private var _name:String;
		/** @private **/
		private var _first:EasePoint;
		/** @private **/
		private var _last:EasePoint;
		
		/**
		 * Constructor
		 * 
		 * @param strength amount of variance from the templateEase (Linear.easeNone by default) that each random point can be placed. A low number like 0.1 will hug very closely to the templateEase whereas a larger number like 2 will allow the values to wander further away from the templateEase.
		 * @param points quantity of random points to plot in the ease. A larger number will cause more (and quicker) flickering.
		 * @param restrictMaxAndMin If true, the ease will prevent random points from exceeding the end value or dropping below the starting value. For example, if you're tweening the x property from 0 to 100, the RoughEase would force all random points to stay between 0 and 100 if restrictMaxAndMin is true, but if it is false, a x could potentially jump above 100 or below 0 at some point during the tween (it would always end at 100 though).
		 * @param templateEase an easing equation that should be used as a template or guide. Then random points are plotted at a certain distance away from the templateEase (based on the strength parameter). The default is Linear.easeNone.
		 * @param name a name to associate with the ease so that you can use RoughEase.byName() to look it up later. Of course you should always make sure you use a unique name for each ease (if you leave it blank, a name will automatically be generated). 
		 */
		public function RoughEase(strength:Number=1, points:uint=20, restrictMaxAndMin:Boolean=false, templateEase:Function=null, name:String="") {
			if (name == "") {
				_count++;
				_name = "roughEase" + _count;
			} else {
				_name = name;
			}
			_all[_name] = this;
			var a:Array = [];
			var cnt:uint = 0;
			var x:Number, y:Number, obj:Object;
			var i:uint = points;
			while (i--) {
				x = Math.random();
				y = (templateEase != null) ? templateEase(x, 0, 1, 1) : x;
				y += ((Math.random() * strength * 0.4) - (strength * 0.2));
				if (restrictMaxAndMin) {
					if (y > 1) {
						y = 1;
					} else if (y < 0) {
						y = 0;
					}
				}
				a[cnt++] = {x:x, y:y};
			}
			a.sortOn("x", Array.NUMERIC);
			
			_first = _last = new EasePoint(1, 1, null);
			
			i = points;
			while (i--) {
				obj = a[i];
				_first = new EasePoint(obj.x, obj.y, _first);
			}
			_first = new EasePoint(0, 0, _first);
			
		}
		
		/**
		 * This static function provides a quick way to create a RoughEase and immediately reference its ease function 
		 * in a tween, like:<br /><br /><code>
		 * 
		 * TweenLite.from(mc, 2, {alpha:0, ease:RoughEase.create(1.5, 15)});<br />
		 * </code>
		 * 
		 * @param strength amount of variance from the templateEase (Linear.easeNone by default) that each random point can be placed. A low number like 0.1 will hug very closely to the templateEase whereas a larger number like 2 will allow the values to wander further away from the templateEase.
		 * @param points quantity of random points to plot in the ease. A larger number will cause more (and quicker) flickering.
		 * @param restrictMaxAndMin If true, the ease will prevent random points from exceeding the end value or dropping below the starting value. For example, if you're tweening the x property from 0 to 100, the RoughEase would force all random points to stay between 0 and 100 if restrictMaxAndMin is true, but if it is false, a x could potentially jump above 100 or below 0 at some point during the tween (it would always end at 100 though).
		 * @param templateEase an easing equation that should be used as a template or guide. Then random points are plotted at a certain distance away from the templateEase (based on the strength parameter). The default is Linear.easeNone.
		 * @param name a name to associate with the ease so that you can use RoughEase.byName() to look it up later. Of course you should always make sure you use a unique name for each ease (if you leave it blank, a name will automatically be generated). 
		 * @return easing function
		 */
		public static function create(strength:Number=1, points:uint=20, restrictMaxAndMin:Boolean=false, templateEase:Function=null, name:String=""):Function {
			return new RoughEase(strength, points, restrictMaxAndMin, templateEase, name).ease;
		}
		
		/**
		 * Provides a quick way to look up a RoughEase by its name.
		 * 
		 * @param name the name of the RoughEase
		 * @return easing function from the RoughEase associated with the name
		 */
		public static function byName(name:String):Function {
			return _all[name].ease;
		}
		
		/**
		 * Easing function that interpolates the numbers
		 * 
		 * @param t time
		 * @param b start
		 * @param c change
		 * @param d duration
		 * @return Result of the ease
		 */
		public function ease(t:Number, b:Number, c:Number, d:Number):Number {
			var time:Number = t / d;
			var p:EasePoint;
			if (time < 0.5) {
				p = _first;
				while (p.time <= time) {
					p = p.next;
				}
				p = p.prev;
			} else {
				p = _last;
				while (p.time >= time) {
					p = p.prev;
				}
			}
			return b + (p.value + ((time - p.time) / p.gap) * p.change) * c;
		}
		
		/** name of the RoughEase instance **/
		public function get name():String {
			return _name;
		}
		
		public function set name(s:String):void {
			delete _all[_name];
			_name = s;
			_all[s] = this;
		}

	}
}

internal class EasePoint {
	public var time:Number;
	public var gap:Number;
	public var value:Number;
	public var change:Number;
	public var next:EasePoint;
	public var prev:EasePoint;
	
	public function EasePoint(time:Number, value:Number, next:EasePoint) {
		this.time = time;
		this.value = value;
		if (next) {
			this.next = next;
			next.prev = this;
			this.change = next.value - value;
			this.gap = next.time - time;
		}
	}
}