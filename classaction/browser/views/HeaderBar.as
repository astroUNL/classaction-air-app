
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.views.elements.DropDownMenu;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HeaderBar extends Sprite {
		
		public static const SEARCH:String = "Search";
		public static const ABOUT:String = "About";
		
		protected var _logoMenu:DropDownMenu;
		protected var _menusMask:Shape;
		
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _dropLimit:Number = 1600;
		
		protected var _logoMenuWidth:Number = 80;
		
	// eventually, width will have to be dynamically settable
		
		public function HeaderBar(width:Number) {
			
			_width = 800; // width
			_height = 29;
			
			_menusMask = new Shape();
			addChild(_menusMask);
			
			_logoMenuWidth = logo.width;
			
			_logoMenu = new DropDownMenu(_logoMenuWidth);
			_logoMenu.addSelection(HeaderBar.SEARCH);
			_logoMenu.addSelection(HeaderBar.ABOUT);
			_logoMenu.x = logo.x;
			_logoMenu.y = _height;
			_logoMenu.addEventListener(Event.SELECT, onLogoMenuSelection);
			addChild(_logoMenu);
			
			_logoMenu.mask = _menusMask;
			
			logo.buttonMode = true;
			logo.addEventListener(MouseEvent.CLICK, onLogoClicked);
			
			redrawMask();
		}
		
		public function get selection():String {
			return _logoMenu.selection;
		}
		
		protected function onLogoMenuSelection(evt:Event):void {
			dispatchEvent(new Event(Event.SELECT));				
			_logoMenu.close();
		}
		
		protected function onLogoClicked(evt:MouseEvent):void {
			_logoMenu.isOpen = !_logoMenu.isOpen;
		}
		
		protected function redrawMask():void {
			_menusMask.graphics.clear();
			_menusMask.graphics.beginFill(0xffff80);
			_menusMask.graphics.drawRect(0, _height, _width, _dropLimit);
			_menusMask.graphics.endFill();
		}
		
		override public function get height():Number {
			return _height;			
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _width;			
		}
		
		override public function set width(arg:Number):void {
			//
		}
		
	}	
}
