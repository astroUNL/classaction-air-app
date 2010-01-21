
package astroUNL.classaction.browser.resources {
	
//	import astroUNL.classaction.browser.download.IDownloadable;
//	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.utils.logger.Logger;
	
	import flash.events.Event;
	
//	import flash.net.URLLoaderDataFormat;
//	import flash.utils.ByteArray;
	
	// implements IDownloadable 
	public class Question extends ResourceItem {
		
		
		public static const WARM_UP:int = 0;
		public static const GENERAL:int = 1;
		public static const CHALLENGE:int = 2;
		public static const DISCUSSION:int = 3;
		
		public var questionType:int = -1;
		public var relevantAnimationIDsList:Array = [];
		public var relevantImageIDsList:Array = [];
		public var relevantOutlineIDsList:Array = [];
		public var relevantTableIDsList:Array = [];
//		public var swfData:ByteArray;
		
//		protected var _downloadState:int = Downloader.NOT_QUEUED;
//		protected var _downloadPriority:int = 0;
//		protected var _fractionLoaded:Number = 0;
				
		public function Question(itemXML:XML=null) {
			super(ResourceItem.QUESTION, itemXML);
		}
		
		public function addRelevantResource(item:ResourceItem):void {
			
			var list:Array;
			if (item.type==ResourceItem.ANIMATION) list = relevantAnimationIDsList;
			else if (item.type==ResourceItem.IMAGE) list = relevantImageIDsList;
			else if (item.type==ResourceItem.OUTLINE) list = relevantOutlineIDsList;
			else if (item.type==ResourceItem.TABLE) list = relevantTableIDsList;
			else return;

			// check that the item is not already marked as relevant
			var i:int;
			for (i=0; i<list.length; i++) if (list[i]==item.id) return;
			
			list.push(item.id);
			dispatchEvent(new Event(ResourceItem.UPDATE));
			
			trace("addRelevantResource");
		}
		
		public function removeRelevantResource(item:ResourceItem):void {
			
			var list:Array;
			if (item.type==ResourceItem.ANIMATION) list = relevantAnimationIDsList;
			else if (item.type==ResourceItem.IMAGE) list = relevantImageIDsList;
			else if (item.type==ResourceItem.OUTLINE) list = relevantOutlineIDsList;
			else if (item.type==ResourceItem.TABLE) list = relevantTableIDsList;
			else return;
			
			var i:int;
			for (i=0; i<list.length; i++) {
				if (list[i]==item.id) {
					list.splice(i, 1);
					dispatchEvent(new Event(ResourceItem.UPDATE));
					return;
				}
			}			
		}
		
		override public function getXML():XML {
			
			var xml:XML = new XML("<Question></Question>");
			xml.@id = id;
			xml.appendChild(new XML("<Name>"+name+"</Name>"));
			xml.appendChild(new XML("<Description>"+description+"</Description>"));
			xml.appendChild(new XML("<Keywords></Keywords>"));
			xml.appendChild(new XML("<Type>"+questionType+"</Type>"));
			xml.appendChild(new XML("<File>"+filename+"</File>"));
			xml.appendChild(new XML("<Width>"+width+"</Width>"));
			xml.appendChild(new XML("<Height>"+height+"</Height>"));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.ANIMATION));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.IMAGE));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.OUTLINE));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.TABLE));
			
			return xml;
		}
		
		protected function getRelevantResourcesXML(type:String):XML {
			
			var xml:XML;
			var list:Array;
			var opening:String, closing:String;
			if (type==ResourceItem.ANIMATION) {
				xml = new XML("<RelevantAnimations></RelevantAnimations>");
				opening = "<RelevantAnimation>";
				closing = "</RelevantAnimation>";
				list = relevantAnimationIDsList;
			}
			else if (type==ResourceItem.IMAGE) {
				xml = new XML("<RelevantImages></RelevantImages>");
				opening = "<RelevantImage>";
				closing = "</RelevantImage>";
				list = relevantImageIDsList;
			}
			else if (type==ResourceItem.OUTLINE) {
				xml = new XML("<RelevantOutlines></RelevantOutlines>");
				opening = "<RelevantOutline>";
				closing = "</RelevantOutline>";
				list = relevantOutlineIDsList;
			}
			else if (type==ResourceItem.TABLE) {
				xml = new XML("<RelevantTables></RelevantTables>");
				opening = "<RelevantTable>";
				closing = "</RelevantTable>";
				list = relevantTableIDsList;
			}
			else return new XML();
			
			var i:int;
			for (i=0; i<list.length; i++) xml.appendChild(new XML(opening+list[i]+closing));
			
			return xml;
		}
		
		
		override public function setXML(itemXML:XML):void {
			if (itemXML!=null) {
				super.setXML(itemXML);
				
				questionType = itemXML.Type;
				
				if (questionType!=Question.WARM_UP && questionType!=Question.GENERAL && questionType!=Question.CHALLENGE && questionType!=Question.DISCUSSION) {
					Logger.report("question " + id + " does not have a valid type");
				}
				
				var relevant:XML;
				
				for each (relevant in itemXML.RelevantAnimations.elements()) {
					relevantAnimationIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantImages.elements()) {
					relevantImageIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantTables.elements()) {
					relevantTableIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantOutlines.elements()) {
					relevantOutlineIDsList.push(relevant.toString());
				}				
				
			}
		}		
		
//		public function get downloadURL():String {
//			return filename;			
//		}
//		
//		public function get downloadFormat():String {
//			return URLLoaderDataFormat.BINARY;			
//		}
//				
//		public function set downloadPriority(arg:int):void {
//			_downloadPriority = arg;
//		}
//		
//		public function get downloadPriority():int {
//			return _downloadPriority;
//		}
//		
//		public function get downloadState():int {
//			return _downloadState;			
//		}
//		
//		public function get downloadNoCache():Boolean {
//			return false;
//		}
//		
//		public function get fractionLoaded():Number {
//			return _fractionLoaded;
//		}		
//		
//		public function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void {
//			_fractionLoaded = bytesLoaded/bytesTotal;			
//		}
//		
//		public function onDownloadStateChanged(state:int, data:*=null):void {
//			_downloadState = state;
//			if (_downloadState==Downloader.DONE_SUCCESS) {
//				_fractionLoaded = 1;
//				swfData = data;
//			}
//		}		
		
	}	
}

