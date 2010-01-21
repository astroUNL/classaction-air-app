package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	
	
	import flash.events.EventDispatcher;
	
	import flash.utils.ByteArray;
	import flash.net.URLLoaderDataFormat;
	
	
	
	public class ResourceItem extends EventDispatcher implements IDownloadable {
				
		public static const UPDATE:String = "update";
		
		public static const QUESTION:String = "question";
		public static const ANIMATION:String = "animation";
		public static const IMAGE:String = "image";
		public static const TABLE:String = "table";
		public static const OUTLINE:String = "outline";
		
		public var thumb:BinaryFile;
		
		public var id:String;
		public var name:String;
		public var description:String;
		public var filename:String;
		public var width:Number;
		public var height:Number;
		public var modulesList:Array = []; // the list of modules this resource is associated with
		public var type:String;
		public var data:ByteArray;
		
		
		public function ResourceItem(type:String, itemXML:XML=null) {
			this.type = type;
			setXML(itemXML);
		}
		
		public function setXML(itemXML:XML):void {
			if (itemXML!=null) {
				id = itemXML.attribute("id").toString();
				name = itemXML.Name;
				description = itemXML.Description;
				filename = itemXML.File;
				width = itemXML.Width;
				height = itemXML.Height;
			}			
		}
		
		public function getXML():XML {
			
			var typeCapped:String = type.charAt(0).toUpperCase() + type.slice(1);
			
			var xml:XML = new XML("<"+typeCapped+"></"+typeCapped+">");
			xml.@id = id;
			xml.appendChild(new XML("<Name>"+name+"</Name>"));
			xml.appendChild(new XML("<Description>"+description+"</Description>"));
			xml.appendChild(new XML("<Keywords></Keywords>"));
			xml.appendChild(new XML("<File>"+filename+"</File>"));
			xml.appendChild(new XML("<Width>"+width+"</Width>"));
			xml.appendChild(new XML("<Height>"+height+"</Height>"));
			
			return xml;
		}
		
		
		
		// the stuff below takes care the IDownloadable requirements
		
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _downloadPriority:int = 0;
		protected var _fractionLoaded:Number = 0;
		
		public function get downloadURL():String {
			return filename;			
		}
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.BINARY;			
		}
		
		public function set downloadPriority(arg:int):void {
			_downloadPriority = arg;
		}
		
		public function get downloadPriority():int {
			return _downloadPriority;
		}
		
		public function get downloadState():int {
			return _downloadState;			
		}
		
		public function get downloadNoCache():Boolean {
			return false;
		}
		
		public function get fractionLoaded():Number {
			return _fractionLoaded;
		}		
		
		public function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void {
			_fractionLoaded = bytesLoaded/bytesTotal;			
		}
		
		public function onDownloadStateChanged(state:int, data:*=null):void {
			_downloadState = state;
			if (_downloadState==Downloader.DONE_SUCCESS) {
				_fractionLoaded = 1;
				this.data = data;
			}
		}				
		
		override public function toString():String {
			if (name==null) return "unnamed (ResourceItem)";
			else return name + " (ResourceItem)";
		}		
	}
}
