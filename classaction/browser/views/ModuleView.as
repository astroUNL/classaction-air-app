
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.download.Downloader;
	
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import astroUNL.utils.logger.Logger;
	
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
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		
		protected var _leftButton:ModuleViewNavButton;
		protected var _rightButton:ModuleViewNavButton;
		
		protected var _navButtonSpacing:Number = 20;
		protected var _columnSpacing:Number = 10;
		protected var _numColumns:int = 3;
		protected var _easeTime:Number = 350;
		
		protected var _panes:ScrollableLayoutPanes;
		
		public function ModuleView(width:Number, height:Number) {
			
			_width = width;
			_height = height;
			
			_headingFormat = new TextFormat("Verdana", 14, 0xffffff, true);
			_preLoadFormat = new TextFormat("Verdana", 12, 0x808080);
			_successFormat = new TextFormat("Verdana", 12, 0xffffff);
			_failureFormat = new TextFormat("Verdana", 12, 0xff8080);
			_emptyFormat = new TextFormat("Verdana", 14, 0xffffff);
			_emptyFormat.align = "center";
			_emptyFormat.leading = 5;
			
			_panesWidth = _width - 4*_navButtonSpacing;
			_panesHeight = _height;
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = 2*_navButtonSpacing;
			addChild(_panes);
			
			_emptyMessage = new ClickableText("this module has no questions\rclick here to return to modules list", null, _emptyFormat);
			_emptyMessage.addEventListener(ClickableText.ON_CLICK, onReturnToModulesList);
			_emptyMessage.x = (_width-_emptyMessage.width)/2;
			_emptyMessage.y = (_height-_emptyMessage.height)/2;
			_emptyMessage.visible = false;
			addChild(_emptyMessage);
			
			_leftButton = new ModuleViewNavButton();
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _height/2;
			_leftButton.scaleX = -1;
			_leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClicked, false, 0, true);
//			_leftButton.visible = false;
			addChild(_leftButton);
			
			_rightButton = new ModuleViewNavButton();
			_rightButton.x = _width - _navButtonSpacing;
			_rightButton.y = _height/2;
			_rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClicked, false, 0, true);
//			_rightButton.visible = false;
			addChild(_rightButton);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
					
			_warmupHeading = createHeading("Warmup Questions");
			_generalHeading = createHeading("General Questions");
			_challengeHeading = createHeading("Challenge Questions");
			_discussionHeading = createHeading("Discussion Questions");			
			
		}
		
		protected var _warmupHeading:TextField;
		protected var _generalHeading:TextField;
		protected var _challengeHeading:TextField;
		protected var _discussionHeading:TextField;
		
		protected function createHeading(text:String):TextField {
			var tf:TextField = new TextField();
			tf.text = text;
			tf.autoSize = "left";
			tf.height = 0;
			tf.width = _panes.columnWidth;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.selectable = false;
			tf.setTextFormat(_headingFormat);
			tf.embedFonts = true;
			return tf;
		}
		
		protected function onLeftButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(-1, _easeTime);
		}
		
		protected function onRightButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(1, _easeTime);
		}	
		
		protected function onReturnToModulesList(evt:Event):void {
			dispatchEvent(new Event(ModuleView.MODULES_LIST_SELECTED));
		}
		
		protected var _timer:Timer;
		
		protected var _headingParams:Object = {topMargin: 10,
											   bottomMargin: 4,
											   minLeftOver: 0};
											   
		protected var _questionParams:Object = {leftMargin: 0,
											    bottomMargin: 0,
												minLeftOver: 0};
		
		protected var _headingFormat:TextFormat;
		protected var _preLoadFormat:TextFormat;
		protected var _successFormat:TextFormat;
		protected var _failureFormat:TextFormat;
		
//		protected var _maxCursorY:Number = 400;
//		protected var _maxHeadingY:Number = _maxCursorY - 100;
//		protected var _columnWidth:Number = 280;
		
//		protected var _cursorX:Number = 0;
//		protected var _cursorY:Number = 0;
		
//		protected var _headingPreMargin:Number = 10;
//		protected var _headingPostMargin:Number = 4;
		
