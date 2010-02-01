
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.text.TextLineMetrics;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	import flash.utils.getTimer;
	
	public class ClickableText extends Sprite {
		
		public static const ON_CLICK:String = "onClick";
		
		public static var defaultFormat:TextFormat = new TextFormat("Verdana", 14, 0xffffff);
		
		public var data:* = null;
		
		protected var _text:String;
		protected var _format:TextFormat;
		protected var _width:Number;
		
		protected var _field:TextField;
		protected var _clickable:Boolean;
		
		protected var _hitArea:Sprite;
		
		public function ClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			contextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
			contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onContextMenuSelect, false, 0, true);
			
			_format = new TextFormat();
			
			_field = new TextField();
			_field.autoSize = "none";
			_field.border = false;
			_field.background = false;
			_field.multiline = false;
			_field.type = "dynamic";
			_field.selectable = false;
			_field.embedFonts = true;
			_field.mouseEnabled = false;
			addChild(_field);
			
			_hitArea = new Sprite();
			_hitArea.visible = false;
			_hitArea.mouseEnabled = false;
			addChild(_hitArea);
			
			hitArea = _hitArea;
			
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
				_format.align = ClickableText.defaultFormat.align;
				_format.leading = ClickableText.defaultFormat.leading;
			}
			else {
				_format.font = format.font;
				_format.size = format.size;
				_format.color = format.color;
				_format.bold = format.bold;
				_format.italic = format.italic;
				_format.align = format.align;
				_format.leading = format.leading;
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
			
			var i:int;
			var m:TextLineMetrics;
			_hitArea.graphics.clear();
			for (i=0; i<_field.numLines; i++) {
				m = _field.getLineMetrics(i);
				_hitArea.graphics.beginFill(0x0000ff, 0.5);
				
				if (_field.defaultTextFormat.align=="left") {
					_hitArea.graphics.drawRect(_field.x+2, _field.y+2+i*m.height, m.width, m.height);
				}
				else if (_field.defaultTextFormat.align=="center") {
					_hitArea.graphics.drawRect(_field.x+((_field.width-m.width)/2), _field.y+2+i*m.height, m.width, m.height);
				}
				else {
					_hitArea.graphics.drawRect(_field.x+_field.width-m.width-2, _field.y+2+i*m.height, m.width, m.height);
				}
				
				_hitArea.graphics.endFill();
			}
		}
		
		protected function onClick(evt:MouseEvent):void {
			if (_clickable) dispatchEvent(new Event(ClickableText.ON_CLICK));
		}
		
		// Problem: When the user right-clicks on the text the mouseOut event is dispatched,
		// however, we'd like to keep the text underlined while the context menu is shown.
		// Solution: This is done by watching for the menuSelect event, which is called just
		// before the mouseOut event. So, when the menuSelect event comes we set a flag
		// (skipMouseOutPropagation) that lets the mouseOut handler know to ignore and stop
		// the next mouseOut event. Now, to know when the context menu has been closed we
		// listen for a mouseOver event from the stage. When this happens we dispatch a
		// mouseOut event -- effectively the one we suppressed when the context menu was
		// selected. Note that it's possible that this ClickableText instance might be removed
		// from the stage as a result of user interaction with the context menu (e.g. the user
		// deletes a module). In this case we listen for a removedFromStage event so we can
		// deregister the mouseOver listener for the stage.
		// Note: the skipMouseOutPropagation flag is reset (set to false) in the mouseOver handler
		// or the stage mouseOver handler, but in the latter case its existing value is used to
		// determine whether to dispatch the mouseOut event. This is done in case the user opens the
		// context menu, then clicks somewhere else on the same text item to close the menu. (The
		// stage mouseOver event follows the text's mouseOver event, and in this case we don't want
		// the mouseOut event fired).	
		
		protected function onMouseOverFunc(evt:MouseEvent):void {
			_skipMouseOutPropagation = false;
			showUnderline(true);
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			if (_skipMouseOutPropagation) evt.stopImmediatePropagation();
			else showUnderline(false);
		}
		
		protected function showUnderline(arg:Boolean):void {
			_format.underline = arg;
			_field.defaultTextFormat = _format;
			_field.setTextFormat(_format);
		}
		
		protected var _skipMouseOutPropagation:Boolean;
		
		protected function onContextMenuSelect(evt:ContextMenuEvent):void {
			_skipMouseOutPropagation = true;
			stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}
		
		protected function onStageMouseOver(evt:MouseEvent):void {
			if (_skipMouseOutPropagation) {
				_skipMouseOutPropagation = false;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
			}
			stage.removeEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
		}
		
		protected function onRemovedFromStage(evt:Event):void {
			// the ClickableText could be removed from stage for a variety of reasons
			// (for example, the ModulesListView removes and then adds back ClickableText
			// objects when it redraws the list)
			if (_skipMouseOutPropagation) {
				_skipMouseOutPropagation = false;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
			}
			stage.removeEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
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

