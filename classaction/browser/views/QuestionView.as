
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	
	public class QuestionView extends Sprite {
		
		protected var _errorMsg:MessageBubble;
		protected var _preloader:Preloader;
		protected var _timer:Timer;
		protected var _mask:Shape;
		protected var _loader:Loader;
		protected var _question:Question;
		
		public function QuestionView() {
			
			_mask = new Shape();
			addChild(_mask);
			
			_errorMsg = new MessageBubble();
			_errorMsg.visible = false;
			_errorMsg.x = 300;
			_errorMsg.y = 300;
			addChild(_errorMsg);
			
			_preloader = new Preloader();
			_preloader.x = 300;
			_preloader.y = 300;
			_preloader.visible = false;
			addChild(_preloader);
			
			_loader = new Loader();
			_loader.visible = false;
			_loader.mask = _mask;
			addChild(_loader);
			
//			if (_loader!=null) {
//				_loader.unloadAndStop(true);
//				removeChild(_loader);
//			}
//			_loader = new Loader();
//			_loader.visible = false;
////			addChildAt(_loader, 0);
			
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function set question(q:Question):void {
			
//			if (q==null) {
//				trace("UNLOADING");
//			}
//			
//			if (_loader!=null) {
//				_loader.unloadAndStop(true);
//				removeChild(_loader);
//			}
//			_loader = new Loader();
//			_loader.visible = false;
//			_loader.mask = _mask;
//			addChildAt(_loader, 0);
			
			
			_question = q;
			refresh();
		}
		
		protected function onTimer(evt:TimerEvent):void {
			refresh();
			evt.updateAfterEvent();
		}
		
		protected function refresh():void {
			if (_question==null) {
				_loader.unloadAndStop(true);
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) _timer.stop();
				return;
			}
			
			if (_question.downloadState==Downloader.DONE_SUCCESS) {
				
				_loader.loadBytes(_question.data);
				
				_mask.graphics.clear();
				_mask.graphics.moveTo(0, 0);
				_mask.graphics.beginFill(0xffffff*Math.random(), 0.3);
				_mask.graphics.drawRect(0, 0, _question.width, _question.height);
				_mask.graphics.endFill();
				
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = true;
				
				if (_timer.running) _timer.stop();				
			}
			else if (_question.downloadState==Downloader.DONE_FAILURE) {
				
				_errorMsg.setMessage("the question file failed to load");
				
				_errorMsg.visible = true;
				_preloader.visible = false;
				_loader.visible = false;
				
				if (_timer.running) _timer.stop();
			}
			else {
				_errorMsg.visible = false;
				_preloader.visible = true;
				_loader.visible = false;
				
				if (!_timer.running) _timer.start();				
			}
		}
		
	}	
}

