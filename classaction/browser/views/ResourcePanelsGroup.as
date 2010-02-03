
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
		
		protected var _panelHeight:Number = 300;
			
		protected var _readOnly:Boolean;
		
		public function ResourcePanelsGroup(readOnly:Boolean) {
			_readOnly = readOnly;						
		}
		
		public function get previewItem():ResourceItem {
			return _previewItem;
		}
		
		public function get previewPosition():Point {
			return _previewPosition;			
		}
		
		protected var _previewPosition:Point;
		
		public function setPreviewItem(item:ResourceItem, pos:Point=null):void {
			_previewItem = item;
			_previewPosition = pos;
			dispatchEvent(new Event(ResourcePanelsGroup.PREVIEW_ITEM_CHANGED));
		}
		
		protected var _previewItem:ResourceItem;
		
		public function init() {
			
			if (AnimationsBank.total>0) {
				_animationsPanel = new ResourcePanel(this, ResourcePanel.ANIMATIONS, _panelHeight, _readOnly);
				_animationsPanel.addEventListener(ResourcePanel.MINIMIZED, onMinimize);
				_animationsPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_animationsPanel.setTabOffset(50);
				addChild(_animationsPanel);
			}
			
			if (ImagesBank.total>0) {
				_imagesPanel = new ResourcePanel(this, ResourcePanel.IMAGES, _panelHeight, _readOnly);
				_imagesPanel.addEventListener(ResourcePanel.MINIMIZED, onMinimize);
				_imagesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_imagesPanel.setTabOffset(235);
				addChild(_imagesPanel);
			}
			
			if (OutlinesBank.total>0) {
				_outlinesPanel = new ResourcePanel(this, ResourcePanel.OUTLINES, _panelHeight, _readOnly);
				_outlinesPanel.addEventListener(ResourcePanel.MINIMIZED, onMinimize);
				_outlinesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_outlinesPanel.setTabOffset(385);
				addChild(_outlinesPanel);
			}
			
			if (TablesBank.total>0) {
				_tablesPanel = new ResourcePanel(this, ResourcePanel.TABLES, _panelHeight, _readOnly);
				_tablesPanel.addEventListener(ResourcePanel.MINIMIZED, onMinimize);
				_tablesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_tablesPanel.setTabOffset(545);
				addChild(_tablesPanel);
			}
			
		}
		
		public function setState(module:Module, question:Question):void {
			for (var i:int = 0; i<numChildren; i++) (getChildAt(i) as ResourcePanel).setState(module, question);
		}
		
		public function set modulesList(arg:ModulesList):void {
			for (var i:int = 0; i<numChildren; i++) (getChildAt(i) as ResourcePanel).modulesList = arg;
		}
		
		protected function onMinimize(evt:Event):void {
			minimizeAll();
		}
		
		protected function onMaximize(evt:Event):void {
			var maximizedPanel:ResourcePanel = (evt.target as ResourcePanel);
			if (maximizedPanel!=null) {
				setChildIndex(maximizedPanel, numChildren-1);
				maximizedPanel.y = -_panelHeight;
				maximizedPanel.inFront = true;
				for (var i:int = 0; i<(numChildren-1); i++) {
					getChildAt(i).y = -_panelHeight;
					(getChildAt(i) as ResourcePanel).inFront = false;
				}
			}			
		}
		
		public function minimizeAll():void {
			for (var i:int = 0; i<numChildren; i++) {
				getChildAt(i).y = 0;
				(getChildAt(i) as ResourcePanel).inFront = false;
			}
			setPreviewItem(null);
		}
		
	}	
}

