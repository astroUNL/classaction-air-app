
package astroUNL.classaction.browser.views.elements {
	
	// this class adds context menu support for resources (question, animations, etc.) so that
	// they can be added to custom modules via right-clicking
	
	// to use, call ResourceContextMenuController.register(object) where object is the display object
	// that you want to have the right-click active on; the display object must have an object called 'data'
	// with a property called 'item', which should be the ResourceItem associated with the display object;
	// (it's done this way so that it can work with ClickableText objects)	
	
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.Module;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.utils.Dictionary;
	
	
	
	public class ResourceContextMenuController {

		protected static const _addToMenuText:String = "Add to…";
		protected static const _removeFromMenuText:String = "Remove from…";
		protected static const _moduleMenuTextPrefix:String = "…";
		protected static const _addRelevantText:String = "Mark as relevant";
		protected static const _removeRelevantText:String = "Unmark as relevant";

		public function ResourceContextMenuController() {
			trace("ResourceContextMenuController not meant to be instantiated");			
		}
		
		public static function register(obj:InteractiveObject):void {
			if (obj.contextMenu==null) obj.contextMenu = new ContextMenu();
			obj.contextMenu.hideBuiltInItems();
			obj.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onMenuSelect, false, 0, true);
		}
		
		public static function set modulesList(arg:ModulesList):void {
			_modulesList = arg;		
		}
		
		protected static var _selectedModule:Module;
		protected static var _selectedQuestion:Question;
		
		public static function setState(module:Module, question:Question):void {
			_selectedModule = module;
			_selectedQuestion = question;
		}
		
		protected static function onMenuSelect(evt:ContextMenuEvent):void {
						
			var menu:ContextMenu = evt.target as ContextMenu;
			if (menu==null) return;
			menu.customItems = [];
			
			var item:ResourceItem = (evt.contextMenuOwner as Object).data.item as ResourceItem;
			if (item==null) {
				trace("************************************ bad bad bad");
				return;
			}
						
			// when done these lists will be populated with the custom modules the
			// item is included and not included in
			var inList:Array = [];
			var outList:Array = [];
			
			// populate the in and out lists
			var i:int, j:int;
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					for (j=0; j<item.modulesList.length; j++) {
						if (_modulesList.modules[i]==item.modulesList[j]) {
							inList.push(_modulesList.modules[i]);
							break;
						}						
					}
					if (j>=item.modulesList.length) outList.push(_modulesList.modules[i]);
				}
			}
			
			_moduleLookup = new Dictionary();			
			var menuItem:ContextMenuItem;
			
			// modules the resource could be added to
			if (outList.length>0) {
				menuItem = new ContextMenuItem(_addToMenuText);
				menu.customItems.push(menuItem);
				for (i=0; i<outList.length; i++) {
					menuItem = new ContextMenuItem(_moduleMenuTextPrefix+outList[i].name);
					menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemAddToModule, false, 0, true);
					menu.customItems.push(menuItem);
					_moduleLookup[menuItem] = outList[i];
				}
			}
			
			// modules the resource could be removed from
			if (inList.length>0) {
				menuItem = new ContextMenuItem(_removeFromMenuText, outList.length>0);
				menu.customItems.push(menuItem);			
				for (i=0; i<inList.length; i++) {
					menuItem = new ContextMenuItem(_moduleMenuTextPrefix+inList[i].name);
					menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onItemRemoveFromModule, false, 0, true);
					menu.customItems.push(menuItem);
					_moduleLookup[menuItem] = inList[i];
				}			
			}
			
			/* the ability to mark resources as relevant has temporarily removed since the changes
			   do no persist between sessions
			
			// if there is a currently selected question and the item is something other than a question,
			// then present the option to make the item a relevant resource (or to remove the item as a
			// relevant resource if it already is such)
			
			if (_selectedQuestion!=null && item.type!=ResourceItem.QUESTION) {
				var relevantIDsList:Array;
				if (item.type==ResourceItem.ANIMATION) relevantIDsList = _selectedQuestion.relevantAnimationIDsList;
				else if (item.type==ResourceItem.IMAGE) relevantIDsList = _selectedQuestion.relevantImageIDsList;
				else if (item.type==ResourceItem.OUTLINE) relevantIDsList = _selectedQuestion.relevantOutlineIDsList;
				else if (item.type==ResourceItem.TABLE) relevantIDsList = _selectedQuestion.relevantTableIDsList;
				
				if (relevantIDsList!=null) {
					var useSeparator:Boolean = (inList.length>0 || outList.length>0);
					for (i=0; i<relevantIDsList.length; i++) {
						if (relevantIDsList[i]==item.id) {
							// the item is already in the relevant resources list so give the option to remove it
							menuItem = new ContextMenuItem(_removeRelevantText, useSeparator);
							menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onRemoveRelevantItem, false, 0, true);
							menu.customItems.push(menuItem);
							break;
						}
					}
					if (i>=relevantIDsList.length) {
						// give the choice to make this a relevant resource
						menuItem = new ContextMenuItem(_addRelevantText, useSeparator);
						menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onAddRelevantItem, false, 0, true);
						menu.customItems.push(menuItem);
					}
				}
				else Logger.report("invalid item type in ResourceContextMenuController.onMenuSelect");
			}			
			*/
		}
		
		protected static function onAddRelevantItem(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as Object).data.item as ResourceItem;
			if (item!=null && _selectedQuestion!=null && _selectedModule!=null) {
				
				// first, check that the resource belongs to the selected module, if not, add it
				var i:int;
				for (i=0; i<item.modulesList.length; i++) if (_selectedModule==item.modulesList[i]) break;
				if (i>=item.modulesList.length) _selectedModule.addResource(item);
				else trace("the resource already belongs to the selected module");
				
				_selectedQuestion.addRelevantResource(item);
			}
		}
		
		protected static function onRemoveRelevantItem(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as Object).data.item as ResourceItem;
			if (item!=null && _selectedQuestion!=null) _selectedQuestion.removeRelevantResource(item);
		}
		
		protected static var _modulesList:ModulesList;
		
		// moduleLookup is used to lookup the module associated with a given context menu item
		protected static var _moduleLookup:Dictionary;
		
		protected static function onItemAddToModule(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as Object).data.item as ResourceItem;
			if (item!=null) {
				if (item is Question) _moduleLookup[evt.target].addQuestion(item as Question);
				else _moduleLookup[evt.target].addResource(item);
			}
			else trace("************************************ bad bad bad");
		}
		
		protected static function onItemRemoveFromModule(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as Object).data.item as ResourceItem;
			if (item!=null) {
				if (item is Question) _moduleLookup[evt.target].removeQuestion(item as Question);
				else _moduleLookup[evt.target].removeResource(item);
			}
			else trace("************************************ bad bad bad");
		}
		
	}
}

