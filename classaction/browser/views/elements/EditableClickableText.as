
package astroUNL.classaction.browser.views.elements {
	
	import flash.text.TextFormat;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	public class EditableClickableText extends ClickableText {
		
		public static const EDIT_DONE:String = "editDone";
		public static const DIMENSIONS_CHANGED:String = "dimensionsChanged";
		
		protected var _halo:FocusHalo;
		
		protected var _editingFormat:TextFormat;
		
		protected var _editMenuItem:ContextMenuItem;
		
		public function EditableClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			_editingFormat = new TextFormat();
			
			_halo = new FocusHalo();
			_halo.visible = false;
			addChild(_halo);
			
			super(text, data, format, width);
			
			_editMenuItem = addMenuItem("Rename", onEdit);
		}		
		
		protected function onEdit(evt:ContextMenuEvent):void {
			setEditable(true);
		}
		
		override public function setFormat(format:TextFormat=null):void {
			var notLocked:Boolean = !_locked;
			if (notLocked) lock();
			
			super.setFormat(format);
			
			_editingFormat.font = _format.font;
			_editingFormat.size = _format.size;
			_editingFormat.color = 0x000000;
			_editingFormat.bold = _format.bold;
			_editingFormat.italic = _format.italic;
			_editingFormat.underline = false;
			
			_field.defaultTextFormat = (_editable) ? _editingFormat : _format;
			
			if (notLocked) unlock();
		}
		
		override protected function redraw():void {
			super.redraw();
			updateHalo();
		}
		
		protected function updateHalo():void {
			if (_halo.scale9Grid!=null) {
				_halo.scaleX = _halo.scaleY = 1;
				_halo.width = _field.width + (_halo.width - _halo.scale9Grid.width);
				_halo.height = _field.height + (_halo.height - _halo.scale9Grid.height);
			}
			_halo.x = _field.width/2;
			_halo.y = _field.height/2;			
		}
		
		override public function get width():Number {
			return _field.width;			
		}
		
		override public function get height():Number {
			return _field.height;			
		}
		
		protected function selectAndFocus():void {
			stage.focus = _field;
			_field.setSelection(0, _field.text.length);
		}
		
		protected var _editable:Boolean = false;
		
		public function setEditable(editable:Boolean):void {
			if (_editable && !editable) {
				_halo.visible = false;
				_field.border = false;
				_field.background = false;
				_field.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn, false);
				_field.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false);
				_field.removeEventListener(Event.CHANGE, onFieldChanged, false);
				
				_field.type = "dynamic";
				_field.selectable = false;
				_field.defaultTextFormat = _format;
				_field.setTextFormat(_format);
				
				if (_clickable) doSetClickable(true);
//				if (_enabled) doSetEnabled(true);
				mouseChildren = false;
				
//				if (_enabled) {
//					addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
//					addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false, 0, true);
//					addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false, 0, true);
//				}
//				
//				buttonMode = true;
//				useHandCursor = true;
//				tabEnabled = true;
				
				_editable = false;
				
				_editMenuItem.enabled = true;
			}
			else if (!_editable && editable) {
				_halo.visible = true;
				_field.border = true;
				_field.borderColor = 0xafd6fa;
				_field.background = true;
				_field.backgroundColor = 0xffffff;
				_field.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
				_field.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
				_field.addEventListener(Event.CHANGE, onFieldChanged, false, 0, true);
				
				_field.type = "input";
				_field.selectable = true;
				_field.defaultTextFormat = _editingFormat;
				_field.setTextFormat(_editingFormat);
				
				if (_clickable) doSetClickable(false);
//				if (_enabled) doSetEnabled(false);
				mouseChildren = true;
				
//				if (_enabled) {
//					removeEventListener(MouseEvent.CLICK, onClick, false);
//					removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false);
//					removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false);
//				}
//				
//				buttonMode = false;
//				useHandCursor = false;
//				tabEnabled = false;
					
				_numLines = _field.numLines;
				_editable = true;
				
				_editMenuItem.enabled = false;
				
				updateHalo();
				selectAndFocus();
			}
		}
		
		protected var _numLines:int;
		
		protected function onFieldChanged(evt:Event):void {
			if (_width==0 || _field.numLines!=_numLines) {
				updateHalo();
				_numLines = _field.numLines;
				dispatchEvent(new Event(EditableClickableText.DIMENSIONS_CHANGED));
			}
		}
		
		protected function onFocusIn(evt:FocusEvent):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
		}
		
		protected function onFocusOut(evt:FocusEvent):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false);
			dispatchEvent(new Event(EditableClickableText.EDIT_DONE));
			
			// there's some kind of intermittent bug where underlines persist after editing
			// this line has been added in the hope of preventing this behavior
			_format.underline = false;
			
			setEditable(false);
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) stage.focus = null;
		}
		
		protected function onMouseDown(evt:MouseEvent):void {
			if (evt.target!=_field && evt.target!=_halo) stage.focus = null;
		}
		
	}	
}
