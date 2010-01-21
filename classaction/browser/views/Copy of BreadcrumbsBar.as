
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.ClickableText;
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
			
			_questionLink = new ClickableText("", null, _linkTextFormat);
			_questionLink.visible = false;
//			_questionLink.setEnabled(false);
			_questionLink.setClickable(false);
			addChild(_questionLink);
		}
		
		protected var _linkTextFormat:TextFormat;
		
		protected function onModulesListClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULES_LIST_SELECTED, null));
			
		}
		
		protected function onModuleClicked(evt:Event):void {
			if (_module!=null) dispatchEvent(new MenuEvent(BreadcrumbsBar.MODULE_SELECTED, _module));
		}

		
		protected var _module:Module;
		protected var _question:Question;
		
		public function setState(module:Module=null, question:Question=null):void {
			
			//trace("breadcrumbs set state: "+(module==null ? "(null)" : module.name)+", "+(question==null ? "(null)" : question.name));
			
			_module = module;
			_question = question;
			
			_modulesListLink.visible = true;
			
			if (module!=null) {
//				_modulesListLink.setEnabled(true);
				_modulesListLink.setClickable(true);
				
				_moduleLink.setText(module.name);
				_moduleLink.visible = true;
				
				if (question!=null) {
					_questionLink.setText(_question.name);
					_questionLink.visible = true;
					
//					_moduleLink.setEnabled(true);
					_moduleLink.setClickable(true);
				}
				else {
					_questionLink.visible = false;
					
//					_moduleLink.setEnabled(false);
					_moduleLink.setClickable(false);
				}
				
				
			}
			else {
//				_modulesListLink.setEnabled(false);
				_modulesListLink.setClickable(false);
				_moduleLink.visible = false;
				_questionLink.visible = false;
			}
			
			
			var margin:Number = 20;
			_modulesListLink.x = margin;
			_moduleLink.x = _modulesListLink.x + _modulesListLink.width + margin;
			_questionLink.x = _moduleLink.x + _moduleLink.width + margin;
		}		
		
		
	}	
}

