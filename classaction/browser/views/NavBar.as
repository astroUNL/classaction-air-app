﻿
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class NavBar extends Sprite {
		
		// the currently selected item (from the NavBar's point of view) is expressed
		// using the module and question read-only variables, it is the responsibility of
		// the main controller to sync on a nav event
		
		// when the state changes in the main controller it alerts the NavBar by calling
		// setState so that the NavBar can add the new state to its queue		
		
		// the nav event is dispatched whenever the current item in the queue changes
		// due to a button press or due to a pruning event (which might occur after a
		// module has been deleted or a question removed from a module)
		public static const NAV:String = "nav";
		
		protected var _back:NavBarButton;
		protected var _forward:NavBarButton;
		
		protected var _navInProgress:Boolean = false;
		protected var _currItem:NavItem;
		
		protected var _customModules:Dictionary; // used so that module listeners get added just once
		protected var _modulesList:ModulesList;
		protected var _id:int = 0; // assigns unique numbers to queue items, for debugging
		
		public function NavBar() {
			
			visible = false;
			
			var shift:Number = 6.5;
			
			_back = new NavBarButton();
			_back.rotation = 180;
			_back.addEventListener(MouseEvent.CLICK, onBack);
			_back.x = -shift;
			addChild(_back);
			
			_forward = new NavBarButton();
			_forward.addEventListener(MouseEvent.CLICK, onForward);
			_forward.x = shift;
			addChild(_forward);
			
			update();
		}
		
		// the read-only properties module and question specify the currently selected item
		
		public function get module():Module {
			if (_currItem!=null) return _currItem.module;
			else return null;
		}
		
		public function get question():Question {
			if (_currItem!=null) return _currItem.question;
			else return null;
		}
		
		public function setState(module:Module, question:Question):void {
			// called by the main controller when the state has changed
			// however, if the main controller is itself reacting to a nav event
			// dispatched by this NavBar then we shouldn't do anything
			if (!_navInProgress) {
				var item:NavItem;
				item = new NavItem();
				item.module = module;
				item.question = question;
				item.id = _id++;
				if (_currItem!=null) {
					removeBranch(_currItem.next);
					_currItem.next = item;
					item.prev = _currItem;
				}
				_currItem = item;
				enforceLengthLimit();
				update();
			}
		}
		
		public function get modulesList():ModulesList {
			return _modulesList;
		}
		
		public function set modulesList(list:ModulesList):void {
			// the NavBar listens to the modules list so that it can attach listeners to 
			// newly added modules and prune out deleted modules
			visible = true;
			_modulesList = list;
			_customModules = new Dictionary();
			_modulesList.addEventListener(ModulesList.UPDATE, onModuleListUpdate);
			onModuleListUpdate();
		}
		
		protected function update():void {
			// this function updates the buttons so that they are appropriately enabled or disabled
			// depending on where we are in the queue
			if (_currItem==null) {
				_forward.enabled = false;
				_back.enabled = false;
			}
			else {
				_forward.enabled = (_currItem.next!=null);
				_back.enabled = (_currItem.prev!=null);
			}
//			traceQueue();
		}
		
//		protected function traceQueue():void {
//			if (_currItem!=null) {
//				trace("queue:");
//				var item:NavItem = _currItem;
//				var moduleName:String, questionName:String;
//				while (item.prev!=null) item = item.prev;
//				var pre:String;
//				do {
//					pre = (item==_currItem) ? " +" : "  ";
//					moduleName = (item.module!=null) ? item.module.name : "null";
//					questionName = (item.question!=null) ? item.question.name : "null";
//					trace(pre+" "+item.id+", "+moduleName+", "+questionName);
//					item = item.next;
//				} while (item!=null);
//			}
//			else trace("queue:\r ...empty...");
//		}
		
		protected function onBack(evt:MouseEvent):void {
			if (_currItem!=null && _currItem.prev!=null) doNav(_currItem.prev);
		}
		
		protected function onForward(evt:MouseEvent):void {
			if (_currItem!=null && _currItem.next!=null) doNav(_currItem.next);
		}				
		
		protected function onModuleListUpdate(evt:Event=null):void {
			// assign listeners to each of the custom modules (assuming we haven't already)
			// so that we know when a question has been removed from a module, which 
			// may necessitate pruning of the queue
			for each (var m:Module in _modulesList.modules) {
				if (!m.readOnly && _customModules[m]==undefined) {
					_customModules[m] = true;
					m.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
				}
			}
			prune(); // a module in the queue may have been deleted
		}
		
		protected function onModuleUpdate(evt:Event):void {
			prune(); // a question in the queue may have been removed from a module
		}

		protected function prune():void {
			var currItemAtStart:NavItem = _currItem;
			
			var item:NavItem;
			var next:NavItem;
			
			// first, remove all states referencing a deleted module
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null) {
					next = item.next;
					if (item.module!=null && !item.module.readOnly && !_modulesList.hasModule(item.module)) {
						// deleted module found
						removeItem(item);
					}
					item = next;
				}
			}
			
			// remove all states where the question is no longer in the custom module
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null) {
					next = item.next;
					if (item.module!=null && item.question!=null && !item.module.readOnly && !item.module.hasQuestion(item.question)) {
						// removed question found
						removeItem(item);
					}
					item = next;
				}
			}
				
			// consolidate all consecutive identical states
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null && item.next!=null) {					
					if (item.module==item.next.module && item.question==item.next.question) {
						// identical states found						
						removeItem(item.next);
					}
					else item = item.next;
				}
			}
			
			// if the current item changed due to pruning then we need to sync to the new state
			if (currItemAtStart!=_currItem) doNav(_currItem);
