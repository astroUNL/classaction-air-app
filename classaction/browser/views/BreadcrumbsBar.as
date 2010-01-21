
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
		
		
		public function BreadcrumbsBar() {
			
			_linkTextFormat = new TextFormat("Verdana", 12, 0xffffff, true);
			
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
//			_questionLink.setEnabled(false);
			_questionLink.setClickable(false);
			addChild(_questionLink);
			
			ResourceContextMenuController.register(_questionLink);
		}
		
		protected var _linkTextFormat:TextFormat;
		
		protected function onModuleNameEdited(evt:Event):void {
			_module.name = evt.target.text;
		}
		
		protected function onModulesListClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULES_LIST_SELECTED, null));
			
		}
		
		protected function onModuleClicked(evt:Event):void {
			if (_module!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULE_SELECTED, _module));
		}

		
		protected var _module:Module;
		protected var _question:Question;
		
		protected function onModuleUpdate(evt:Event):void {
			reposition();			
		}
		
		public function setState(module:Module=null, question:Question=null):void {
			trace("setState in Breadcrumbs");
			//trace("breadcrumbs set state: "+(module==null ? "(null)" : module.name)+", "+(question==null ? "(null)" : question.name));
			
			if (_module!=null) _module.removeEventListener(Module.UPDATE, onModuleUpdate, false);
			
			if (module!=null) module.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
			
			_module = module;
			_question = question;
			
			_modulesListLink.visible = true;
			
			if (module!=null) {
//				_modulesListLink.setEnabled(true);
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
					
//					_moduleLink.setEnabled(true);
					_moduleLink.setClickable(true);
					_editableModuleLink.setClickable(true);
				}
				else {
					_questionLink.visible = false;
					
//					_moduleLink.setEnabled(false);
					_moduleLink.setClickable(false);
					_editableModuleLink.setClickable(false);
				}				
				
			}
			else {
//				_modulesListLink.setEnabled(false);
				_modulesListLink.setClickable(false);
				_moduleLink.visible = false;
				_editableModuleLink.visible = false;
				_questionLink.visible = false;
			}
			
			reposition();
		}
		
		protected function reposition():void {
			var margin:Number = 20;
			_modulesListLink.x = margin;
			_editableModuleLink.x = _moduleLink.x = _modulesListLink.x + _modulesListLink.width + margin;
			if (_module!=null) {
				if (_module.readOnly) {
					_questionLink.x = _moduleLink.x + _moduleLink.width + margin;
				}
				else {
					_questionLink.x = _editableModuleLink.x + _editableModuleLink.width + margin;
				}
			}
		}
		
		
	}	
}

