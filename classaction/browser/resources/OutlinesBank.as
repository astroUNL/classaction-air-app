
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.Downloader;
	
	public class OutlinesBank {
	
		public static var lookup:Object = {};
		public static var downloadState:int = Downloader.NOT_QUEUED;
		public static var total:uint = 0;
		public static var loaded:Boolean = false;
		
		public static function add(resource:ResourceItem):void {
			lookup[resource.id] = resource;
			total++;
		}		
		
	}	
}
