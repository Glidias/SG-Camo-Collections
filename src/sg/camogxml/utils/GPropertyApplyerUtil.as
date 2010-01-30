/** 
 * <p>Original Author:  jessefreeman</p>
 * <p>Class File: PropertyApplyerUtil.as</p>
 * 
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 * 
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 * 
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 * 
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 *
 * <p>Revisions<br/> 
 * 	2.0  Initial version April 9, 2009</p>
 *	
 *
 */

 
package sg.camogxml.utils {
	import camo.core.property.PropertyMap;
	import camo.core.utils.PropertyMapCache;
	import camo.core.utils.TypeHelperUtil;
	
	// -- concrete PropertySelector implementation not required in this class
	//import camo.core.property.PropertySelector;   

	import flash.utils.Dictionary;
	

	/**
	 * Custom PropertyApplierUtil with additional options
	 * 
	 * @see camo.core.utils.PropertyApplierUtil
	 * 
	 */
	public class GPropertyApplyerUtil {

		/**
		 * Same applyProperties() as PropertyApplierUtil
		 * @param   target
		 * @param   properties  
		 */		
		public static function applyProperties( target : Object, properties : Object) : void {
			var propMap : PropertyMap = PropertyMapCache.getPropertyMap(target);
			
			for(var prop:String in properties) {

				var type : String = propMap[prop];
				if(type) {
					var cleanedUpValue : * = TypeHelperUtil.getType(properties[prop], type);
					
					target[prop] = cleanedUpValue;
				}
			}
		}
		
		/**
		 * Same as applyProperties() on a target object, but also returns a cached object containing
		 * the converted values.
		 * @param	target
		 * @param	properties
		 * @return	A cached object containing the successfully converted values
		 */
		public static function applyCachableProperties(target:Object, properties:Object):Object {
			var propMap:PropertyMap = PropertyMapCache.getPropertyMap (target);
			var cachedProps:Object = { };
					for(var prop:String in properties) {
						if(target.hasOwnProperty(prop)){
								var type:String = propMap[prop];
							var cleanedUpValue:* = TypeHelperUtil.getType (properties[prop], type);
							target[prop] = cleanedUpValue;
							cachedProps[prop] =  cleanedUpValue;
						}
					}
			return cachedProps;
		}
		
		
		/**
		 * Applies any valid property to target as string irregardless (with the exception of true and false). 
		 * Normally used on Textformat object, since they aren't strictly typed.
		 * @param	target
		 * @param	properties
		 * @return  Also returns cached properties
		 * <br/><br/>
		 * Note: With a possible integration of F*CSS, this method might no longer be necessary.
		 */
		public static function applyPropertiesAsString ( target:Object, properties:Object):Object {
			var propMap : PropertyMap = PropertyMapCache.getPropertyMap (target);
			var cachedProps:Object = { };
			for(var prop:String in properties) {
				if (target.hasOwnProperty (prop)) {
					var val:* = properties[prop];
					val = (val === "true" || val === "false") ? TypeHelperUtil.stringToBoolean (val) : val;
					target[prop] =  val;
					cachedProps[prop] =  val;
				}
			}
			return cachedProps;
		}
		
	
	}
}