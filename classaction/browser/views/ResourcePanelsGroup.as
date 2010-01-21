
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;
	
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;


	import flash.display.Sprite;
	import flash.events.Event;
	
	public class ResourcePanelsGroup extends Sprite {
		
		
		protected var _animationsPanel:ResourcePanel;
		protected var _imagesPanel:ResourcePanel;
		protected var _outlinesPanel:ResourcePanel;
		protected var _tablesPanel:ResourcePanel;
		
		protected var _panelsList:Array = [];
			
		protected var _readOnly:Boolean;
		
		public function ResourcePanelsGroup(readOnly:Boolean) {
			_readOnly = readOnly;
						
		}
		
		public function init() {
			
			if (AnimationsBank.total>0) {
				_animationsPanel = new ResourcePanel(ResourcePanel.ANIMATIONS, _readOnly);
				_animationsPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_animationsPanel.setTabOffset(50);
				addChild(_animationsPanel);
			}
			
			if (ImagesBank.total>0) {
				_imagesPanel = new ResourcePanel(ResourcePanel.IMAGES, _readOnly);
				_imagesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_imagesPanel.setTabOffset(235);
				addChild(_imagesPanel);
			}
			
			if (OutlinesBank.total>0) {
				_outlinesPanel = new ResourcePanel(ResourcePanel.OUTLINES, _readOnly);
				_outlinesPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
				_outlinesPanel.setTabOffset(385);
				addChild(_outlinesPanel);
			}
			
			if (TablesBank.total>0) {
				_tablesPanel = new ResourcePanel(ResourcePanel.TABLES, _readOnly);
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