//		protected var _questionPostMargin:Number = 0;
		
		
//		protected var _ctsList:Array;		
		
		
		protected function onTimer(evt:TimerEvent):void {
			var startTimer:Number = getTimer();
			var allFinished:Boolean = refresh();
			if (allFinished) _timer.stop();			
			evt.updateAfterEvent();
			
			
//			
//			
//			var format:TextFormat;
//			var i:int;
//			var numFinished:int = 0;
//			
//			for (i=0; i<_ctsList.length; i++) {
//				
//				if (_ctsList[i].question.downloadState<Downloader.DONE_SUCCESS) {
//					format = _preLoadFormat;
//				}
//				else if (_ctsList[i].question.downloadState==Downloader.DONE_SUCCESS) {
//					format = _successFormat;
//					numFinished++;
//				}
//				else {
//					format = _failureFormat;
//					numFinished++;
//				}
//				
//				_ctsList[i].clickableText.setFormat(format);
//			}
//			if (numFinished>=_ctsList.length) _timer.stop();
//			
////			trace("numFinished: "+numFinished);
////			trace("onTimer: "+(getTimer()-startTimer));
//			
//			
		}
		
		
//		protected function addQuestions(list:Array):void {
//			
//			var ct:ClickableText;
//			var name:String;
//			var i:int;
//			
//			var format:TextFormat;
//			
//			var ctsList:Array = [];
//			var numFinished:int = 0;
//			
//			for (i=0; i<list.length; i++) {
//				name = (i<9) ? " " : "";
//				name += (i+1).toString() + " - " + list[i].name;
//								
//				if (list[i].downloadState<Downloader.DONE_SUCCESS) {
//					format = _preLoadFormat;
//				}
//				else if (list[i].downloadState==Downloader.DONE_SUCCESS) {
//					format = _successFormat;
//					numFinished++;
//				}
//				else {
//					format = _failureFormat;
//					numFinished++;
//				}
//				
//				ct = new ClickableText(name, {item: list[i]}, format, 250);
//				ct.x = _cursorX;
//				ct.y = _cursorY;
////				ct.contextMenu = new ContextMenu();
////				ct.contextMenu.hideBuiltInItems();
////				ct.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onQuestionMenuSelect);
//				ResourceContextMenuController.register(ct);
//				ct.addEventListener(ClickableText.ON_CLICK, onQuestionClicked, false, 0, true);
//				addChild(ct);
//				
//				_cursorY += ct.height + _questionPostMargin;
//				if (_cursorY>_maxCursorY) {
//					_cursorY = _topY;
//					_cursorX += _columnWidth;
//				}
//				
//				_ctsList.push({clickableText: ct, question: list[i]});
//			}
//			
//			if (numFinished<_ctsList.length) _timer.start();
//			else _timer.stop();
//		}
		
//		protected var _leftX:Number = 20;
//		protected var _topY:Number = 20;
//		
//		protected function addHeading(text:String):void {
//			if (_cursorY!=_topY) _cursorY += _headingPreMargin;
//			if (_cursorY>_maxHeadingY) {
//				_cursorY = _topY;
//				_cursorX += _columnWidth;
//			}
//			var t:TextField = new TextField();
//			t.x = _cursorX;
//			t.y = _cursorY;
//			t.text = text;
//			t.autoSize = "left";
//			t.height = 0;
//			t.width = _columnWidth;
//			t.multiline = true;
//			t.wordWrap = true;			
//			t.selectable = false;
//			t.setTextFormat(_headingFormat);
//			t.embedFonts = true;
//			addChild(t);
//			_cursorY += t.height + _headingPostMargin;			
//			if (_cursorY>_maxCursorY) {
//				_cursorY = _topY;
//				_cursorX += _columnWidth;
//			}
//		}
		
		
//		protected function redrawMenu():void {
//			redraw();
//			return;
//			
//			var startTimer:Number = getTimer();
//			
//			_cursorX = _leftX;
//			_cursorY = _topY;		
//			
//			_ctsList = [];
//			
//			
//			// this is inefficient -- may want to find a way to reuse the clickable text links
//			// also, are we sure that these objects are getting garbage collected?
//			try {
//				while (getChildAt(0)) {
//					removeChildAt(0);
//				}
//			}
//			catch (err:Error) {
//				//
//			}
//			
//			var total:int = 0;
//			
//			if (module.warmupQuestionsList.length>0) {
//				addHeading("Warmup Questions");
//				addQuestions(module.warmupQuestionsList);
//				total++;
//			}
//			if (module.generalQuestionsList.length>0) {
//				addHeading("General Questions");
//				addQuestions(module.generalQuestionsList);
//				total++;
//			}
//			if (module.challengeQuestionsList.length>0) {
//				addHeading("Challenge Questions");
//				addQuestions(module.challengeQuestionsList);
//				total++;
//			}
//			if (module.discussionQuestionsList.length>0) {
//				addHeading("Discussion Questions");
//				addQuestions(module.discussionQuestionsList);
//				total++;
//			}
			
