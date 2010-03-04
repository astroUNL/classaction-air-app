
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.QuestionsBank;
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.text.TextFormat;
	
	
	public class SearchBar extends Sprite {
				
		protected var _hitFormat:TextFormat;
		
		protected var _hits:Sprite;
		protected var _hitsPool:Vector.<ClickableText>;
		protected var _hitWidth:Number = 300;
		
		protected var _hitPanes:ScrollableLayoutPanes;
		
		public function SearchBar() {
			
			_hitPanes = new ScrollableLayoutPanes(300, 400, 0, 5, {topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, columnSpacing: 0, numColumns: 1});
			addChild(_hitPanes);
			
			_hits = new Sprite();
			addChild(_hits);
			
			_hitsPool = new Vector.<ClickableText>();
			_hitFormat = new TextFormat("Trebuchet MS", 13, 0x000000);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function clearHits():void {
			for (var i:int = 0; i<_hitsPool.length; i++) _hitsPool[i].visible = false;
			_hitPanes.reset();
		}
		
		protected function getHit(item:ResourceItem):ClickableText {
			var hit:ClickableText;
						
			var i:int;
			for (i=0; i<_hitsPool.length; i++) {
				
				
				_hitsPool[i].visible
				
			}
			if (i>=_hitsPool.length) {
				hit = new ClickableText(item.name, null, _hitFormat, _hitWidth);
			
			}
			
			
			
//			var hit:ClickableText;
//			if (_hitsPool.length>0) {
//				hit = _hitsPool.pop();
//				hit.name = item.name;
//			}
//			else hit = new ClickableText(item.name, null, _hits, _hitsWidth);
//			_hits.addChild(hit);

			return hit;
		}
		
//		protected function removeAllLinks():void {
//			while (_hits.numChildren>0) _hitsPool.push(_hits.removeChildAt(0));
//		}
		
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
		
		
		
		protected function doSearch(pattern:RegExp):void {
			var startTimer:Number = getTimer();
			var hits:Array = [];				
			findHits(pattern, QuestionsBank.lookup, hits);
			findHits(pattern, AnimationsBank.lookup, hits);
			findHits(pattern, ImagesBank.lookup, hits);
			findHits(pattern, OutlinesBank.lookup, hits);
			findHits(pattern, TablesBank.lookup, hits);				
			hits.sortOn("score", Array.DESCENDING | Array.NUMERIC);
			trace(" search time: "+(getTimer()-startTimer));
			trace(" search hits:");				
			for (var i:int = 0; i<hits.length; i++) {
				trace("  "+hits[i].score+": "+hits[i].item.name+" ("+hits[i].item.type+")");
			}			
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) {
				doSearch(new RegExp(searchField.text, "i"));
			}
		}
		
	}
}

