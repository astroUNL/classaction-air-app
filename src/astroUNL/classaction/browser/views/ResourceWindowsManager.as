

package astroUNL.classaction.browser.views {
	

	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.views.ResourceWindow;
	
	import flash.utils.Dictionary;
	
	import flash.events.Event;


	public class ResourceWindowsManager {
		
		protected static var _windows:Dictionary = new Dictionary();
		
		public function ResourceWindowsManager() {
			trace("ResourceWindowsManager not meant to be instantiated");
		}
		
		public static function closeAll():void {
			for (var key:Object in _windows) {
				var window:ResourceWindow = _windows[key];
				if (!window.closed) {
					window.close();
					trace("will close a resource window");
				}
			}
		}
		
		public static function open(item:ResourceItem):void {
			trace("Call to open for " + item);
			
			var window:ResourceWindow = _windows[item];
			trace("Will trace window");
			
			if (window==null) {
				trace("No window.");
				_createWindowForItem(item);
				
			} else {
				trace("Window!");
				if (window.closed) {
					trace("...but closed");
					_createWindowForItem(item);
					
				} else {
					trace("...order to front");
					window.orderToFront();
				}
			}
			
		}
		
		protected static function _createWindowForItem(item:ResourceItem):void {
			var window:ResourceWindow = new ResourceWindow(item);
			_windows[item] = window;
			window.addEventListener(Event.CLOSING, _onWindowClosing);
		}
		
		protected static function _onWindowClosing(evt:Event):void {
			trace("A resource window is closing.");
			
			for (var key:Object in _windows) {
				if (_windows[key] == evt.target) {
					trace("found the window in list, will remove");
					delete _windows[key];
					break;
				}
			}
			
		}
		
		
	}
	
}

