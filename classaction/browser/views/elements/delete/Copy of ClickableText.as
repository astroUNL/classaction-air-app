
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.text.StyleSheet;
	
	public class ClickableText extends Sprite {
				
		public var data:*;
		public var text:String;
		protected var _tf:TextField;
		protected var _format:TextFormat;
		
		public static const ON_CLICK:String = "onClick";
		
		public function ClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			setProperties(text, data, format, width);
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			tabEnabled = true;
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc);
		}
		
		protected var _enabled:Boolean = true;
		
		protected function onClick(evt:MouseEvent):void {
			if (_enabled) dispatchEvent(new Event(ClickableText.ON_CLICK));
			//if (!_enabled) evt.stopImmediatePropagation();
		}
		
		public function setEnabled(arg:Boolean):void {
			_enabled = arg;
			buttonMode = _enabled;
			useHandCursor = _enabled;
		}
		
		
		
		protected var _style:StyleSheet;
		
		public function setStyleSheet(style:StyleSheet):void {
			_style = style;
			_tf.styleSheet = _style;
		}
		
		protected function initStyle():void {
			_style = new StyleSheet();
			_style.setStyle("body", {fontFamily: "Verdana", fontSize: 12, color: "#000000", fontWeight: "normal", fontStyle: "normal"});
		}
		
		public function setProperties(text:String="", data:*=null, format:TextFormat=null, width:Number=0):void {
			this.text = text;
			this.data = data;
			
			if (_style==null) initStyle();
			
			if (format!=null) _style.setStyle("body", {fontFamily: format.font, fontSize: format.size, color: "#"+format.color.toString(16), fontWeight: (format.bold) ? "bold" : "normal", fontStyle: (format.italic) ? "italic" : "normal"});
			
			// may want to try to reuse textfields?
			if (_tf!=null) removeChild(_tf);
			
			_tf = new TextField();
			_tf.styleSheet = _style;
			_tf.htmlText = "<body>" + this.text + "</body>";
			_tf.autoSize = "left";
			_tf.height = 0;
			_tf.width = width;
			if (width!=0) {
				_tf.multiline = true;
				_tf.wordWrap = true;
			}
			_tf.selectable = false;
			_tf.embedFonts = true;
			
			addChild(_tf);			
		}
		
		public function setTextFormat(format:TextFormat):void {
			if (_style==null) initStyle();			
			if (format!=null) {
				_style.setStyle("body", {fontFamily: format.font, fontSize: format.size, color: "#"+format.color.toString(16), fontWeight: (format.bold) ? "bold" : "normal", fontStyle: (format.italic) ? "italic" : "normal"});
				_tf.styleSheet = _style;
			}
		}
		
		protected function onMouseOverFunc(evt:MouseEvent):void {
			if (_enabled) {				
				var obj:Object = _style.getStyle("body");
				obj.textDecoration = "underline";
				_style.setStyle("body", obj);
			}
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			var obj:Object = _style.getStyle("body");
			obj.textDecoration = "none";
			_style.setStyle("body", obj);	
		}
		
	}
}

