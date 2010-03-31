﻿
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.views.elements.EditableClickableText;
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	import astroUNL.classaction.browser.events.StateChangeRequestEvent;
	
	import astroUNL.utils.logger.Logger;	
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class Breadcrumbs extends Sprite {
		
//		public static const QUESTION_SELECTED:String = "questionSelected";
//		public static const MODULE_SELECTED:String = "moduleSelected";
//		public static const MODULES_LIST_SELECTED:String = "modulesListSelected";
		
		protected var _modulesListLink:ClickableText;
		protected var _moduleLink:ClickableText;
		protected var _editableModuleLink:EditableClickableText;
		protected var _questionLink:ClickableText;
		protected var _questionNum:ClickableText;
		
		protected var _content:Sprite;
		protected var _mask:Shape;
		
		protected var _prevButton:QuestionNavButton;
		protected var _nextButton:QuestionNavButton;
		
		protected var _separator:String = "»";
		protected var _separator1:ClickableText;
		protected var _separator2:ClickableText;
		
		protected var _separatorTextFormat:TextFormat;
		protected var _linkTextFormat:TextFormat;
		protected var _questionNumFormat:TextFormat;
		
		protected var _spacing:Number = 4;
		protected var _questionButtonLeftSpacing:Number = 11;
		protected var _questionButtonRightSpacing:Number = 7;
		
		protected var _module:Module;
		protected var _question:Question;
		
		
		public function Breadcrumbs() {
			
			_linkTextFormat = new TextFormat("Verdana", 12, 0xffffff, true);
			_questionNumFormat = new TextFormat("Verdana", 11, 0xC2C5C4, true, null, null, null, null, "center");
			_separatorTextFormat = new TextFormat("Verdana", 11, 0xC2C5C4, true);
			
			_content = new Sprite();
			addChild(_content);
			
			_mask = new Shape();
			addChild(_mask);
			
			_separator1 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator1.visible = false;
			_separator1.setClickable(false);
			_content.addChild(_separator1);
			
			_separator2 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator2.visible = false;
			_separator2.setClickable(false);
			_content.addChild(_separator2);
			
			_modulesListLink = new ClickableText("All Modules", null, _linkTextFormat);
			_modulesListLink.addEventListener(ClickableText.ON_CLICK, onModulesListClicked);
			_modulesListLink.visible = false;
			_content.addChild(_modulesListLink);
			
			_moduleLink = new ClickableText("", null, _linkTextFormat);
			_moduleLink.addEventListener(ClickableText.ON_CLICK, onModuleClicked);
			_moduleLink.visible = false;
			_content.addChild(_moduleLink);
			
			_editableModuleLink = new EditableClickableText("", null, _linkTextFormat);
			_editableModuleLink.addEventListener(ClickableText.ON_CLICK, onModuleClicked);
			_editableModuleLink.addEventListener(EditableClickableText.EDIT_DONE, onModuleNameEdited);
			_editableModuleLink.addEventListener(EditableClickableText.DIMENSIONS_CHANGED, onModuleNameEdited);
			_editableModuleLink.visible = false;
			_content.addChild(_editableModuleLink);
			
			_questionLink = new ClickableText("", null, _linkTextFormat);
			_questionLink.visible = false;
			_questionLink.setClickable(false);
			_content.addChild(_questionLink);
			
			_questionNum = new ClickableText("888", null, _questionNumFormat);
			_questionNum.visible = false;
			_questionNum.setClickable(false);
			_questionNum.y = 1;
			_content.addChild(_questionNum);
			
			var midY:Number = 1 + _questionNum.height/2;
			var halfQuestionButtonGap:Number = 1.5;
			
			_prevButton = new QuestionNavButton();
			_prevButton.addEventListener(MouseEvent.CLICK, gotoPrevQuestion);
			_prevButton.visible = false;
			_prevButton.rotation = -90;
			_prevButton.y = midY - halfQuestionButtonGap;
			_content.addChild(_prevButton);
			
			_nextButton = new QuestionNavButton();
			_nextButton.addEventListener(MouseEvent.CLICK, gotoNextQuestion);
			_nextButton.visible = false;
			_nextButton.rotation = 90;
			_nextButton.y = midY + halfQuestionButtonGap;
			_content.addChild(_nextButton);
			
			ResourceContextMenuController.register(_questionLink);
			
		}
		
		protected var _maxWidth:Number = 0;
		protected var _maxWidthLimit:Number = 5000;
		
		public function get maxWidth():Number {
			return _maxWidth;
		}
		
		public function set maxWidth(arg:Number):void {
			// maxWidth is the maximum amount of horizontal space the breadcrumbs get
			if (!isNaN(arg) && arg>0 && arg!=Number.NEGATIVE_INFINITY) {
				_maxWidth = arg;
				redrawMask();
			}
		}
		
		protected function redrawMask():void {
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xffff00, 0.3);
			_mask.graphics.drawRect(0, -5, Math.min(_maxWidth, _maxWidthLimit), 10);
			_mask.graphics.endFill();
		}
		
		protected function onModuleNameEdited(evt:Event):void {
			_module.name = evt.target.text;
		}
		
		protected function onModulesListClicked(evt:Event):void {
			dispatchEvent(new StateChangeRequestEvent(null, null, true));
//			dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULES_LIST_SELECTED, null));
		}
		
		protected function onModuleClicked(evt:Event):void {
			if (_module!=null) dispatchEvent(new StateChangeRequestEvent(_module, null, true));
//			if (_module!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULE_SELECTED, _module));
		}

		protected function onModuleUpdate(evt:Event):void {
			reposition();			
		}
		
		protected function gotoPrevQuestion(evt:MouseEvent):void {
			if (_prevQuestion!=null) dispatchEvent(new StateChangeRequestEvent(_module, _prevQuestion, true));
//			if (_prevQuestion!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.QUESTION_SELECTED, _prevQuestion));
		}
		
		protected function gotoNextQuestion(evt:MouseEvent):void {
			if (_nextQuestion!=null) dispatchEvent(new StateChangeRequestEvent(_module, _nextQuestion, true));
//			if (_nextQuestion!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.QUESTION_SELECTED, _nextQuestion));
		}
		
		protected var _nextQuestion:Question;
		protected var _prevQuestion:Question;
		
		public function setState(module:Module, question:Question):void {
			
			if (_module!=null) _module.removeEventListener(Module.UPDATE, onModuleUpdate, false);
			
			_module = module;
			_question = question;
			
			if (_module!=null) _module.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
			
			_modulesListLink.visible = true;
			_separator1.visible = true;
			
			// we set these later on, if their values are found
			_nextQuestion = null;
			_prevQuestion = null;
			
			if (_module!=null) {
				_modulesListLink.setClickable(true);
				
				if (_module.readOnly) {
					_moduleLink.setText(_module.name);
					_moduleLink.visible = true;
					_editableModuleLink.visible = false;
				}
				else {
					_editableModuleLink.setText(_module.name);
					_editableModuleLink.visible = true;
					_moduleLink.visible = false;
				}
				
				if (question!=null) {
					
					// please note that the code here assumes that each of the question types constants (which
					// are defined in Question) are unique integers in the range [0,3]
					var typesList:Array = [];
					typesList[Question.WARM_UP] = {prefix: "W", list: _module.warmupQuestionsList};
					typesList[Question.GENERAL] = {prefix: "G", list: _module.generalQuestionsList};
					typesList[Question.CHALLENGE] = {prefix: "C", list: _module.challengeQuestionsList};
					typesList[Question.DISCUSSION] = {prefix: "D", list: _module.discussionQuestionsList};
					
					if (typesList[question.questionType]!=undefined) {
						var list:Array = typesList[question.questionType].list;
						var prefix:String = typesList[question.questionType].prefix;
						
						var qNum:int;
						for (qNum=0; qNum<list.length; qNum++) if (list[qNum]==question) break;
						
						if (qNum<list.length) {
							
							var i:int;
							
							if (qNum==0) {
								// at the beginning of the current section
								var prevList:Array = [];
								for (i=1; i<=typesList.length; i++) {
									prevList = typesList[(question.questionType-i+typesList.length)%typesList.length].list;
									if (prevList.length!=0) break;
								}
								if (prevList.length!=0) _prevQuestion = prevList[prevList.length-1];
								else _prevQuestion = null;								
							}
							else _prevQuestion = list[qNum-1];
							
							if (qNum==(list.length-1)) {
								// at the end of the current section
								var nextList:Array = [];
								for (i=1; i<=typesList.length; i++) {
									nextList = typesList[(question.questionType+i)%typesList.length].list;
									if (nextList.length!=0) break;
								}
								if (nextList.length!=0) _nextQuestion = nextList[0];
								else _nextQuestion = null;								
							}
							else _nextQuestion = list[qNum+1];
							
							_questionNum.setText(prefix+String(qNum+1));
							_questionNum.visible = true;
						}
						else {
							Logger.report("question not found in module's list in breadcrumbs, module: "+_module.name+", question: "+_question.name);
							_questionNum.visible = false;
						}
					}
					else {
						Logger.report("invalid question type encountered in breadcrumbs, question: "+_question.name+", type: "+String(_question.questionType));
						_questionNum.visible = false;
					}
					
					_questionLink.setText(_question.name);
					
					_questionLink.visible = true;
					
					_questionLink.data = {item: _question};
					
					_moduleLink.setClickable(true);
					_editableModuleLink.setClickable(true);
					
					_separator2.visible = true;
				}
				else {
					_questionLink.visible = false;
					_questionNum.visible = false;
					
					_moduleLink.setClickable(false);
					_editableModuleLink.setClickable(false);
					
					_separator2.visible = false;
				}				
				
				_separator1.visible = true;				
			}
			else {
				_modulesListLink.setClickable(false);
				_moduleLink.visible = false;
				_editableModuleLink.visible = false;
				_questionLink.visible = false;
				_questionNum.visible = false;
				
				_separator1.visible = false;
				_separator2.visible = false;
			}
			
			_prevButton.visible = _nextButton.visible = _questionNum.visible;
			
//			trace("");
//			trace("prev question: "+((_prevQuestion!=null) ? _prevQuestion.name : "null"));
//			trace("next question: "+((_nextQuestion!=null) ? _nextQuestion.name : "null"));
			
			reposition();
		}
		
		protected function reposition():void {
			_modulesListLink.x = 0;
			_separator1.x = _modulesListLink.x + _modulesListLink.width + _spacing;
			_editableModuleLink.x = _moduleLink.x = _separator1.x + _separator1.width + _spacing;
			if (_module!=null) {
				if (_module.readOnly) _separator2.x = _moduleLink.x + _moduleLink.width + _spacing;
				else _separator2.x = _editableModuleLink.x + _editableModuleLink.width + _spacing;
				_prevButton.x = _separator2.x + _separator2.width + _questionButtonLeftSpacing;
				_nextButton.x = _prevButton.x;
				_questionNum.x = _prevButton.x + _questionButtonRightSpacing;				
				_questionLink.x = _questionNum.x + _questionNum.width + _spacing;
			}
		}
		
	}	
}
