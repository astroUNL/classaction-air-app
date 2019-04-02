
// ResourceWindow was created for the ClassAction 2.1 AIR app. In the online/HTML version of
//  of ClassAction 2.0, resources are opened in a new browser window. In the AIR app resources
//  are opened in a new NativeWindow.

// ResourceWindows are created by ResourceWindowsManager, which assigns one window per
//  resource (no duplicates).


package astroUNL.classaction.browser.views {

	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
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

	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	
	public class ResourceWindow extends NativeWindow {
		
		protected var _item:ResourceItem;
		
		// _errorMsg remains null unless loading fails.
		protected var _errorMsg:MessageBubble = null;
		
		// _isLoaded flag raised on loading complete.
		protected var _isLoaded:Boolean = false;
		
		protected var _mask:Shape;
		protected var _loader:Loader;
		
		
		public function ResourceWindow(item:ResourceItem):void {
			trace("ResourceWindow called for item: "+item);
			
			addEventListener(Event.CLOSING, _onWindowClosing);
			
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
			
			stage.stageWidth = _item.width;
			stage.stageHeight = _item.height;
			
			trace(" width: "+width);
			trace(" height: "+height);
			
			title = _item.name;
			
			activate();
						
			_mask = new Shape();
			stage.addChild(_mask);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loader.mask = _mask;
			stage.addChild(_loader);
			
			trace(" loader.width: "+_loader.width);
			trace(" loader.height: "+_loader.height);
			
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = true;
			context.applicationDomain = new ApplicationDomain(null);		
					
			var request:URLRequest = new URLRequest(Downloader.baseURL + _item.downloadURL);
			_loader.load(request, context);			
			
			stage.addEventListener(Event.RESIZE, onStageResized);
		}
		
		
		protected function _onWindowClosing(evt:Event):void {
			if (_isLoaded) {
				_loader.unloadAndStop(true);
			}
		}
		
		
		protected function onStageResized(evt:Event):void {
			refreshPositioning();
		}
		
		
		protected function onLoaderError(evt:IOErrorEvent):void {
			stage.removeChild(_loader);
			_errorMsg = new MessageBubble();
			_errorMsg.setMessage(evt.text);
			stage.addChild(_errorMsg);
			refreshPositioning();
		}
		
		
		protected function onLoaderComplete(evt:Event):void {
			_isLoaded = true;
			refreshPositioning();
		}
		

		protected function refreshPositioning():void {
			
			if (_errorMsg == null && _isLoaded) {
				
				if (_loader.contentLoaderInfo.contentType == "application/x-shockwave-flash") {
					
					trace("contentLoaderInfo for "+_item);
					trace(" actionScriptVersion: "+_loader.contentLoaderInfo.actionScriptVersion);
					trace(" applicationDomain: "+_loader.contentLoaderInfo.applicationDomain);
					trace(" swfVersion: "+_loader.contentLoaderInfo.swfVersion);
					trace(" framerate: "+_loader.contentLoaderInfo.frameRate);
					trace(" width: "+_loader.contentLoaderInfo.width);
					trace(" height: "+_loader.contentLoaderInfo.height);
					trace(" content: "+_loader.content);
				
					trace("loader width: "+_loader.width);
					trace("loader height: "+_loader.height);				
			
					trace("loader.stage.width: "+_loader.stage.width);
				}
			
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
			}
			
			trace("refreshPositioning");
		}
		
	}
	
}

