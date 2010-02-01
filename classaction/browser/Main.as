
package astroUNL.classaction.browser {
	
	import astroUNL.classaction.browser.events.MenuEvent;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourcePanelsGroup;
	import astroUNL.classaction.browser.views.ResourcePreview;
	import astroUNL.classaction.browser.views.ModulesListView;
	import astroUNL.classaction.browser.views.ModuleView;
	import astroUNL.classaction.browser.views.QuestionView;
	import astroUNL.classaction.browser.views.BreadcrumbsBar;
	import astroUNL.classaction.browser.views.ZipDownloader;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.resources.QuestionsBank;
	import astroUNL.classaction.browser.resources.ResourceBanksLoader;
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	
	import astroUNL.utils.keylistener.KeyListener;
	import astroUNL.utils.logger.Logger;
	
	import flash.utils.ByteArray;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.system.Security;
	import flash.system.Capabilities;
	
	
	import flash.utils.Dictionary;
	import flash.net.SharedObject;
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	
	public class Main extends Sprite {
		
		protected var _modulesList:ModulesList;		
		protected var _so:SharedObject;
		protected var _resourcePanels:ResourcePanelsGroup;
		protected var _resourcePreview:ResourcePreview;		
		protected var _zipDownloader:ZipDownloader;
		
		public function Main(readOnly:Boolean) {
			_readOnly = readOnly;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected var _readOnly:Boolean;
		
		// the background exists so that MouseOver events can be fired from the
		// stage when returning from a context menu (this is needed since there's no
		// mouseEnter to match the mouseLeave event)
		protected var _background:Sprite;
		protected var _backgroundColor:uint = 0x000000;
		protected var _backgroundAlpha:Number = 0;
		
		protected function onAddedToStage(evt:Event):void {
			
			_registeredCustomModules = new Dictionary();
			
			stage.showDefaultContextMenu = false;
			
			if (!_readOnly) {
				try {
					_so = SharedObject.getLocal("classaction");
					_so.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onSOAsyncError);
					_so.addEventListener(NetStatusEvent.NET_STATUS, onSONetStatus);
				}
				catch (err:Error) {
					_so = null;
				}
			}
			else _so = null;
			
			if (Security.sandboxType==Security.REMOTE) Downloader.init("");
			else if (_readOnly) Downloader.init("classaction/");
			else if (Capabilities.isDebugger) Downloader.init("C:/Documents and Settings/Chris/Desktop/new classaction/");
			else Downloader.init("");
			
			_background = new Sprite();
			_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_background.graphics.endFill();
			addChild(_background);
			
			addChild(KeyListener.getListenerProxy());
			
			ResourceBanksLoader.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onResourceBanksLoadFinished);
			ResourceBanksLoader.start();			
			
			_modulesListView = new ModulesListView(_readOnly);
			_modulesListView.addEventListener(ModulesListView.MODULE_SELECTED, onModuleSelected);
			_modulesListView.addEventListener(ModulesListView.START_ZIP_DOWNLOAD, onZipDownloadStart);
			_modulesListView.x = 0;
			_modulesListView.y = 30;
			addChild(_modulesListView);
						
			_moduleView = new ModuleView();
			_moduleView.addEventListener(ModuleView.QUESTION_SELECTED, onQuestionSelected);
			_moduleView.addEventListener(ModuleView.MODULES_LIST_SELECTED, onModulesListSelected);
			_moduleView.x = 0;
			_moduleView.y = 30;
			addChild(_moduleView);
			
			_questionView = new QuestionView();
			_questionView.x = 10;
			_questionView.y = 40;
			addChild(_questionView);
			
			_breadcrumbs = new BreadcrumbsBar();
			_breadcrumbs.addEventListener(BreadcrumbsBar.MODULE_SELECTED, onModuleSelected);
			_breadcrumbs.addEventListener(BreadcrumbsBar.MODULES_LIST_SELECTED, onModulesListSelected);
			_breadcrumbs.x = 20;
			_breadcrumbs.y = 5;
			addChild(_breadcrumbs);
			
			_resourcePanels = new ResourcePanelsGroup(_readOnly);
			_resourcePanels.x = 0;
			_resourcePanels.y = stage.stageHeight;
			_resourcePanels.addEventListener(ResourcePanelsGroup.PREVIEW_ITEM_CHANGED, onPreviewItemChanged);
			addChild(_resourcePanels);
			
			_resourcePreview = new ResourcePreview();
			addChild(_resourcePreview);
			
			_zipDownloader = new ZipDownloader();
			_zipDownloader.addEventListener(ZipDownloader.DONE, onZipDownloadDone);
			_zipDownloader.visible = false;
			addChild(_zipDownloader);
		}
		
		protected function onPreviewItemChanged(evt:Event):void {
			var item:ResourceItem = _resourcePanels.previewItem;
			if (item==null) _resourcePreview.hide();
			else _resourcePreview.show(item, _resourcePanels.previewPosition);
		}
		
		protected function onSOAsyncError(evt:AsyncErrorEvent):void {
			trace("onSOAsyncError, "+evt);
		}
		
		protected function onSONetStatus(evt:NetStatusEvent):void {
			trace("onSONetStatus, "+evt);
		}
		
		protected var _customModulesList:Array;
				
		protected function storeCustomModules():void {
			if (_so==null) return;
			var startTimer:Number = getTimer();
			_customModulesList = [];
			var i:int;
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					_customModulesList.push(_modulesList.modules[i].getSerialization());
				}
			}
			_so.setProperty("customModules", _customModulesList);
			trace("storeCustomModules: "+(getTimer()-startTimer));
		}
		
		protected function loadStoredCustomModules():void {
			if (_so==null) return;
			var startTimer:Number = getTimer();
			var module:Module;
			var serialization:ByteArray = new ByteArray();
			if (_so.data.customModules is Array) {
				for (var i:int = 0; i<_so.data.customModules.length; i++) {
					if (_so.data.customModules[i] is ByteArray) {
						serialization.length = 0;
						serialization.writeBytes(_so.data.customModules[i]);
						module = new Module(null, false, serialization);
						if (module.serializationSuccess) _modulesList.addModule(module);
						else Logger.report("failed to load a stored custom module");
					}
				}
			}
			trace("loadStoredCustomModules: "+(getTimer()-startTimer));
		}
		
		protected function onCustomModuleUpdate(evt:Event):void {
			if (evt.target==_selectedModule && _selectedQuestion!=null) {
				// check to see if the currently selected question was removed from the selected module
				var i:int;
				for (i=0; i<_selectedQuestion.modulesList.length; i++) {
					if (_selectedQuestion.modulesList[i]==_selectedModule) break;
				}
				if (i>=_selectedQuestion.modulesList.length) {
					trace("falling back to module view");
					setView(_selectedModule, null);
				}
			}
			storeCustomModules();
		}
		
		protected function onModulesListUpdate(evt:Event):void {
			addCustomModuleUpdateListeners();
			storeCustomModules();
		}
		
		protected var _registeredCustomModules:Dictionary;
		
		protected function addCustomModuleUpdateListeners():void {
			// only need to add listeners for new custom modules
			for (var i:int = 0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					if (!_registeredCustomModules[_modulesList.modules[i]]) {
						_modulesList.modules[i].addEventListener(Module.UPDATE, onCustomModuleUpdate, false, 0, true);
						_registeredCustomModules[_modulesList.modules[i]] = true;
					}
				}
			}
		}
	
		protected function onResourceBanksLoadFinished(evt:Event):void {
			if (!QuestionsBank.loaded) {
				// if the questions bank could not be loaded that's a fatal error 
				var explanation:String = "The questions bank could not be loaded. ";
				if (QuestionsBank.downloadState==Downloader.DONE_FAILURE) explanation += "The specification file could not be downloaded.";
				else explanation += "The specification file could not be parsed.";
				reportFailure(explanation);
			}
			else {
				// the next step is to load the modules list and the associated module files
				
				_modulesList = new ModulesList("moduleslist.xml");
				_modulesList.addEventListener(ModulesList.LOAD_FINISHED, onModulesListLoadFinished);
				// the modules list update listener is added after loading custom modules from the shared object
			}
		}
		
		protected function onModulesListLoadFinished(evt:Event):void {
			if (!_modulesList.listLoaded) {
				// failed to load the list of modules -- this is a fatal error
				var explanation:String = "The list of modules could not be loaded. ";
				if (_modulesList.downloadState==Downloader.DONE_FAILURE) explanation += " The specification file could not be downloaded.";
				else explanation += " The specification file could not be parsed.";
				reportFailure(explanation);
			}
			else {
				// the modules list is loaded and we're ready to present the views
				
				// but first, lets load any stored custom module specifications, and then register
				// update listeners so we can store any changes				
				loadStoredCustomModules();
				_modulesList.addEventListener(ModulesList.UPDATE, onModulesListUpdate);
				addCustomModuleUpdateListeners();
				
				// now we're ready to present the views
				
				_resourcePanels.init();
				_resourcePanels.modulesList = _modulesList;
				
				_modulesListView.modulesList = _modulesList;
				_moduleView.modulesList = _modulesList;
				
				_zipDownloader.modulesList = _modulesList;

				ResourceContextMenuController.modulesList = _modulesList;
				

				loadStoredState();
				
			}
		}		
		
		protected function loadStoredState():void {			
			// if a valid previous state has been saved in the shared object, use it,
			// otherwise, start with the modules list; note: in the shared object, a module
			// is designated by its url, and a question is designated by its id
			if (_so!=null) {
				var selectedModule:Module = null;
				var selectedQuestion:Question = null;
				var i:int;
				if (_so.data.selectedModule is String) {
					for (i=0; i<_modulesList.modules.length; i++) {
						if (_so.data.selectedModule==_modulesList.modules[i].downloadURL) {
							selectedModule = _modulesList.modules[i];
							break;
						}						
					}
				}
				if ((_so.data.selectedQuestion is String) && selectedModule!=null) {
					// we require the selected question to be in the selected module, and since
					// this may have changed since the last saving of state, we need to check
					for (i=0; i<selectedModule.allQuestionsList.length; i++) {
						if (_so.data.selectedQuestion==selectedModule.allQuestionsList[i].id) {
							selectedQuestion = selectedModule.allQuestionsList[i];								
						}							
					}
				}
				setView(selectedModule, selectedQuestion);
			}
			else setView(null, null);
		}
		
		protected function storeState():void {
			if (_so!=null) {
				_so.setProperty("selectedModule", (_selectedModule==null) ? "" : _selectedModule.downloadURL);
				_so.setProperty("selectedQuestion", (_selectedQuestion==null) ? "" : _selectedQuestion.id);
			}			
		}
		
		protected function onModulesListSelected(evt:Event):void {
			setView(null, null);
		}
		
		protected function onModuleSelected(evt:MenuEvent):void {
			setView(evt.data, null);
		}
		
		protected function onQuestionSelected(evt:MenuEvent):void {
			setView(_selectedModule, evt.data);
		}
		
		protected var _selectedModule:Module;
		protected var _selectedQuestion:Question;
		
		protected function setView(module:Module=null, question:Question=null):void {
			
			_modulesListView.visible = false;
			_moduleView.visible = false;
			_questionView.visible = false;
			
			_zipDownloader.visible = false;
			
			_selectedModule = module;
			_selectedQuestion = question;
			
			if (_selectedModule==null && _selectedQuestion==null) {
				_modulesListView.visible = true;
			}
			else if (_selectedModule!=null && _selectedQuestion==null) {
				Downloader.cancel(0);
				Downloader.get(_selectedModule.allQuestionsList);
				_moduleView.module = _selectedModule;
				_moduleView.visible = true;
			}
			else if (_selectedModule!=null && _selectedQuestion!=null) {
				if (_selectedQuestion.downloadState==Downloader.NOT_QUEUED) Downloader.get(_selectedQuestion);
				_selectedQuestion.downloadPriority = _topPriority++;
				_questionView.visible = true;
			}
			else {
				trace("error in setView, selectedModule: "+_selectedModule+", selectedQuestion: "+_selectedQuestion);
				setView(null, null);
			}
			
			
			_questionView.question = _selectedQuestion;
			
			_resourcePanels.setState(_selectedModule, _selectedQuestion);
			_breadcrumbs.setState(_selectedModule, _selectedQuestion);

			ResourceContextMenuController.setState(_selectedModule, _selectedQuestion);
			
			_resourcePanels.minimizeAll();
			
			storeState();
		}
		
		protected var _topPriority:int = 1;
		
		protected var _modulesListView:ModulesListView;
		protected var _moduleView:ModuleView;
		protected var _questionView:QuestionView;
		protected var _breadcrumbs:BreadcrumbsBar;
		
		protected function onZipDownloadStart(evt:Event):void {
			_zipDownloader.visible = true;
			_zipDownloader.start();
		}
		
		protected function onZipDownloadDone(evt:Event):void {
			_zipDownloader.visible = false;
		}
		
		protected function reportFailure(text:String):void {
			Logger.report(text);		
		}
		
	}	
}

