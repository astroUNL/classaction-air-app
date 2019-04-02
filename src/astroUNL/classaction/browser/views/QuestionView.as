
// QuestionView was modified to follow ResourceWindow. This was done to avoid using
//  Loader.loadBytes, which would put all question SWFs in the same global space.


package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
	import astroUNL.utils.logger.Logger;

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.ApplicationDomain;

	import flash.display.LoaderInfo;
	import flash.system.LoaderContext;
	
	
	public class QuestionView extends Sprite {
		
		// _question may be null.
		protected var _question:Question;

		// Unlike in ResourceWindow, _errorMsg always exists, but its visibility is toggled.
		protected var _errorMsg:MessageBubble;
		
		protected var _mask:Shape;
		protected var _loader:Loader;
		
		protected var _maxWidth:Number = 780;
		protected var _maxHeight:Number = 515;
		
		
		public function QuestionView() {
			
			_question = null;
			
			_errorMsg = new MessageBubble();
			_errorMsg.visible = false;
			addChild(_errorMsg);
			
			_mask = new Shape();
			_mask.visible = false;
			addChild(_mask);
			
			_loader = new Loader();
			_loader.visible = false;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loader.mask = _mask;
			addChild(_loader);
		}
		
		
		public function get question():Question {
			return _question;
		}
		
		public function set question(q:Question):void {

			_errorMsg.visible = false;
			_mask.visible = false;
			_loader.visible = false;
			
			if (_question != null) {
				try {
					_loader.unloadAndStop(true);
				} catch (e:Error) {
					Logger.report("Failed to unload question SWF.");
				}
			}
			
			_question = q;
			
			if (_question != null) {
				var context:LoaderContext = new LoaderContext();
				context.allowCodeImport = true;
				context.applicationDomain = new ApplicationDomain(null);		
					
				var request:URLRequest = new URLRequest(Downloader.baseURL + _question.downloadURL);
				_loader.load(request, context);
			}
		}
		
		
		public function setMaxDimensions(w:Number, h:Number):void {
			_maxWidth = w;
			_maxHeight = h;
			refreshPositioning();
		}
		
		
		protected function onLoaderError(evt:IOErrorEvent):void {
			_errorMsg.visible = true;
			_errorMsg.setMessage(evt.text);
			refreshPositioning();
		}
		
		
		protected function onLoaderComplete(evt:Event):void {
			_loader.visible = true;
			_mask.visible = true;
			refreshPositioning();
		}		
		
		
		protected function refreshPositioning():void {
			
			if (_loader.visible) {
				
				var maxAspect:Number = _maxWidth/_maxHeight;
				var qAspect:Number = _question.width/_question.height;
				
				var qScale:Number, qWidth:Number, qHeight:Number;
				
				if (qAspect>maxAspect) {
					qScale = _maxWidth/_question.width;
					qWidth = qScale*_question.width;
					qHeight = qScale*_question.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = 0;
					_loader.y = (_maxHeight - qHeight)/2;
				}
				else {
					qScale = _maxHeight/_question.height;
					qWidth = qScale*_question.width;
					qHeight = qScale*_question.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = (_maxWidth - qWidth)/2;
					_loader.y = 0;
				}
				
				_mask.graphics.clear();
				_mask.graphics.moveTo(_loader.x, _loader.y);
				_mask.graphics.beginFill(0xffff00);
				_mask.graphics.drawRect(_loader.x, _loader.y, qWidth, qHeight);
				_mask.graphics.endFill();
				
			} else {
				_mask.graphics.clear();
			}
			
		}
		
		
	}	
}

