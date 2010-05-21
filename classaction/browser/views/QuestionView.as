
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	
	public class QuestionView extends Sprite {
		
		protected var _errorMsg:MessageBubble;
		protected var _preloader:Preloader;
		protected var _timer:Timer;
		protected var _mask:Shape;
		protected var _loader:Loader;
		protected var _question:Question;
		protected var _maxWidth:Number = 780;
		protected var _maxHeight:Number = 515;
		
		protected var _editable:EditableQuestionView;
		
		public function QuestionView() {
			
			_mask = new Shape();
			addChild(_mask);
			
			_errorMsg = new MessageBubble();
			_errorMsg.visible = false;
			addChild(_errorMsg);
			
			_preloader = new Preloader();
			_preloader.x = 300;
			_preloader.y = 300;
			_preloader.visible = false;
			addChild(_preloader);
			
			_loader = new Loader();
			_loader.visible = false;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderDone);
			_loader.mask = _mask;
			addChild(_loader);
			
			_editable = new EditableQuestionView();
			_editable.visible = false;
			addChild(_editable);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function set question(q:Question):void {
			_question = q;
			if (_question!=null && !_question.readOnly) _editable.question = _question;
			refresh();
		}
		
		public function setMaxDimensions(w:Number, h:Number):void {
			_maxWidth = w;
			_maxHeight = h;
			
			refreshPositioning();
		}
		
		protected function onTimer(evt:TimerEvent):void {
			refresh();
			evt.updateAfterEvent();
		}
		
		protected function onLoaderDone(evt:Event):void {
			_loader.visible = true;
			refreshPositioning();
		}
		
		protected function refresh():void {
			if (_question==null) {
				_loader.unloadAndStop(true);
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = false;
				_editable.visible = false;
				if (_timer.running) _timer.stop();
				return;
			}
			
			if (_question.downloadState==Downloader.DONE_SUCCESS) {
				if (_question.readOnly) {
					_loader.loadBytes(_question.data);
					_editable.visible = false;
				}
				else {
					_editable.visible = true;
				}
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) _timer.stop();
			}
			else if (_question.downloadState==Downloader.DONE_FAILURE) {
				_errorMsg.setMessage("the question file failed to load");
				_errorMsg.visible = true;
				_preloader.visible = false;
				_loader.visible = false;
				_editable.visible = false;
				if (_timer.running) _timer.stop();
			}
			else {
				_errorMsg.visible = false;
				_preloader.visible = true;
				_loader.visible = false;
				_editable.visible = false;
				if (!_timer.running) _timer.start();				
			}
			
			refreshPositioning();
		}
		
		protected function refreshPositioning():void {
			
			var midX:Number = _maxWidth/2;
			var midY:Number = _maxHeight/2;
			
			_errorMsg.x = midX - _errorMsg.width/2;
			_errorMsg.y = midY - _errorMsg.height/2;
			
			_preloader.x = midX - _preloader.width/2;
			_preloader.y = midY - _preloader.height/2;
			
			var maxAspect:Number = _maxWidth/_maxHeight;
			var qAspect:Number = _question.width/_question.height;
			var qScale:Number, qWidth:Number, qHeight:Number;
			
			if (qAspect>maxAspect) {
				qScale = _maxWidth/_question.width;
				qWidth = qScale*_question.width;
				qHeight = qScale*_question.height;
			}
			else {
				qScale = _maxHeight/_question.height;
				qWidth = qScale*_question.width;
				qHeight = qScale*_question.height;
			}
			
			if (_loader.visible) {
				_loader.scaleX = _loader.scaleY = qScale;
				if (qAspect>maxAspect) {
					_loader.x = 0;
					_loader.y = (_maxHeight - qHeight)/2;
				}
				else {
					_loader.x = (_maxWidth - qWidth)/2;
					_loader.y = 0;
				}
				
				_mask.graphics.clear();
				_mask.graphics.moveTo(_loader.x, _loader.y);
				_mask.graphics.beginFill(0xffff00);
				_mask.graphics.drawRect(_loader.x, _loader.y, qWidth, qHeight);
				_mask.graphics.endFill();
			}
			else {
				_mask.graphics.clear();
			}
			
			if (_editable.visible) {
				_editable.setDimensions(qWidth, qHeight, qScale);
				if (qAspect>maxAspect) {
					_editable.x = 0;
					_editable.y = (_maxHeight - qHeight)/2;
				}
				else {
					_editable.x = (_maxWidth - qWidth)/2;
					_editable.y = 0;
				}
			}
			
		}
		
	}	
}

