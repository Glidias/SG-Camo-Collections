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
 *  *   Changes made on Sept 05, 2009 - Glenn (commented)
 * 		- Took out unnecessary concrete class references for dynamic classes
 * 
 * 
 * 		Changes made on Nov 26, 2009  - Glenn (commented)
 * 
 *   		- In applyProperties(), replaced target.hasOwnProperty with direct propertyMap check, 
 * 		  since hasOwnProperty also returns read-only variables which cannot be written over.
 * 
 *      ( Now in PropertyMap Cache, Dec 21 2009)
 * 
 *   	- Limit describeType() calls to only once per class.
 * 
 * 		- Consider 'factory' node in describeType() for propertyMap generation, if running
 * 		  property map on a Class object rather than an already instantiated instance.
 * 
 *     Changes made on Dec 21,2009 -  Glenn.
 * 
 * 		Transfered all stored property maps into a seperate class called PropertyMapCache 
 * 		so that property maps can be easily referenced in a cross-platform manner from other packages.
 * 
 */

 
package camo.core.utils {
	import camo.core.property.PropertyMap;
	
	// -- concrete PropertySelector implementation not required in this class
	//import camo.core.property.PropertySelector;   

	import flash.utils.Dictionary;
	

	public class PropertyApplierUtil {

		/**
		 * @param   target
		 * @param   properties  This parameter is now made generic Object for cross-platform flexiblity.
		 */		
		public static function applyProperties( target : Object, properties : Object) : void {
			var propMap : Object = PropertyMapCache.getPropertyMap(target);
			
			for(var prop:String in properties) {

				var type : String = propMap[prop];
				if(type) {  //target.hasOwnProperty(prop)
					var cleanedUpValue : * = TypeHelperUtil.getType(properties[prop], type);
					
					target[prop] = cleanedUpValue;
				}
			}
		}
		
	
	}
}