//			else traceQueue();
		}
		
		// a very long queue can cause the prune function to take a lot of time, so a limit is useful 
		//  - note that the limit applies only to the number of items before the currently selected item
		//  - set to a negative number if you don't want a limit
		protected var _lengthLimit:int = 20;
		
		protected function enforceLengthLimit():void {
			// this function enforces a limit on the length of the queue preceeding the currently selected item
			var lastItem:NavItem = _currItem;
			for (var i:int = 0; i<_lengthLimit; i++) {
				if (lastItem.prev!=null) lastItem = lastItem.prev;
				else break;
			}
			removeRoot(lastItem.prev);
		}
		
		protected function doNav(item:NavItem):void {
			_navInProgress = true;
			_currItem = item;
			dispatchEvent(new Event(NavBar.NAV));
			_navInProgress = false;
			update();
		}
		
		protected function removeItem(item:NavItem):void {
			// removes an item from the queue by splicing the previous and next items together
			// if the item is the currently selected item then that designation will 
			// go to, in order: the previous item, the next item, null
			// (the preference for the previous item is due to how pruning of redundant states works)
			if (item!=null) {
				if (item==_currItem) {
					if (item.prev!=null) _currItem = item.prev;
					else if (item.next!=null) _currItem = item.next;
					else _currItem = null;
				}
				if (item.next!=null) item.next.prev = item.prev;
				if (item.prev!=null) item.prev.next = item.next;			
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
			}			
		}
		
		protected function removeBranch(item:NavItem):void {
			// removes an item and all items after it
			// if any of the items are the currently selected item then that designation will 
			// go to the item just before the ones that have been removed (the tip)
			var tip:NavItem = null;
			if (item!=null && item.prev!=null) {
				item.prev.next = null;
				tip = item.prev;
			}
			var next:NavItem;
			while (item!=null) {
				next = item.next;
				if (item==_currItem) _currItem = tip;
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
				item = next;
			}			
		}
		
		protected function removeRoot(item:NavItem):void {
			// removes an item and all items before it
			// if any of the items are the currently selected item then that designation will 
			// go to the item just after the ones that have been removed (the new root)
			var newRoot:NavItem = null;
			if (item!=null && item.next!=null) {
				item.next.prev = null;
				newRoot = item.next;
			}
			var prev:NavItem;
			while (item!=null) {
				prev = item.prev;
				if (item==_currItem) _currItem = newRoot;
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
				item = prev;
			}			
		}
		
	}	
}


import astroUNL.classaction.browser.resources.Module;
import astroUNL.classaction.browser.resources.Question;

internal class NavItem {
	public var module:Module;
	public var question:Question;
	public var next:NavItem;
	public var prev:NavItem;
	public var id:int;
}
