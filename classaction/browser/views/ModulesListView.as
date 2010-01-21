
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
//	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;
//	import astroUNL.classaction.browser.resources.BinaryFile;
//	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.events.MenuEvent;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.views.elements.ResourcePanelNavButton;
	import astroUNL.classaction.browser.views.elements.EditableClickableText;
	
	import astroUNL.utils.keylistener.KeyListener;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.text.TextFormat;
	import flash.text.TextField;
//	import flash.net.FileReference;
//	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
//	import flash.utils.Timer;
//	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
//	import nochump.util.zip.ZipOutput;
//	import nochump.util.zip.ZipEntry;
	
	public class ModulesListView extends Sprite {
		
		public static const MODULE_SELECTED:String = "moduleSelected";
		public static const START_ZIP_DOWNLOAD:String = "startZipDownload";

		protected var _createCommand:ClickableText;
		protected var _downloadCommand:ClickableText;
		
		protected var _content:Sprite;
		
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		protected var _actionFormat:TextFormat;
		protected var _editingFormat:TextFormat;
		
		protected var _panelWidth:Number = 800;
		protected var _panelHeight:Number = 550;
		protected var _navButtonSpacing:Number = 20;
		protected var _panesTopMargin:Number = 45;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number = _panelWidth - 2*_navButtonSpacing;
		protected var _panesHeight:Number = _panelHeight - _panesTopMargin - _panesBottomMargin;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 3;
		protected var _easeTime:Number = 250;
		
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 4;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _leftButton:ResourcePanelNavButton;
		protected var _rightButton:ResourcePanelNavButton;
		
		protected var _standardHeading:TextField;
		protected var _customHeading:TextField;
		
		protected var _readOnly:Boolean;
//		protected var _browserSwf:BinaryFile;
//		protected var _startHtml:BinaryFile;
		
		public function ModulesListView(readOnly:Boolean) {
			
			_moduleLinks = new Dictionary();
			
			_readOnly = readOnly;
			
//			_fr = new FileReference();
//			_browserSwf = new BinaryFile("~browser.swf");			
//			_startHtml = new BinaryFile("~start.html");
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_headingFormat = new TextFormat("Verdana", 15, 0xffffff, true);
			_itemFormat = new TextFormat("Verdana", 14, 0xffffff);
			_actionFormat = new TextFormat("Verdana", 12, 0xffffff, false, true);
			_editingFormat = new TextFormat("Verdana", 14, 0x000000);
			
			if (_readOnly) {
				_standardHeading = createHeading("My Modules");
				_customHeading = createHeading("Custom Modules");
			}
			else {
				_standardHeading = createHeading("ClassAction Modules");
				_customHeading = createHeading("My Modules");
			}
			
			_createCommand = new ClickableText("create new module", null, _actionFormat, _panes.columnWidth);
			_createCommand.addEventListener(ClickableText.ON_CLICK, onCreateCustomModule, false, 0, true);
			_downloadCommand = new ClickableText("download my modules", null, _actionFormat, _panes.columnWidth);
			_downloadCommand.addEventListener(ClickableText.ON_CLICK, onDownloadCustomModules, false, 0, true);
			
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
			
//			_downloadPoller = new Timer(20);
//			_downloadPoller.addEventListener(TimerEvent.TIMER, onDownloadPoll);
			
		}
		
		
		protected var _panes:ScrollableLayoutPanes;
		
		protected var _customNum:int = 1;
		
		protected function onCreateCustomModule(evt:Event):void {
			var newModule:Module = new Module(null, false);
			newModule.name = "New Module " + (_customNum++).toString();
			_modulesList.addModule(newModule);
			_moduleLinks[newModule].setEditable(true);
		}
		
		protected function onModuleDeleteRequest(evt:ContextMenuEvent):void {
			var module:Module = (evt.contextMenuOwner as EditableClickableText).data;
			var success:Boolean = _modulesList.removeModule(module);
			if (success) delete _moduleLinks[module];			
		}
		
		protected function onModuleNameEntered(evt:Event):void {
			evt.target.data.name = evt.target.text;
		}
		
		protected function onDownloadCustomModules(evt:Event):void {
			dispatchEvent(new Event(ModulesListView.START_ZIP_DOWNLOAD));
		}
		
//		protected var _downloadPoller:Timer;
//		
//		protected function onDownloadCustomModules(evt:Event):void {
//			
//			trace("skipping onDownloadCustomModules");
//			return;
//
////			if (_downloadPoller.running) {
////							_panes.addContent(createHeading("-1"));
////
////				trace("download already in progress");
////				return;
////			}
////			var i:int;
//
////			for (i=0; i<_modulesList.modules.length; i++) {
////				if (!_modulesList.modules[i].readOnly) {
////					Downloader.get(_modulesList.modules[i].allQuestionsList);
////				}
////			}
//			
////			_downloadPoller.start();
////		}
////		
////		protected function onDownloadPoll(evt:TimerEvent):void {
//			
//			var i:int, j:int;
//
//			
//			for (i=0; i<_modulesList.modules.length; i++) {
//				if (!_modulesList.modules[i].readOnly) {
//					for (j=0; j<_modulesList.modules[i].allQuestionsList.length; j++) {
//						if (_modulesList.modules[i].allQuestionsList[j].downloadState!=Downloader.DONE_SUCCESS) return;						
//					}
//				}
//			}
//			
//			if (_startHtml.downloadState!=Downloader.DONE_SUCCESS) return;
//			if (_browserSwf.downloadState!=Downloader.DONE_SUCCESS) return;
//			
////			// ok, all the resources in the custom modules have been loaded
////			_downloadPoller.stop();
//			
//			
//			var zip:ZipOutput = new ZipOutput();
//			
//			var entry:ZipEntry;
//			var ba:ByteArray = new ByteArray();
//			var done:Object = {};
//			var question:Question;
//			
//			var filename:String;
//			
//			var baseURL:String = "custom/classaction/";
//			
//			var modulesXML:XML = new XML("<modules></modules>");
//			var questionsXML:XML = new XML("<QuestionBank></QuestionBank>");
//			
//			
//			for (i=0; i<_modulesList.modules.length; i++) {
//				if (!_modulesList.modules[i].readOnly) {
//					for (j=0; j<_modulesList.modules[i].allQuestionsList.length; j++) {
//						question = _modulesList.modules[i].allQuestionsList[j];
//						if (done[question.id]==undefined) {
//							
//							// add the question to the zip file
//							entry = new ZipEntry(baseURL+question.downloadURL);
//							zip.putNextEntry(entry);
//							zip.write(question.swfData);
//							zip.closeEntry();
//							done[question.id] = true;
//							
//							// add the question data to the xml file
//							questionsXML.appendChild(question.getXML());
//						}						
//					}
//					
//					// write the xml file for this custom module
//					filename = _modulesList.modules[i].name + ".xml";
//					trace(filename);
//					ba.length = 0;
//					ba.writeMultiByte(_modulesList.modules[i].getXMLString(), "iso-8859-1");
//					entry = new ZipEntry(baseURL+filename);
//					zip.putNextEntry(entry);
//					zip.write(ba);
//					zip.closeEntry();
//					
//					// add this custom module to the modules list xml file
//					modulesXML.appendChild(new XML("<module>"+filename+"</module>"));
//				}				
//			}
//			
//			
//			// write the questions.xml file
//			ba.length = 0;
//			ba.writeMultiByte("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" + (new XML(questionsXML)).toXMLString(), "iso-8859-1");
//			entry = new ZipEntry(baseURL+"questions/questions.xml");
//			zip.putNextEntry(entry);
//			zip.write(ba);
//			zip.closeEntry();
//			
//			// write the moduleslist.xml file
//			ba.length = 0;
//			ba.writeMultiByte("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" + (new XML(modulesXML)).toXMLString(), "iso-8859-1");
//			entry = new ZipEntry(baseURL+"moduleslist.xml");
//			zip.putNextEntry(entry);
//			zip.write(ba);
//			zip.closeEntry();
//			
//			
//			entry = new ZipEntry(baseURL+"browser.swf");
//			zip.putNextEntry(entry);
//			zip.write(_browserSwf.byteArray);
//			zip.closeEntry();
//			
//			
//			entry = new ZipEntry("custom/start.html");
//			zip.putNextEntry(entry);
//			zip.write(_startHtml.byteArray);
//			zip.closeEntry();
//			
//			
//			zip.finish();
//			
////var zipOut:ZipOutput = new ZipOutput();
////// Add entry to zip
////var ze:ZipEntry = new ZipEntry(fileName);
////zipOut.putNextEntry(ze);
////zipOut.write(fileData);
////zipOut.closeEntry();
////// end the zip
////zipOut.finish();
////// access the zip data
////var zipData:ByteArray = zipOut.byteArray;
////			
//			
//			trace("success!");
//			
//			_fr.save(zip.byteArray, "custom.zip");
//		}
//		
//		protected var _fr:FileReference;
//		
		
//		protected var _activeZip:ZipOutput;
		
		protected var _modulesList:ModulesList;
		
		public function get modulesList():ModulesList {
			return _modulesList;
		}
		
		public function set modulesList(m:ModulesList):void {
			_modulesList = m;
			_modulesList.addEventListener(ModulesList.UPDATE, onModuleListUpdate);
			redraw();
		}
		
		protected function onModuleListUpdate(evt:Event):void {
			redraw();
		}
		
		protected function onModuleUpdate(evt:Event):void {
			redraw();
		}
		
		protected function redraw():void {
			
			_panes.reset();
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {columnTopMargin: 45, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};
			
			var i:int;
			var ct:ClickableText;
			
			_panes.addContent(_standardHeading, headingParams);
			for (i=0; i<_modulesList.modules.length; i++) {
				if (_modulesList.modules[i].readOnly) {
					if (_moduleLinks[modulesList.modules[i]]==undefined) {
						ct = new ClickableText(_modulesList.modules[i].name, _modulesList.modules[i], _itemFormat, _panes.columnWidth);		
						ct.addEventListener(ClickableText.ON_CLICK, onModuleClicked, false, 0, true);
						_moduleLinks[modulesList.modules[i]] = ct;
					}
					_panes.addContent(_moduleLinks[modulesList.modules[i]], itemParams);
				}
			}
			
			if (_readOnly) return;
			
			_panes.advanceColumn();
			
			var numCustom:int = 0;
			
			_panes.addContent(_customHeading, headingParams);
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					numCustom++;
					
					if (_moduleLinks[modulesList.modules[i]]==undefined) {
						// have not encountered this custom module before
						
						// listen for module updates
						_modulesList.modules[i].addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
						
						// create the label
						ct = new EditableClickableText(_modulesList.modules[i].name, _modulesList.modules[i], _itemFormat, _panes.columnWidth);		
						ct.addEventListener(EditableClickableText.DIMENSIONS_CHANGED, onModuleNameEntered, false, 0, true);
						ct.addEventListener(EditableClickableText.EDIT_DONE, onModuleNameEntered, false, 0, true);
						ct.addEventListener(ClickableText.ON_CLICK, onModuleClicked, false, 0, true);
						ct.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelect, false, 0, true);
						ct.addMenuItem(_deleteItemText, onModuleDeleteRequest);
									
						_moduleLinks[modulesList.modules[i]] = ct;
					}	
					
					if (_moduleLinks[modulesList.modules[i]].text!=modulesList.modules[i].name) {
						_moduleLinks[modulesList.modules[i]].setText(modulesList.modules[i].name);
					}
					
					_panes.addContent(_moduleLinks[modulesList.modules[i]], itemParams);
				}
			}
			
			if (numCustom>0) itemParams.topMargin = 10;
			if (numCustom<_customModuleLimit) {
				_panes.addContent(_createCommand, itemParams);
				itemParams.topMargin = 0;
			}
			if (numCustom>0) _panes.addContent(_downloadCommand, itemParams);
		}
		
		protected var _customModuleLimit:int = 12;
		
		protected var _deleteItemText:String = "Delete (hold Shift)";
		
		protected function onMenuSelect(evt:ContextMenuEvent):void {
			// this function handles the right-clicks on custom module names
			for (var i:int = 0; i<evt.target.customItems.length; i++) {
				if (evt.target.customItems[i].caption==_deleteItemText) {
					evt.target.customItems[i].enabled = KeyListener.isDown(Keyboard.SHIFT);
					KeyListener.reset();
					break;
				}					
			}
		}
		
		// moduleLinks contains the references to the ClickableText or EditableClickableText
		// instances associated with each module
		protected var _moduleLinks:Dictionary;
		
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
		
		protected function onModuleClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(ModulesListView.MODULE_SELECTED, evt.target.data));
		}

		protected function onLeftButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(-1, _easeTime);
		}
		
		protected function onRightButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(1, _easeTime);
		}
				
	}
}

