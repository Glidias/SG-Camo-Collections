package sg.camolite.display.impl
{
	import camo.core.events.CamoDisplayEvent;
	import flash.text.TextField;
	import sg.camolite.display.GTextMovieClip;
	/**
	 * Expanding textfield box. <br/>
	 * Sets fixed width based on staged txtLabel width. Autosizing by default
	 * and will wrap text and expand textfield vertically if width limit is reached. 
	 * <br/><br/>
	 * This is made a movieClip for convenience and expandability.
	 * 
	 * @author Glenn Ko
	 */
	public class MCTextBox extends GTextMovieClip
	{
		
		public function MCTextBox() 
		{
			super();
		}
		// -- IReflectClass
		
		override public function get reflectClass():Class {
			return MCTextBox;
		}
		
		override public function set text(str:String):void {

			super.text = str;
			
			if (_textField.textWidth > _width) {
				_textField.multiline = true;
				_textField.wordWrap = true;
				_textField.width = _width;
			}
			else {
				_textField.multiline = false;
				_textField.wordWrap = false;
				
			}
			
		
			if (stage != null) stage.invalidate();
			dispatchEvent( new CamoDisplayEvent(CamoDisplayEvent.DRAW, true) );
		}

		
		override public function set txtLabel(txtField:TextField):void {
			super.txtLabel = txtField;
			_width = txtField.width;
			//resize(txtField.width, textField.height);
			
			txtField.autoSize = txtField.getTextFormat().align; 
			_textField.multiline = false;
			_textField.wordWrap = false;
			txtField.text = txtField.text;
			
		}
		
	}

}