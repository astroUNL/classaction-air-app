
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.download.Downloader;
	
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	
	
	public class ModuleView extends Sprite {
		
		public static const QUESTION_SELECTED:String = "questionSelected";
		public static const MODULES_LIST_SELECTED:String = "modulesListSelected";
		
		protected var _emptyFormat:TextFormat;
		protected var _emptyMessage:ClickableText;
		
		protected var _width:Number = 800;
		protected var _height:Number = 500;
		
		public function ModuleView() {
			
			_headingFormat = new TextFormat("Verdana", 14, 0xffffff, true);
			_preLoadFormat = new TextFormat("Verdana", 12, 0x808080);
			_successFormat = new TextFormat("Verdana", 12, 0xffffff);
			_failureFormat = new TextFormat("Verdana", 12, 0xff8080);
			_emptyFormat = new TextFormat("Verdana", 14, 0xffffff); 
			_emptyFormat.align = "center";
			_emptyFormat.leading = 5;
			
			_emptyMessage = new ClickableText("this module has no questions\rclick here to return to modules list", null, _emptyFormat);
			_emptyMessage.addEventListener(ClickableText.ON_CLICK, onReturnToModulesList);
			_emptyMessage.x = (_width-_emptyMessage.width)/2;
			_emptyMessage.y = (_height-_emptyMessage.height)/2;
			_emptyMessage.visible = false;
			addChild(_emptyMessage);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		protected function onReturnToModulesList(evt:Event):void {
			dispatchEvent(new Event(ModuleView.MODULES_LIST_SELECTED));
		}
		
		protected var _timer:Timer;
		
		
		protected var _headingFormat:TextFormat;
		
		protected var _maxCursorY:Number = 400;
		protected var _maxHeadingY:Number = _maxCursorY - 100;
		protected var _columnWidth:Number = 280;
		
		protected var _cursorX:Number = 0;
		protected var _cursorY:Number = 0;
		
		protected var _headingPreMargin:Number = 10;
		protected var _headingPostMargin:Number = 4;
				
		protected var _questionPostMargin:Number = 0;
		
		
		
		protected var _preLoadFormat:TextFormat;
		protected var _successFormat:TextFormat;
		protected var _failureFormat:TextFormat;
		
		protected var _ctsList:Array;		
		
		
		protected function onTimer(evt:TimerEvent):void {
			
			var startTimer:Number = getTimer();
			
			var format:TextFormat;
			var i:int;
			var numFinished:int = 0;
			
			for (i=0; i<_ctsList.length; i++) {
				
				if (_ctsList[i].question.downloadState<Downloader.DONE_SUCCESS) {
					format = _preLoadFormat;
				}
				else if (_ctsList[i].question.downloadState==Downloader.DONE_SUCCESS) {
					format = _successFormat;
					numFinished++;
				}
				else {
					format = _failureFormat;
					numFinished++;
				}
				
				_ctsList[i].clickableText.setFormat(format);
			}
			if (numFinished>=_ctsList.length) _timer.stop();
			
//			trace("numFinished: "+numFinished);
//			trace("onTimer: "+(getTimer()-startTimer));
			
			
			evt.updateAfterEvent();
		}
		
		
		protected function addQuestions(list:Array):void {
			
			var ct:ClickableText;
			var name:String;
			var i:int;
			
			var format:TextFormat;
			
			var ctsList:Array = [];
			var numFinished:int = 0;
			
			for (i=0; i<list.length; i++) {
				name = (i<9) ? " " : "";
				name += (i+1).toString() + " - " + list[i].name;
								
				if (list[i].downloadState<Downloader.DONE_SUCCESS) {
					format = _preLoadFormat;
				}
				else if (list[i].downloadState==Downloader.DONE_SUCCESS) {
					format = _successFormat;
					numFinished++;
				}
				else {
					format = _failureFormat;
					numFinished++;
				}
				
				ct = new ClickableText(name, {item: list[i]}, format, 250);
				ct.x = _cursorX;
				ct.y = _cursorY;
//				ct.contextMenu = new ContextMenu();
//				ct.contextMenu.hideBuiltInItems();
//				ct.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onQuestionMenuSelect);
				ResourceContextMenuController.register(ct);
				ct.addEventListener(ClickableText.ON_CLICK, onQuestionClicked, false, 0, true);
				addChild(ct);
				
				_cursorY += ct.height + _questionPostMargin;
				if (_cursorY>_maxCursorY) {
					_cursorY = _topY;
					_cursorX += _columnWidth;
				}
				
				_ctsList.push({clickableText: ct, question: list[i]});
			}
			
			if (numFinished<_ctsList.length) _timer.start();
			else _timer.stop();
		}
		
		protected var _leftX:Number = 20;
		protected var _topY:Number = 20;
		
		protected function addHeading(text:String):void {
			if (_cursorY!=_topY) _cursorY += _headingPreMargin;
			if (_cursorY>_maxHeadingY) {
				_cursorY = _topY;
				_cursorX += _columnWidth;
			}
			var t:TextField = new TextField();
			t.x = _cursorX;
			t.y = _cursorY;
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_headingFormat);
			t.embedFonts = true;
			addChild(t);
			_cursorY += t.height + _headingPostMargin;			
			if (_cursorY>_maxCursorY) {
				_cursorY = _topY;
				_cursorX += _columnWidth;
			}
		}
		
		
		protected function redrawMenu():void {
			
			var startTimer:Number = getTimer();
			
			_cursorX = _leftX;
			_cursorY = _topY;		
			
			_ctsList = [];
			
			
			// this is inefficient -- may want to find a way to reuse the clickable text links
			// also, are we sure that these objects are getting garbage collected?
			try {
				while (getChildAt(0)) {
					removeChildAt(0);
				}
			}
			catch (err:Error) {
				//
			}
			
			var total:int = 0;
			
			if (module.warmupQuestionsList.length>0) {
				addHeading("Warmup Questions");
				addQuestions(module.warmupQuestionsList);
				total++;
			}
			if (module.generalQuestionsList.length>0) {
				addHeading("General Questions");
				addQuestions(module.generalQuestionsList);
				total++;
			}
			if (module.challengeQuestionsList.length>0) {
				addHeading("Challenge Questions");
				addQuestions(module.challengeQuestionsList);
				total++;
			}
			if (module.discussionQuestionsList.length>0) {
				addHeading("Discussion Questions");
				addQuestions(module.discussionQuestionsList);
				total++;
			}
			
			_emptyMessage.visible = (total==0);
			addChild(_emptyMessage); // since it's getting removed
			
//			trace("redrawMenu: "+(getTimer()-startTimer));			
		}
		
		protected function onQuestionClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(ModuleView.QUESTION_SELECTED, evt.target.data.item));
		}
		
		protected var _modulesList:ModulesList;
		public function set modulesList(arg:ModulesList):void {
			_modulesList = arg;
		}
		
		protected function onModuleUpdate(evt:Event):void {
			redrawMenu();
		}
		
		protected var _module:Module;
		
		public function get module():Module {
			return _module;
		}
		
		public function set module(m:Module):void {
			if (_module!=null) _module.removeEventListener(Module.UPDATE, onModuleUpdate, false);
			if (m!=null) m.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
			_module = m;
			redrawMenu();
		}
		
	}
}

