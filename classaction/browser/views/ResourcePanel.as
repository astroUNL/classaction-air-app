
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.views.elements.ResourcePanelNavButton;
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	import astroUNL.classaction.browser.download.Downloader;

	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.system.Security;
	import flash.geom.Point;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
//	import flash.events.ContextMenuEvent;
//	import flash.ui.ContextMenu;
//	import flash.ui.ContextMenuItem;
	
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.external.ExternalInterface;
	
	
	public class ResourcePanel extends Sprite {
		
		public static const MINIMIZED:String = "minimized";
		public static const MAXIMIZED:String = "maximized";
		
		public static const ANIMATIONS:String = "animations";
		public static const IMAGES:String = "images";
		public static const OUTLINES:String = "outlines";
		public static const TABLES:String = "tables";
		
		
		protected var _type:String;
		protected var _titleFormat:TextFormat;
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		protected var _background:Sprite;
		protected var _title:ClickableText;
		protected var _panes:ScrollableLayoutPanes;
		protected var _leftButton:ResourcePanelNavButton;
		protected var _rightButton:ResourcePanelNavButton;
		protected var _content:Sprite;
		protected var _relevantStar:RelevantStar;
		protected var _relevantHeading:TextField;		
		protected var _moreHeading:TextField;
		protected var _titleStar:RelevantStar;
		
		protected var _closeButton:ResourcePanelCloseButton;
		
		
		
		protected var _panelWidth:Number = 800;
		protected var _panelHeight:Number = 300;
		protected var _navButtonSpacing:Number = 20;
		protected var _panesTopMargin:Number = 45;
		protected var _panesBottomMargin:Number = 5;
		protected var _panesWidth:Number = _panelWidth - 4*_navButtonSpacing;
		protected var _panesHeight:Number = _panelHeight - _panesTopMargin - _panesBottomMargin;
		protected var _columnSpacing:Number = 10;
		protected var _numColumns:int = 3;
		protected var _easeTime:Number = 250;
		protected var _modulesList:ModulesList;
		protected var _preparedTextItems:Object = {};
		
		protected var _selectedModule:Module;
		protected var _selectedQuestion:Question;
		protected var _tabOffset:Number;
		protected var _tabWidth:Number;
		protected var _maximized:Boolean;
		protected var _showAll:Boolean = false;
		
		protected var _titleMargin:Number = 3;
		protected var _backgroundColor:uint = 0xfafafa;
		protected var _borderColor:uint = 0xa0a0a0;
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 4;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 4;
		protected var _itemBottomMargin:Number = 2;
		protected var _itemMinLeftOver:Number = -2;
		
		protected var _closeButtonY:Number = 18;
		protected var _closeButtonX:Number = _panelWidth - _closeButtonY;
		
		protected var _horizontalDividerColor:uint = 0xe0e0e0;
		protected var _horizontalDividerX:Number = 8;
		protected var _horizontalDividerY:Number = 34;
		
		protected var _readOnly:Boolean;
		
		protected var _group:ResourcePanelsGroup;
				
		public function ResourcePanel(group:ResourcePanelsGroup, type:String, readOnly:Boolean) {
			
			_group = group;
			_type = type;
			_readOnly = readOnly;
			
			_titleFormat = new TextFormat("Verdana", 14, 0x404040, true);
			_headingFormat = new TextFormat("Verdana", 13, 0x0, true);
			_itemFormat = new TextFormat("Verdana", 13, 0x404040);		
			
			_background = new Sprite();
			addChild(_background);
			
			_title = new ClickableText("", null, _titleFormat);
			_title.addEventListener(ClickableText.ON_CLICK, onTitleClicked);
			addChild(_title);
			
			_titleStar = new RelevantStar();
			_titleStar.visible = false;
			addChild(_titleStar);
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = 2*_navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_leftButton = new ResourcePanelNavButton();
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _panelHeight/2;
			_leftButton.scaleX = -1;
			_leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClicked);
			_leftButton.visible = false;
			addChild(_leftButton);
			
			_rightButton = new ResourcePanelNavButton();
			_rightButton.x = _panelWidth - _navButtonSpacing;
			_rightButton.y = _panelHeight/2;
			_rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClicked);
			_rightButton.visible = false;
			addChild(_rightButton);
			
			_content = new Sprite();
			addChild(_content);
			
			_relevantStar = new RelevantStar();
			
			_closeButton = new ResourcePanelCloseButton();
			_closeButton.x = _closeButtonX;
			_closeButton.y = _closeButtonY;
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseButtonClicked);
			_closeButton.useHandCursor = true;
			_closeButton.buttonMode = true;
			addChild(_closeButton);
			
			_typeCapped = getFirstCapped(type);
			_relevantHeading = createHeading("Relevant "+_typeCapped);
			_moreHeading = createHeading("More "+_typeCapped+"...");
		}
		
		protected var _typeCapped:String;
		
		protected function onTitleClicked(evt:Event):void {
			if (_maximized) minimize();
			else maximize();
		}
		
		protected function onCloseButtonClicked(evt:MouseEvent):void {
			minimize();
		}

	
		import flash.utils.getTimer;
		
		protected function onItemMouseOver(evt:MouseEvent):void {
			var item:ResourceItem = evt.target.data.item;
			_group.setPreviewItem(item, evt.target.localToGlobal(new Point(0, 0)));
		}
		
		protected function onItemMouseOut(evt:MouseEvent):void {
			var item:ResourceItem = evt.target.data.item;
			// cancel the preview only if the mouseOut event corresponds to the currently previewed object
			if (item==_group.previewItem) _group.setPreviewItem(null);
		}
		
		protected function onItemClicked(evt:Event):void {
			
			var item:ResourceItem = evt.target.data.item;			
			
			var filename:String = Downloader.baseURL + item.filename;
			filename = filename.slice(0, filename.lastIndexOf(".")) + ".html";
			
			if (Security.sandboxType==Security.REMOTE) {
				ExternalInterface.call("openNewWindow", filename, item.id, "toolbar=no,directories=no,menubar=no,resizable=yes,dependent=no,status=no,width=" + item.width.toString() + ",height=" + item.height.toString());				
			}
			else {
				navigateToURL(new URLRequest(filename), "_blank");
			}
		}
		
		protected function onLeftButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(-1, _easeTime);
		}
		
		protected function onRightButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(1, _easeTime);
		}
		
		protected function onModulesListUpdate(evt:Event):void {
			redraw();
		}
		
		protected function onModuleUpdate(evt:Event):void {
			redraw();
		}
		
		public function set modulesList(arg:ModulesList):void {
			_modulesList = arg;
			_modulesList.addEventListener(ModulesList.UPDATE, onModulesListUpdate);
			_preparedTextItems = {};		
			redraw();
		}
		
		public function setState(module:Module, question:Question):void {
			_selectedModule = module;
			_selectedQuestion = question;
			_showAll = (_selectedModule==null);
			redraw();
		}
		
		public function setTabOffset(tabOffset:Number):void {
			//trace("setting tabOffset: "+tabOffset+", "+_type);
			_tabOffset = tabOffset;
			redrawTitle();
			redrawBackground();
		}
		
		protected function redrawTitle():void {
			_title.setText(_titleText);
			_title.x = _tabOffset + _titleMargin;
			_title.y = -_title.height;
			if (_numRelevant>0) {
				_titleStar.visible = true;
				_titleStar.x = _tabOffset + _titleMargin + 9;//_title.x + _title.width + 17;
				_titleStar.y = _title.y + _title.height/2;
				_title.x += 18;
				_tabWidth = _title.width + 2*_titleMargin + 20;
			}
			else {
				_titleStar.visible = false;
				_tabWidth = _title.width + 2*_titleMargin;
			}
			//trace("tabOffset: "+_tabOffset+", "+_type);
		}
		
		protected var _titleText:String = "";
		

