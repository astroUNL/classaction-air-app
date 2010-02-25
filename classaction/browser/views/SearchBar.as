
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.QuestionsBank;
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	public class SearchBar extends Sprite {
		
		public function SearchBar() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(evt:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc);
		}
		
		protected function findHits(pattern:RegExp, lookup:Object, hits:Array):void {
			var score:int;
			var matches:Array = [];
			for each (var item:ResourceItem in lookup) { 
				score = 0;
				matches = item.name.match(pattern);
				if (matches!=null) score += matches.length;
				matches = item.description.match(pattern);
				if (matches!=null) score += matches.length;
				for each (var keyword:String in item.keywords) {
					matches = keyword.match(pattern);
					if (matches!=null) score += matches.length;
				}
				if (score>0) hits.push({item: item, score: score});
			}
		}					
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) {
				trace("do search for "+searchField.text);
				var startTimer:Number = getTimer();
				
				var pattern:RegExp = new RegExp(searchField.text, "i");
				var hits:Array = [];
				
				findHits(pattern, QuestionsBank.lookup, hits);
				findHits(pattern, AnimationsBank.lookup, hits);
				findHits(pattern, ImagesBank.lookup, hits);
				findHits(pattern, OutlinesBank.lookup, hits);
				findHits(pattern, TablesBank.lookup, hits);
				
//				for each (var question:Question in QuestionsBank.lookup) { 
//					matches = question.name.match(pattern);
//					if (matches!=null) score += matches.length;
//					matches = question.description.match(pattern);
//					if (matches!=null) score += matches.length;
//					for each (var keyword:String in item
//					matches = question.name.match(pattern);
//					if (matches!=null) score += matches.length;
//					
//					if (matches!=null && matches.length>0) hits.push({item: question, score: matches.length});
//				}

				hits.sortOn("score", Array.DESCENDING | Array.NUMERIC);
				
				trace("search time: "+(getTimer()-startTimer));
				trace("search hits:");
				
				for (var i:int = 0; i<hits.length; i++) {
					trace(" "+hits[i].score+": "+hits[i].item.name+" ("+hits[i].item.type+")");
				}				
			}
		}
		
	}
}

