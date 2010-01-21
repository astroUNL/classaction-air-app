
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	public class ClickableText extends Sprite {
		
		public static const ON_CLICK:String = "onClick";
		
		public static var defaultFormat:TextFormat = new TextFormat("Verdana", 14, 0xffffff);
		
		public var data:* = null;
		
		protected var _text:String;
		protected var _format:TextFormat;
		protected var _width:Number;
		
		protected var _field:TextField;
//		protected var _enabled:Boolean = false;
		protected var _clickable:Boolean;
		
		public function ClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			
			_format = new TextFormat();
			
			_field = new TextField();
			_field.autoSize = "none";				
			_field.border = false;
			_field.background = false;
			_field.multiline = false;
			_field.type = "dynamic";
			_field.selectable = false;
			_field.embedFonts = true;			
			addChild(_field);
			
			mouseChildren = false;
			
			// _clickable must initially be set to the opposite of what's intended
			_clickable = false;
			setClickable(true);
			
			lock();
			
			setText(text);
			this.data = data;
			setFormat(format);
			setWidth(width);
			
			unlock();
		}
		
		public function get text():String {
			return _field.text;
		}
		
		public function addMenuItem(label:String, listener:Function=null, separatorBefore:Boolean=false):ContextMenuItem {
			var item:ContextMenuItem = new ContextMenuItem(label, separatorBefore);
			if (listener!=null) item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, listener, false, 0, true);
			contextMenu.customItems.push(item);
			return item;
		}		
		
		public function setClickable(arg:Boolean):void {
			if (arg && !_clickable) doSetClickable(arg);
			else if (!arg && _clickable) {
				doSetClickable(arg);
				showUnderline(false);
			}
			_clickable = arg;
		}
		
		protected function doSetClickable(arg:Boolean):void {
			// this function is separate from setClickable for the benefit of the EditableClickableText class
			if (arg) {
				addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false, 0, true);
			}
			else {
				removeEventListener(MouseEvent.CLICK, onClick, false);
				removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false);
				removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false);
			}
			buttonMode = arg;
			useHandCursor = arg;
			tabEnabled = arg;
		}
		
//		public function setEnabled(arg:Boolean):void {
//			if (arg && !_enabled) doSetEnabled(arg);
//			else if (!arg && _enabled) doSetEnabled(arg);
//			_enabled = arg;
//		}
//		
//		protected function doSetEnabled(arg:Boolean):void {
//			// this is a separate function from setEnabled for the benefit of the EditableClickableText class
//			if (arg) {
//				addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
//				addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false, 0, true);
//				addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false, 0, true);
//			}
//			else {
//				removeEventListener(MouseEvent.CLICK, onClick, false);
//				removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false);
//				removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false);				
//			}
//			buttonMode = arg;
//			useHandCursor = arg;
//			tabEnabled = arg;
//		}
		
		public function setText(text:String=""):void {
			_text = text;
			redraw();
		}
		
		public function setFormat(format:TextFormat=null):void {
			if (format==null) {
				_format.font = ClickableText.defaultFormat.font;
				_format.size = ClickableText.defaultFormat.size;
				_format.color = ClickableText.defaultFormat.color;
				_format.bold = ClickableText.defaultFormat.bold;
				_format.italic = ClickableText.defaultFormat.italic;
			}
			else {
				_format.font = format.font;
				_format.size = format.size;
				_format.color = format.color;
				_format.bold = format.bold;
				_format.italic = format.italic;
			}			
			_field.defaultTextFormat = _format;
			redraw();
		}
		
		public function setWidth(width:Number):void {
			_width = width;
			redraw();
		}
		
		protected function redraw():void {
			if (_locked) return;
			
			_field.text = "";
			_field.scrollH = 0;
			_field.scrollV = 0;
			_field.autoSize = "left";
			_field.height = 0;
			_field.width = _width;
			if (_width!=0) {
				_field.multiline = true;
				_field.wordWrap = true;
			}
			else {
				_field.multiline = false;
				_field.wordWrap = false;
			}
			_field.text = _text;
		}
		
		protected function onClick(evt:MouseEvent):void {
			if (_clickable) dispatchEvent(new Event(ClickableText.ON_CLICK));
//			if (_enabled) dispatchEvent(new Event(ClickableText.ON_CLICK));
		}
		
		protected function onMouseOverFunc(evt:MouseEvent):void {
			showUnderline(true);
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			showUnderline(false);
		}
		
		protected function showUnderline(arg:Boolean):void {
			_format.underline = arg;
			_field.defaultTextFormat = _format;
			_field.setTextFormat(_format);
		}
		
		protected var _locked:Boolean = false;
		
		public function lock():void {
			_locked = true;
		}
		
		public function unlock():void {
			_locked = false;	
			redraw();
		}
		
		override public function toString():String {
			return "[object ClickableText, text: " + _text + "]";
			
		}
		
	}
}