//			_emptyMessage.visible = (total==0);
//			addChild(_emptyMessage); // since it's getting removed
//			
//			trace("redrawMenu: "+(getTimer()-startTimer));			
//		}
		
		protected function onQuestionClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(ModuleView.QUESTION_SELECTED, evt.target.data.item));
		}
		
		protected function onModuleUpdate(evt:Event):void {
			redraw();
		}
		
		protected var _module:Module;
		
		public function get module():Module {
			return _module;
		}
		
		public function set module(m:Module):void {
			if (_module!=null) _module.removeEventListener(Module.UPDATE, onModuleUpdate, false);
			if (m!=null) m.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
			_module = m;
			_panes.paneNum = 0;
			redraw();
		}
		
		
		/*******************************************************************/
		
		import flash.utils.Dictionary;
		
		
		
		protected function redraw():void {
			// this function clears the panes and adds the module's content
			// then it calls refresh
			
			var startTimer:Number = getTimer();
			
			var i:int;
			var links:Array;
			
			var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			if (_module.allQuestionsList.length>0) {
				_emptyMessage.visible = false;
				addQuestions(_warmupHeading, _module.warmupQuestionsList);
				addQuestions(_generalHeading, _module.generalQuestionsList);
				addQuestions(_challengeHeading, _module.challengeQuestionsList);
				addQuestions(_discussionHeading, _module.discussionQuestionsList);
			}
			else _emptyMessage.visible = true;
			
			_panes.paneNum = oldPaneNum;
			
			_leftButton.visible = _rightButton.visible = (_panes.numPanes>1);
			
			trace("redraw module view: "+(getTimer()-startTimer));
			var allFinished:Boolean = refresh();
			if (!allFinished) _timer.start();
		}
		
		protected function addQuestions(heading:TextField, questionsList:Array):void {
			if (questionsList.length>0) {
				var links:Array = getLinks(questionsList);
				_headingParams.minLeftOver = _questionParams.bottomMargin + links[0].height;
				_panes.addContent(heading, _headingParams);
				for (var i:int = 0; i<links.length; i++) {
					trace("adding question: "+links[i].data.item.name+", "+links[i].data.item.id);
					_panes.addContent(links[i], _questionParams);
				}
			}
		}
		
		protected function refresh():Boolean {
			// this function updates the colors of the ClickableText links to match
			// the download state of the questions
			// it returns a boolean value indicating whether all questions have finished
			// downloading (successfully or otherwise)
			var numFinished:int = 0;
			var i:int;
			var q:Question;
			var ct:ClickableText;
			var format:TextFormat;
			for (i=0; i<_module.allQuestionsList.length; i++) {
				q = _module.allQuestionsList[i];
				ct = (_links[q] as ClickableText);
				if (ct!=null) {
					if (q.downloadState!=ct.data.lastDownloadState) {
						ct.data.lastDownloadState = q.downloadState;
						ct.setFormat(getFormat(q.downloadState));
					}
				}
				else Logger.report("null question link in ModuleView.refresh");				
				if (q.downloadState>=Downloader.DONE_SUCCESS) numFinished++;
			}
			return (numFinished==_module.allQuestionsList.length);
		}
		
		protected var _links:Dictionary = new Dictionary();
		
		protected function getFormat(state:int):TextFormat {
			if (state<Downloader.DONE_SUCCESS) return _preLoadFormat;
			else if (state==Downloader.DONE_SUCCESS) return _successFormat;
			else return _failureFormat;
		}
		
		protected function getLinks(questionsList:Array):Array {
			// this function returns the list of ClickableText links associated with the given list of
			// questions, creating the links if necessary
			// it also sets the text of the link to indicate the question number
			var i:int;
			var name:String;
			var ct:ClickableText;
			var links:Array = [];
			for (i=0; i<questionsList.length; i++) {
				name = (i<9) ? " " : "";
				name += (i+1).toString() + " - " + questionsList[i].name;
				if (_links[questionsList[i]]==undefined) {
					ct = new ClickableText(name, {item: questionsList[i], lastDownloadState: questionsList[i].downloadState}, getFormat(questionsList[i].downloadState), _panes.columnWidth);
					ct.addEventListener(ClickableText.ON_CLICK, onQuestionClicked, false, 0, true);
					ResourceContextMenuController.register(ct);
					_links[questionsList[i]] = ct;					
					links.push(ct);
				}
				else {
					_links[questionsList[i]].setText(name);
					links.push(_links[questionsList[i]]);
				}
			}			
			return links;
		}
		
	}
}

