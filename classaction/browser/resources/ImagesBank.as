
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.Downloader;
	
	public class ImagesBank {
	
		public static var lookup:Object = {};
		public static var downloadState:int = Downloader.NOT_QUEUED;
		public static var total:uint = 0;
		public static var loaded:Boolean = false;
		
	}
	
}