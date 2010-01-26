
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.views.elements.EditableClickableText;
	import astroUNL.classaction.browser.views.elements.ResourceContextMenuController;
	import astroUNL.classaction.browser.events.MenuEvent;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class BreadcrumbsBar extends Sprite {
		
		public static const MODULE_SELECTED:String = "moduleSelected";
		public static const MODULES_LIST_SELECTED:String = "modulesListSelected";
		
		
		protected var _modulesListLink:ClickableText;
		protected var _moduleLink:ClickableText;
		protected var _editableModuleLink:EditableClickableText;
		protected var _questionLink:ClickableText;
		
		protected var _separator:String = "»";
		protected var _separator1:ClickableText;
		protected var _separator2:ClickableText;
		
		protected var _separatorTextFormat:TextFormat;
		protected var _linkTextFormat:TextFormat;
		
		protected var _spacing:Number = 4;
		
		protected var _module:Module;
		protected var _question:Question;
		
		public function BreadcrumbsBar() {
			
			_linkTextFormat = new TextFormat("Verdana", 12, 0xffffff, true);
			_separatorTextFormat = new TextFormat("Verdana", 12, 0xffffff, true);
			
			_separator1 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator1.visible = false;
			_separator1.setClickable(false);
			addChild(_separator1);
			
			_separator2 = new ClickableText(_separator, null, _separatorTextFormat);
			_separator2.visible = false;
			_separator2.setClickable(false);
			addChild(_separator2);
			
			_modulesListLink = new ClickableText("All Modules", null, _linkTextFormat);
			_modulesListLink.addEventListener(ClickableText.ON_CLICK, onModulesListClicked);
			_modulesListLink.visible = false;
			addChild(_modulesListLink);
			
			_moduleLink = new ClickableText("", null, _linkTextFormat);
			_moduleLink.addEventListener(ClickableText.ON_CLICK, onModuleClicked);
			_moduleLink.visible = false;
			addChild(_moduleLink);
			
			_editableModuleLink = new EditableClickableText("", null, _linkTextFormat);
			_editableModuleLink.addEventListener(ClickableText.ON_CLICK, onModuleClicked);
			_editableModuleLink.addEventListener(EditableClickableText.EDIT_DONE, onModuleNameEdited);
			_editableModuleLink.addEventListener(EditableClickableText.DIMENSIONS_CHANGED, onModuleNameEdited);
			_editableModuleLink.visible = false;
			addChild(_editableModuleLink);
			
			_questionLink = new ClickableText("", null, _linkTextFormat);
			_questionLink.visible = false;
			_questionLink.setClickable(false);
			addChild(_questionLink);
			
			ResourceContextMenuController.register(_questionLink);
		}
		
		protected function onModuleNameEdited(evt:Event):void {
			_module.name = evt.target.text;
		}
		
		protected function onModulesListClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULES_LIST_SELECTED, null));
			
		}
		
		protected function onModuleClicked(evt:Event):void {
			if (_module!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULE_SELECTED, _module));
		}

		protected function onModuleUpdate(evt:Event):void {
			reposition();			
		}
		
		public function setState(module:Module=null, question:Question=null):void {
			
			if (_module!=null) _module.removeEventListener(Module.UPDATE, onModuleUpdate, false);
			
			if (module!=null) module.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
			
			_module = module;
			_question = question;
			
			_modulesListLink.visible = true;
			_separator1.visible = true;
			
			if (module!=null) {
				_modulesListLink.setClickable(true);
				
				if (module.readOnly) {
					_moduleLink.setText(module.name);
					_moduleLink.visible = true;
					_editableModuleLink.visible = false;
				}
				else {
					_editableModuleLink.setText(module.name);
					_editableModuleLink.visible = true;
					_moduleLink.visible = false;
				}
				
				if (question!=null) {
					_questionLink.setText(_question.name);
					_questionLink.visible = true;
					
					_questionLink.data = {item: _question};
					
					_moduleLink.setClickable(true);
					_editableModuleLink.setClickable(true);
					
					_separator2.visible = true;
				}
				else {
					_questionLink.visible = false;
					
					_moduleLink.setClickable(false);
					_editableModuleLink.setClickable(false);
					
					_separator2.visible = false;
				}				
				
				_separator1.visible = true;				
			}
			else {
				_modulesListLink.setClickable(false);
				_moduleLink.visible = false;
				_editableModuleLink.visible = false;
				_questionLink.visible = false;
				
				_separator1.visible = false;
				_separator2.visible = false;
			}
			
			reposition();
		}
		
		protected function reposition():void {
			_modulesListLink.x = 0;
			_separator1.x = _modulesListLink.x + _modulesListLink.width + _spacing;
			_editableModuleLink.x = _moduleLink.x = _separator1.x + _separator1.width + _spacing;
			if (_module!=null) {
				if (_module.readOnly) _separator2.x = _moduleLink.x + _moduleLink.width + _spacing;
				else _separator2.x = _editableModuleLink.x + _editableModuleLink.width + _spacing;
				_questionLink.x = _separator2.x + _separator2.width + _spacing;
			}
		}
		
	}	
}

