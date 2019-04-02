
// ResourceWindow was created for the ClassAction 2.1 AIR app. In the online/HTML version of
//  of ClassAction 2.0, resources are opened in a new browser window. In the AIR app resources
//  are opened in a new NativeWindow.

// Some code adapted from QuestionView.

package astroUNL.classaction.browser.views {

	import astroUNL.classaction.browser.resources.ResourceItem;
	
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	import flash.net.URLRequest;
	
	
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	import flash.system.LoaderContext;
	//import flash.display.Sprite;

	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import flash.system.ApplicationDomain;
	
	
	public class ResourceWindow extends NativeWindow {
		
		protected var _item:ResourceItem;
		
		protected var _errorMsg:MessageBubble;
		protected var _preloader:Preloader;
		protected var _timer:Timer;
		protected var _mask:Shape;
		protected var _loader:Loader;
		
		//protected var _maxWidth:Number = 780;
		//protected var _maxHeight:Number = 515;
		
		public function ResourceWindow(item:ResourceItem):void {
			trace("ResourceWindow called for item: "+item);
			
			_item = item;
			
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
			initOptions.type = NativeWindowType.NORMAL;
			
			super(initOptions);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.color = 0x000000;
			
			var chromeWidth:Number = width - stage.stageWidth;
			var chromeHeight:Number = height - stage.stageHeight;
			
			trace("ResourceWindow");
			trace(" stage.stageWidth: "+stage.stageWidth);
			trace(" stage.stageHeight: "+stage.stageHeight);
			trace(" stage.width: "+stage.width);
			trace(" stage.height: "+stage.height);
			trace(" chromeWidth: "+chromeWidth);
			trace(" chromeHeight: "+chromeHeight);
			trace(" item width: "+_item.width);
			trace(" item.height: "+_item.height);
			
			trace(" width (before): "+width);
			trace(" height (before): "+height);
			
			//width = _item.width + chromeWidth;
			//height = _item.height + chromeHeight;
			
			stage.stageWidth = _item.width;
			stage.stageHeight = _item.height;
			
			trace(" width: "+width);
			trace(" height: "+height);
			
			//stage.stageWidth = width;
			//stage.stageHeight = height;
			
			title = _item.name;
			
			trace("stage: "+stage);
			activate();
			
			_mask = new Shape();
			stage.addChild(_mask);
			
			_errorMsg = new MessageBubble();
			_errorMsg.visible = false;
			//stage.addChild(_errorMsg);
			
			_preloader = new Preloader();
			_preloader.x = 300;
			_preloader.y = 300;
			_preloader.visible = false;
			//stage.addChild(_preloader);
			
			_loader = new Loader();
			_loader.visible = true;//false;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderDone);
			_loader.mask = _mask;
			stage.addChild(_loader);
			
			trace(" loader.width: "+_loader.width);
			trace(" loader.height: "+_loader.height);
						
			//_loader.stage.width = _item.width;
			//_loader.stage.height = _item.height;
			
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			refresh();

			/*
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;
			context.applicationDomain = new ApplicationDomain(null);		
					
			var request:URLRequest = new URLRequest(_item.downloadURL);
			_loader.load(request, context);
			_loader.visible = true;
			_preloader.visible = false;
			
			*/
			stage.addEventListener(Event.RESIZE, onStageResized);
		}
		
		protected function onStageResized(evt:Event):void {
			trace("ON STAGE RESIZE");
			refreshPositioning();
			
			trace("contentLoaderInfo for "+_item);
			trace(" actionScriptVersion: "+_loader.contentLoaderInfo.actionScriptVersion);
			trace(" applicationDomain: "+_loader.contentLoaderInfo.applicationDomain);
			trace(" swfVersion: "+_loader.contentLoaderInfo.swfVersion);
			trace(" framerate: "+_loader.contentLoaderInfo.frameRate);
			trace(" width: "+_loader.contentLoaderInfo.width);
			trace(" height: "+_loader.contentLoaderInfo.height);
			trace(" content: "+_loader.content);
		}
		
		protected function refresh():void {
			if (_item == null) {
				_loader.unloadAndStop(true);
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) {
					_timer.stop();
				}
				return;
			}

			if (_item.downloadState == Downloader.DONE_SUCCESS) {
				if (_item.data.length>0) {
					
					var context:LoaderContext = new LoaderContext();
					context.allowCodeImport = true;
					context.applicationDomain = new ApplicationDomain(null);
					//context.securityDomain = SecurityDomain.currentDomain;
					
					_loader.loadBytes(_item.data, context);
					_errorMsg.visible = false;
					_preloader.visible = false;
					_loader.visible = false;
				}
				// TODO : Check QuestionView -- there may be a bug in logic.
				if (_timer.running) {
					_timer.stop();
				}
			} else if (_item.downloadState == Downloader.DONE_FAILURE) {
				_errorMsg.setMessage("The resource file failed to load.");
				_errorMsg.visible = true;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) {
					_timer.stop();
				}
			} else {
				if (_item.downloadState == Downloader.NOT_QUEUED) {
					Downloader.get(_item);
				}
				_errorMsg.visible = false;
				_preloader.visible = true;
				_loader.visible = false;
				if (!_timer.running) {
					_timer.start();
				}
			}
			
			refreshPositioning();
		}
		
		protected function onTimer(evt:TimerEvent):void {
			trace("onTimer");
			refresh();
			evt.updateAfterEvent();
		}
		
		protected function onLoaderDone(evt:Event):void {
			trace("onLoaderDone");
			_loader.visible = true;
			refreshPositioning();
		}
		
		
		protected function refreshPositioning():void {
			
			var midX:Number = stage.stageWidth/2;
			var midY:Number = stage.stageHeight/2;
			
			_errorMsg.x = midX - _errorMsg.width/2;
			_errorMsg.y = midY - _errorMsg.height/2;
			
			_preloader.x = midX - _preloader.width/2;
			_preloader.y = midY - _preloader.height/2;
			
			if (_loader.visible) {
				
			trace("loader width: "+_loader.width);
			trace("loader height: "+_loader.height);				
			
				trace("loader.stage.width: "+_loader.stage.width);
			
				var maxAspect:Number = stage.stageWidth/stage.stageHeight;
				var qAspect:Number = _item.width/_item.height;
				
				var qScale:Number, qWidth:Number, qHeight:Number;
				
				if (qAspect>maxAspect) {
					qScale = stage.stageWidth/_item.width;
					qWidth = qScale*_item.width;
					qHeight = qScale*_item.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = 0;
					_loader.y = (stage.stageHeight - qHeight)/2;
				} else {
					qScale = stage.stageHeight/_item.height;
					qWidth = qScale*_item.width;
					qHeight = qScale*_item.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = (stage.stageWidth - qWidth)/2;
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
			
			trace("refreshPositioning");
		}
		
	}
	
}

