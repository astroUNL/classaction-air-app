
package astroUNL.classaction.browser.views {

	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.resources.BinaryFile;
	
	import astroUNL.utils.easing.CubicEaser;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	
	public class ResourcePreview extends Sprite {
		
		protected var _alphaTimer:Timer;
		
		public const fadeInTime:Number = 500;
		public const fadeOutTime:Number = 500;
		
		protected var _alphaEaser:CubicEaser;
		
		protected var _item:ResourceItem;
		
		protected var _downloadPriority:int = 500000;
		
		protected var _thumbLoader:Loader;
		
		protected var _thumb:Bitmap;
		
		protected var _bubble:Sprite;
		
		public function ResourcePreview() {
			alpha = 0;
			visible = false;
			
			_bubble = new Sprite();
			addChild(_bubble);
			
			_thumb = new Bitmap();
			_bubble.addChild(_thumb);
			
			_thumbLoader = new Loader();
			_thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbLoaded);
			
			mouseEnabled = false;
			mouseChildren = false;
			
			_alphaEaser = new CubicEaser(0);
			
			_alphaTimer = new Timer(20);
			_alphaTimer.addEventListener(TimerEvent.TIMER, onAlphaTimer);
		}
		
		protected var _maxWidth:Number = 180;
		protected var _maxHeight:Number = 140;
		
		protected function onThumbLoaded(evt:Event):void {
			//_thumbLoader.scaleX = _thumbLoader.scaleY = 1;
			trace("thumb loaded, "+_thumbLoader.width+"x"+_thumbLoader.height);
			var scale:Number = Math.min(_maxWidth/_thumbLoader.width, _maxHeight/_thumbLoader.height);
			if (scale>1) scale = 1;
			
			var w:int = scale*_thumbLoader.width;
			var h:int = scale*_thumbLoader.height;
			
			var src:BitmapData = new BitmapData(_thumbLoader.width, _thumbLoader.height, true, 0x0);
			src.draw(_thumbLoader);
			
			var bmd:BitmapData = new BitmapData(w, h);
			bmd.draw(src, new Matrix(scale, 0, 0, scale, 0, 0), null, null, null, true);
			
			_thumb.bitmapData = bmd;
			
		}		
		
		protected var _position:Point;
		
		public function show(item:ResourceItem, pos:Point):void {
			
			_position = pos;
			
//			_x = x;
//			_y = y;
			
			_item = item;
			
			if (item.thumb==null) {
				
				var filename:String;
				
				if (item.type==ResourceItem.ANIMATION) filename = item.filename.slice(0, item.filename.lastIndexOf(".")) + ".jpg";
				else if (item.type==ResourceItem.IMAGE) filename = item.filename.slice(0, item.filename.lastIndexOf(".")) + "_thumbLoader" + item.filename.slice(item.filename.lastIndexOf("."));
				else if (item.type==ResourceItem.OUTLINE) filename = item.filename;
				else if (item.type==ResourceItem.TABLE) filename = item.filename;
				else {
					Logger.report("invalid resource type in ResourcePreview");
					hide(true);
					return;
				}
				
				item.thumb = new BinaryFile(filename);
				item.thumb.downloadPriority = _downloadPriority++;
			}
			
			_alphaTimer.start();
			onAlphaTimer();
		}
		
		public function hide(noWait:Boolean=false):void {
			noWait = true;
			if (noWait) {
				alpha = 0;
				visible = false;
				_alphaEaser.init(0);
				_alphaTimer.stop();
			}
			else if (alpha>0) {
				
				
				_alphaEaser.setTarget(getTimer(), null, getTimer()+fadeOutTime, 0);
				_alphaTimer.start();				
			}
		}
		
		protected function onAlphaTimer(evt:TimerEvent=null):void {
			
			if (_item.thumb.downloadState==Downloader.DONE_FAILURE) {
				Logger.report("failed to get thumb for "+_item.name);
				hide(true);
			}
			else if (_item.thumb.downloadState==Downloader.DONE_SUCCESS) {
				trace("SUCCESS in getting thumb for "+_item.name);
				trace(" bytes: "+_item.thumb.byteArray.length);
				_thumbLoader.loadBytes(_item.thumb.byteArray);
				alpha = 1;
				visible = true;
				_alphaTimer.stop();
				
				var pos:Point = globalToLocal(_position);
				trace("pos: "+pos.x+", "+pos.y);
				_bubble.x = pos.x;
				_bubble.y = pos.y;
				
				//hide(true);
			}
			else trace("waiting for the thumb to load");
		}
		
	}
}

