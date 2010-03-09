
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	
	public class PopupManager extends Sprite {
				
		var _bounds:Rectangle;
		var _popups:Vector.<PopupWindow>;
		
		public function PopupManager() {
			_popups = new Vector.<PopupWindow>();
		}
		
		public function addPopup(popup:PopupWindow):void {
			addChild(popup);
			_popups.push(popup);
			popup.manager = this;
			popup.keepInBounds();
		}
		
		public function get bounds():Rectangle {
			return _bounds;
		}
		
		public function set bounds(b:Rectangle):void {
			_bounds = b;
			for each (var popup:PopupWindow in _popups) popup.keepInBounds();			
		}
	}
	
}
