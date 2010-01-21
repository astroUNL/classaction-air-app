
package astroUNL.classaction.browser.views.elements {
	
	import 
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	public class EditableClickableText extends ClickableText {
		
		public static const EDIT_DONE:String = "editDone";
		
		public function EditableModuleText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			_halo = new FocusHalo();
			addChild(_halo);
			
//			_field = new TextField();
//			_field.autoSize = "none";				
//			_field.border = true;
//			_field.borderColor = 0xafd6fa;
//			_field.background = true;
//			_field.backgroundColor = 0xffffff;
//			_field.multiline = false;
//			_field.type = "input";
//			_field.embedFonts = true;			
//			//_field.maxChars = 16;
//			addChild(_field);
			
			_field.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_field.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			
			setProperties(text, data, format, width, height);
		}
		
		
		override public function setProperties():void {
			
			if (_halo.scale9Grid!=null) {
				_halo.scaleX = _halo.scaleY = 1;
				_halo.width = width + (_halo.width - _halo.scale9Grid.width);
				_halo.height = height + (_halo.height - _halo.scale9Grid.height);
			}
			
			_halo.x = width/2;
			_halo.y = height/2;			
		}
		
		public function selectAndFocus():void {
			stage.focus = _field;
			_field.setSelection(0, _field.text.length);
		}
		
		
		public function get text():String {
			return _field.text;			
		}
		
		protected function onFocusIn(evt:FocusEvent):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onFocusOut(evt:FocusEvent):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			dispatchEvent(new Event(EditableField.ON_EDIT));
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) stage.focus = null;
		}
		
		protected function onMouseDown(evt:MouseEvent):void {
			if (evt.target!=_field && evt.target!=_halo) stage.focus = null;
		}
		
		
	}	
}