//		protected function setTitle(title:String, tabOffset:Number):void {
//			_title.x = tabOffset + _titleMargin;
//			_title.y = -_title.height;			
//			_tabWidth = _title.width + 2*_titleMargin;
//			_tabOffset = tabOffset;			
//			redrawBackground();
//		}
		
		public function minimize():void {
			_maximized = false;
			y = 0;			
			dispatchEvent(new Event(ResourcePanel.MINIMIZED));
		}
		
		public function maximize():void {
			if (!_maximized) _panes.paneNum = 0;
			_maximized = true;
			y = -_panelHeight;
			dispatchEvent(new Event(ResourcePanel.MAXIMIZED));
		}
		
		protected function prepareTextItems():void {
			// preparedTextItems consists of objects identified by "_"+module.id;
			// each of these objects contains a heading TextField and a links object;
			// the links object consists of ClickableText links identified by the resource id
			
			var i:int, j:int;
			
			var module:Module;
			var list:Array;
			
			var prepObj:Object;
			
			for (i=0; i<_modulesList.modules.length; i++) {
				module = _modulesList.modules[i];
				prepObj = _preparedTextItems["_"+module.id];
				if (prepObj==null) {
					prepObj = {};
					prepObj.links = {};
					_preparedTextItems["_"+module.id] = prepObj;
					module.addEventListener(Module.UPDATE, onModuleUpdate);
				}
				else if (module.readOnly) {
					continue;
				}
				
				// if the previous heading is undefined or changed, get a new one
				if (prepObj.heading==null || prepObj.heading.text!=module.name) {
					prepObj.heading = createHeading(module.name);
					prepObj.contHeading = createHeading(module.name + " Cont'd");
				}
				
				list = getResourceList(module);
				
				// for each resource in a module create a ClickableText object if it does not already exist
				for (j=0; j<list.length; j++) {
					if (prepObj.links[list[j].id]==undefined) {
						prepObj.links[list[j].id] = new ClickableText(list[j].name, {item: list[j]}, _itemFormat, _panes.columnWidth);
//						prepObj.links[list[j].id].contextMenu = new ContextMenu();
//						prepObj.links[list[j].id].contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onItemMenuSelect);
						ResourceContextMenuController.register(prepObj.links[list[j].id]);
						prepObj.links[list[j].id].addEventListener(MouseEvent.MOUSE_OVER, onItemMouseOver);
						prepObj.links[list[j].id].addEventListener(MouseEvent.MOUSE_OUT, onItemMouseOut);
						prepObj.links[list[j].id].addEventListener(ClickableText.ON_CLICK, onItemClicked);
					}
				}
			}
		}
		
