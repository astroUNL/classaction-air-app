
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	public class EditableField extends Sprite {
		
		protected var _halo:FocusHalo;
		protected var _field:TextField;
		
		public static const ON_EDIT:String = "onEdit";
		
		public function EditableField(text:String="", data:*=null, format:TextFormat=null, width:Number=0, height:Number=0) {
			
			_halo = new FocusHalo();
			addChild(_halo);
			
			_field = new TextField();
			_field.autoSize = "none";				
			_field.border = true;
			_field.borderColor = 0xafd6fa;
			_field.background = true;
			_field.backgroundColor = 0xffffff;
			_field.multiline = false;
			_field.type = "input";
			_field.embedFonts = true;			
			//_field.maxChars = 16;
			addChild(_field);
			
			_field.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
			_field.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
			
			setProperties(text, data, format, width, height);
		}
		
		public var data:*;
		
		public function selectAndFocus():void {
			stage.focus = _field;
			_field.setSelection(0, _field.text.length);
		}
		
		public function setProperties(text:String="", data:*=null, format:TextFormat=null, width:Number=0, height:Number=0):void {
			this.data = data;
			
			if (format!=null) _field.defaultTextFormat = format;
			_field.scrollH = 0;
			_field.width = width;
			_field.height = height;
			_field.text = text;
			
			if (_halo.scale9Grid!=null) {
				_halo.scaleX = _halo.scaleY = 1;
				_halo.width = width + (_halo.width - _halo.scale9Grid.width);
				_halo.height = height + (_halo.height - _halo.scale9Grid.height);
			}
			
			_halo.x = width/2;
			_halo.y = height/2;			
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
