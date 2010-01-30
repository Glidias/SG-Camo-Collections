package sg.camo.form {


	
	/**
	* Utility class with static methods to validate form values.
	*/
	public class FormValidator {
		
		public static const EMAIL:String = "A-Za-z0-9@_\\-.";
		public static const ALPHA:String = "A-z a-z\\-";
		public static const NUMERIC:String = "0-9";
		public static const ALPHANUMERIC:String	= "A-z a-z0-9";

		/**
		 * Checks for valid email format
		 * @param	email	(String)
		 * @return
		 */
		public static function isValidEmail(email:String):Boolean {
			
			var emailExpression:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			return emailExpression.test(email);
		}
		
		/**
		 * Checks whether stirng value is a valid number.
		 * @param	tfValue		(String)
		 * @return
		 */
		public static function isValidNumber(tfValue:String):Boolean{
			return (!FormValidator.isEmpty( tfValue ) && !isNaN(Number(tfValue)));
		}
		
		/**
		 * Checks whether string value of textfield is empty
		 * @param	tfValue	(String)
		 * @return
		 */
		public static function isEmpty(tfValue:String):Boolean{
			var max:Number = tfValue.length;
			
			//-- zero length string
			if (max==0) return true;
			
			//-- whitespace only string
			for(var i:int=0; i<max; i++){
				if(tfValue.substr(i,1) != " ") return false;
			}
			
			return true;
		}
		
		/**
		 * Checks for valid URL
		 * @param	url	 (String)
		 * @return
		 */
		public static function isValidURL(url:String):Boolean
		{
			//trace("Is it valid??");
			var regex:RegExp = /^http(s)?:\/\/((\d+\.\d+\.\d+\.\d+)|(([\w-]+\.)+([a-z,A-Z][\w-]*)))(:[1-9][0-9]*)?(\/([\w-.\/:%+@&=]+[\w- .\/?:%+@&=]*)?)?(#(.*))?$/i;
			return regex.test(url); 
		}
		

		/**
		 * Checks for valid date in DDMMYYYY format
		 * @param	date (String) In DDMMYYYY format
		 * @return
		 */
		public static function isValidDate(date:String):Boolean{
			var dd:Number= Number(date.substr(0,2));
			var mm:Number = Number(date.substr(3,2));
			var yyyy:Number = Number(date.substr(6,4));
			var maxDay:Number;
			
			if (mm<1 || mm>12)
				return false;
			
			if (mm == 4 || mm == 6 || mm == 9 || mm ==11)
				maxDay = 30;
			else if (mm == 2){
				if (yyyy%4 == 0)
					maxDay = 29;
				else
					maxDay = 28;
			}
			
			if (dd<1 || dd>maxDay)
				return false;
				
			return true;
		}
		
		
	}
	
	
	
}