//		protected function onItemMenuSelect(evt:ContextMenuEvent):void {
//			
//			var menu:ContextMenu = (evt.contextMenuOwner as ClickableText).contextMenu;
//			menu.hideBuiltInItems();
//			menu.customItems = [];
//			
//			// the list of modules the item is included in
//			var masterInList:Array = (evt.contextMenuOwner as ClickableText).data.modulesList;
//			
//			// when done these lists will be populated with the custom modules the
//			// item is included and not included in
//			var inList:Array = [];
//			var outList:Array = [];
//			
//			// populate the in and out lists
//			var i:int, j:int;
//			for (i=0; i<_modulesList.modules.length; i++) {
//				if (!_modulesList.modules[i].readOnly) {
//					for (j=0; j<masterInList.length; j++) {
//						if (_modulesList.modules[i]==masterInList[j]) {
//							inList.push(_modulesList.modules[i]);
//							break;
//						}						
//					}
//					if (j>=masterInList.length) outList.push(_modulesList.modules[i]);
//				}
//			}
//			
//			_moduleLookup = new Dictionary();			
//			var item:ContextMenuItem;
//			
//			// modules the resource could be added to
//			if (outList.length>0) {
//				item = new ContextMenuItem(_addToMenuText, inList.length>0);
//				menu.customItems.push(item);
//				for (i=0; i<outList.length; i++) {
//					item = new ContextMenuItem(_moduleMenuTextPrefix+outList[i].name);
//					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemAddToModule);
//					menu.customItems.push(item);
//					_moduleLookup[item] = outList[i];
//				}
//			}
//			
//			// modules the resource could be removed from
//			if (inList.length>0) {
//				item = new ContextMenuItem(_removeFromMenuText);
//				menu.customItems.push(item);			
//				for (i=0; i<inList.length; i++) {
//					item = new ContextMenuItem(_moduleMenuTextPrefix+inList[i].name);
//					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemRemoveFromModule);
//					menu.customItems.push(item);
//					_moduleLookup[item] = inList[i];
//				}			
//			}
//		}
//		
//		// moduleLookup is used to lookup the module associated with a given context menu item
//		protected var _moduleLookup:Dictionary;
//		
//		protected function onItemAddToModule(evt:ContextMenuEvent):void {
//			_moduleLookup[evt.target].addResource((evt.contextMenuOwner as ClickableText).data);
//		}
//		
//		protected function onItemRemoveFromModule(evt:ContextMenuEvent):void {
//			_moduleLookup[evt.target].removeResource((evt.contextMenuOwner as ClickableText).data);
//		}
//		
//		protected var _addToMenuText:String = "Add to…";
//		protected var _removeFromMenuText:String = "Remove from…";
//		protected var _moduleMenuTextPrefix:String = "…";
		
		protected var _numRelevant:int = 0;
		
		protected function redraw():void {
			//var startTimer:Number = getTimer();
			
			if (_selectedModule==null) _showAll = true;
			
			prepareTextItems();
			
			var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			var i:int, j:int;
			var module:Module;
			var list:Array;
			var link:ClickableText;
			var preparedModuleItems:Object;
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};
			
			var total:int = 0;
			
			_numRelevant = 0;
			
			
			if (_showAll) {
				var addedOk:Boolean;
				for (i=0; i<_modulesList.modules.length; i++) {
					module = _modulesList.modules[i];
					list = getResourceList(module);
					preparedModuleItems = _preparedTextItems["_"+module.id];
					if (list.length>0) {
						_panes.addContent(preparedModuleItems.heading, headingParams);
						for (j=0; j<list.length; j++) {
							addedOk = _panes.addContent(preparedModuleItems.links[list[j].id], itemParams, false);
							if (!addedOk) {
								if (_panes.getColumnNum()==_numColumns) {
									_panes.advanceColumn();
									_panes.addContent(preparedModuleItems.contHeading, headingParams);								
								}
								_panes.addContent(preparedModuleItems.links[list[j].id], itemParams);
							}
							total++;
						}
					}
				}
			}
			else {
				preparedModuleItems = _preparedTextItems["_"+_selectedModule.id];
				list = getResourceList(_selectedModule);
				if (list.length>0) {
					var relevantLinks:Array = getRelevantLinks();
					_numRelevant = relevantLinks.length;
					if (_numRelevant>0) {
						// there are relevant resources that need to be highlighted (brought to front)
						
						// mark each link in the list as not visible
						// this is used as a flag to identify which links have already been added
						for (j=0; j<list.length; j++) preparedModuleItems.links[list[j].id].visible = false;
												
						// add the relevant resources
						_panes.addContent(_relevantHeading, headingParams);
						_panes.getCurrentPane().addChild(_relevantStar);
						_relevantStar.x = _relevantHeading.x + _relevantHeading.textWidth + 17;
						_relevantStar.y = _relevantHeading.y + _relevantHeading.height/2;
 						for (i=0; i<_numRelevant; i++) {
							link = relevantLinks[i];
							link.visible = true;
							_panes.addContent(link, itemParams);
							total++;
						}
						
						_panes.addPadding(5);
						
						// add the rest of the resources
						var needToAddHeading:Boolean = true;
						for (j=0; j<list.length; j++) {
							link = preparedModuleItems.links[list[j].id];
							if (link.visible) continue;
							if (needToAddHeading) {
								_panes.addContent(_moreHeading, headingParams);
								needToAddHeading = false;
							}
							link.visible = true;
							_panes.addContent(link, itemParams);
							total++;
						}
					}
					else {
						for (j=0; j<list.length; j++) {
							_panes.addContent(preparedModuleItems.links[list[j].id], itemParams);
							total++;
						}
					}
				}
			}
			
			_titleText = _typeCapped + " (" + total.toString() + ")";
			
			redrawTitle();
			redrawBackground();
			
			_leftButton.visible = _rightButton.visible = (_panes.numPanes>1);
			
			_panes.paneNum = oldPaneNum;
			
			//trace("redraw ResourcePanel: "+(getTimer()-startTimer)+", "+_type);
		}
				
		protected function redrawBackground():void {
			var g:Graphics = _background.graphics;
			g.clear();
			g.moveTo(0, 0);
			g.lineStyle(0, _borderColor);
			g.beginFill(_backgroundColor);
			g.lineTo(_tabOffset, 0);
			g.lineTo(_tabOffset, _title.y);
			g.lineTo(_tabOffset+_tabWidth, _title.y);
			g.lineTo(_tabOffset+_tabWidth, 0);
			g.lineTo(_panelWidth, 0);
			g.lineStyle();
			g.lineTo(_panelWidth, _panelHeight);
			g.lineTo(0, _panelHeight);
			g.lineTo(0, 0);
			g.endFill();
			
			g.lineStyle(0, _horizontalDividerColor);
			g.moveTo(_horizontalDividerX, _horizontalDividerY);
			g.lineTo(_panelWidth-_horizontalDividerX, _horizontalDividerY);
		}
		
		public function get panelHeight():Number {
			return _panelHeight;
		}
		
		public function get tabWidth():Number {
			return _tabWidth;
		}
		
		protected function createHeading(text:String):TextField {
			var t:TextField = new TextField();
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _panes.columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_headingFormat);
			t.embedFonts = true;
			return t;
		}		
				
		protected function getResourceList(module:Module):Array {
			if (_type==ResourcePanel.ANIMATIONS) return module.animationsList;
			else if (_type==ResourcePanel.IMAGES) return module.imagesList;
			else if (_type==ResourcePanel.OUTLINES) return module.outlinesList;
			else if (_type==ResourcePanel.TABLES) return module.tablesList;
			else return [];
		}
		
		protected function getRelevantLinks():Array {
			var list:Array = [];
			
			if (_selectedModule==null || _selectedQuestion==null) return list;

			var idsList:Array;
			if (_type==ResourcePanel.ANIMATIONS) idsList = _selectedQuestion.relevantAnimationIDsList;
			else if (_type==ResourcePanel.IMAGES) idsList = _selectedQuestion.relevantImageIDsList;
			else if (_type==ResourcePanel.OUTLINES) idsList = _selectedQuestion.relevantOutlineIDsList;
			else if (_type==ResourcePanel.TABLES) idsList = _selectedQuestion.relevantTableIDsList;
			
			var link:ClickableText;
			var i:int;			
			for (i=0; i<idsList.length; i++) {
				link = _preparedTextItems["_"+_selectedModule.id].links[idsList[i]];
				if (link!=null) list.push(link);
				else trace("Warning, relevant resource not found in containing module, module: "+_selectedModule.name+", question: "+_selectedQuestion.id+", resource id: "+idsList[i]+", resource type: "+_type);
			}
			
			return list;
		}
		
		protected function getFirstCapped(str:String):String {
			return str.charAt(0).toUpperCase() + str.slice(1);
		}
		
	}	
}

