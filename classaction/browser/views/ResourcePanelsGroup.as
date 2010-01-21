
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.ResourceItem;
	
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;
	


	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ResourcePanelsGroup extends Sprite {
		
		public static const PREVIEW_ITEM_CHANGED:String = "previewItemChanged";
		
		protected var _animationsPanel:ResourcePanel;
		protected var _imagesPanel:ResourcePanel;
		protected var _outlinesPanel:ResourcePanel;
		protected var _tablesPanel:ResourcePanel;
		
		protected var _panelsList:Array = [];
			
		protected var _readOnly:Boolean;
		
		public function ResourcePanelsGroup(readOnly:Boolean) {
			_readOnly = readOnly;
						
		}
		
		public function get previewItem():ResourceItem {
			return _previewItem;
		}
		
//		public function get previewX():Number {
//			return _previewX;			
//		}
//		
//		public function get previewY():Number {
//			return _previewY;			
//		}
//		
	
		public function get previewPosition():Point {
			return _previewPosition;			
		}
		
		protected var _previewPosition:Point;
		
//		protected var _previewX:Number, _previewY:Number;
		
		public function setPreviewItem(item:ResourceItem, pos:Point=null):void {
			_previewItem = item;
			_previewPosition = pos;
			dispatchEvent(new Event(ResourcePanelsGroup.PREVIEW_ITEM_CHANGED));
		}
		
		protected var _previewItem:ResourceItem;
		
		public function init() {
			
			if (AnimationsBank.total>0) {
				_animationsPanel = new ResourcePanel(this, ResourcePanel.ANIMATIONS, _readOnly);
				_animationsPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_animationsPanel.setTabOffset(50);
				addChild(_animationsPanel);
			}
			
			if (ImagesBank.total>0) {
				_imagesPanel = new ResourcePanel(this, ResourcePanel.IMAGES, _readOnly);
				_imagesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_imagesPanel.setTabOffset(235);
				addChild(_imagesPanel);
			}
			
			if (OutlinesBank.total>0) {
				_outlinesPanel = new ResourcePanel(this, ResourcePanel.OUTLINES, _readOnly);
				_outlinesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_outlinesPanel.setTabOffset(385);
				addChild(_outlinesPanel);
			}
			
			if (TablesBank.total>0) {
				_tablesPanel = new ResourcePanel(this, ResourcePanel.TABLES, _readOnly);
				_tablesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_tablesPanel.setTabOffset(545);
				addChild(_tablesPanel);
			}			
		}
		
		public function setState(module:Module, question:Question):void {
			//setTitles();
			for (var i:int = 0; i<numChildren; i++) (getChildAt(i) as ResourcePanel).setState(module, question);
		}
		
		public function set modulesList(arg:ModulesList):void {
			for (var i:int = 0; i<numChildren; i++) (getChildAt(i) as ResourcePanel).modulesList = arg;
		}
		
//		public function setTitles() {
//			
//			var tabOffset:Number = 20;
//			var tabSpacing:Number = 7;
//			
//			// <font face='Wingdings'>«</font>
//			
//			if (AnimationsBank.total>0) {
//				_animationsPanel.setTabOffset(50);
//			}
//			
//			if (ImagesBank.total>0) {
//				_imagesPanel.setTabOffset(250);
//			}
//			
//			if (OutlinesBank.total>0) {
//				_outlinesPanel.setTabOffset(400);
//			}
//			
//			if (TablesBank.total>0) {
//				_tablesPanel.setTabOffset(600);
//			}
//			
//		}
		
		protected function onMaximize(evt:Event):void {			
			setChildIndex(evt.target as ResourcePanel, numChildren-1);
			for (var i:int = 0; i<(numChildren-1); i++) (getChildAt(i) as ResourcePanel).minimize();
		}
		
		public function minimizeAll():void {
			for (var i:int = 0; i<numChildren; i++) (getChildAt(i) as ResourcePanel).minimize();
			
		}
		
	}	
}

