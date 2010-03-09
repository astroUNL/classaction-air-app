
package astroUNL.classaction.browser.views {
	
	
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.QuestionsBank;
//	import astroUNL.classaction.browser.resources.AnimationsBank;
//	import astroUNL.classaction.browser.resources.ImagesBank;
//	import astroUNL.classaction.browser.resources.OutlinesBank;
//	import astroUNL.classaction.browser.resources.TablesBank;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	import astroUNL.utils.easing.CubicEaser;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	
	
	public class SearchPanel extends Sprite {
		
		public static const QUESTION_SELECTED:String = "questionSelected";
		
		protected var _expandTime:Number = 200;
				
		protected var _hitPool:Vector.<ClickableText>;
		protected var _hitFormat:TextFormat;
		protected var _hitParams:Object;
		
		protected var _heightEaser:CubicEaser;
		protected var _heightTimer:Timer;
		
		protected var _margin:Number = 12;
		protected var _bottomMargin:Number = 20;
		protected var _panesMargin:Number = 1.5*_margin;
		
		protected var _panelHeightMin:Number = 40;
//		protected var _panelHeightMax:Number = 250;
		protected var _panelWidth:Number = 290;
		protected var _panelHeight:Number;
		
		protected var _messageY:Number = 40;
		
		protected var _panes:ScrollableLayoutPanes;
		protected var _panesWidth:Number =_panelWidth - 2*_panesMargin;
		protected var _panesHeightLimit:Number = 140;
		
		protected var _background:Shape;
		protected var _maskedContent:Sprite;
		protected var _mask:Shape;
		protected var _message:TextField;
		
		protected var _searchFieldBackground:Shape;
		protected var _searchFieldBackgroundColor:uint = 0x0C0E0E;//1c2020;
		protected var _searchFieldBorderColor:uint = 0x303635;
		
		protected var _backgroundColor:uint = 0x272D2E;
		
		public function SearchPanel() {
			
			_background = new Shape();
			addChild(_background);
			
			_searchFieldBackground = new Shape();
			addChild(_searchFieldBackground);
			
			_searchFieldBackground.graphics.beginFill(_searchFieldBackgroundColor);
			_searchFieldBackground.graphics.lineStyle(1, _searchFieldBorderColor);
			_searchFieldBackground.graphics.drawRect(searchField.x-2, searchField.y-2, searchField.width+4, searchField.height+4);
			_searchFieldBackground.graphics.endFill();
			
			_panelHeight = _panelHeightMin;
			
			_heightEaser = new CubicEaser(_panelHeight);
			
			_heightTimer = new Timer(20);
			_heightTimer.addEventListener(TimerEvent.TIMER, onHeightTimer);
			
			_maskedContent = new Sprite();
			addChild(_maskedContent);
			
			_message = new TextField();
			_message.autoSize = "left";
			_message.wordWrap = true;
			_message.width = _panesWidth;
			_message.embedFonts = true;
			_message.selectable = false;
			_message.x = _margin;
			_message.y = _messageY;
			_message.defaultTextFormat = new TextFormat("Verdana", 12, 0xffffff, false, true);
			addChild(_message);
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeightLimit, 0, 5, {topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, columnSpacing: 0, numColumns: 1});
			_panes.x = _panesMargin;
			_maskedContent.addChild(_panes);
			
			_mask = new Shape();
			addChild(_mask);
			
			setChildIndex(searchField, numChildren-1);
			setChildIndex(searchButton, numChildren-1);
			
			_maskedContent.mask = _mask;
			
			_hitPool = new Vector.<ClickableText>();
			_hitParams = {};
			_hitFormat = new TextFormat("Verdana", 13, 0xffffff);
			
			
			
			
			searchButton.addEventListener(MouseEvent.CLICK, doSearch);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			redraw();
		}
		
		protected function onHeightTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			if (timeNow>_heightEaser.targetTime) {
				_panelHeight = _heightEaser.targetValue;
				_heightEaser.init(_panelHeight);		
				_heightTimer.stop();
			}
			else {
				_panelHeight = _heightEaser.getValue(timeNow);				
			}
			dispatchEvent(new Event(Event.RESIZE));
			redraw();
		}
		
		protected function redraw():void {
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor);
			_background.graphics.drawRect(0, 0, _panelWidth, _panelHeight);
			_background.graphics.endFill();
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0, 0, _panelWidth, _panelHeight);
			_mask.graphics.endFill();
		}
		
		protected function onAddedToStage(evt:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc);
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) doSearch();
		}
		
		protected function addLink(item:ResourceItem, num:int):void {
			var hit:ClickableText;
			var i:int;
			for (i=0; i<_hitPool.length; i++) {
				if (_hitPool[i].alpha==0) {
					hit = _hitPool[i];
					break;					
				}
			}			
			if (hit==null) {
				hit = new ClickableText("", null, _hitFormat, _panesWidth);
				hit.addEventListener(ClickableText.ON_CLICK, onHitClicked);
				_hitPool.push(hit);
			}
			hit.alpha = 1;
			if (num<10) hit.setText(" "+String(num)+". "+item.name);
			else hit.setText(String(num)+". "+item.name);
			hit.data = item;
			trace("height: "+hit.height);
			_panes.addContent(hit, _hitParams);
		}
		
		protected function clearLinks():void {
			_selectedModule = null;
			_selectedQuestion = null;
			for each (var hit:ClickableText in _hitPool) hit.alpha = 0;
			_panes.reset();
		}
		
		protected function onHitClicked(evt:Event):void {
			var item:ResourceItem = (evt.target as ClickableText).data;
			if (item==null) {
				trace("WARNING,invalid item in search panel");
				_selectedModule = null;
				_selectedQuestion = null;
			}
			else if (item.type==ResourceItem.QUESTION) {
				trace("item clicked: "+item.name);
				if (item.modulesList.length>0) {
					_selectedModule = item.modulesList[0];
					_selectedQuestion = item as Question;
					dispatchEvent(new Event(SearchPanel.QUESTION_SELECTED));
				}
			}
			else {
				trace("WARNING, unrecognized type in search panel");
				_selectedModule = null;
				_selectedQuestion = null;
			}
		}
		
		protected var _selectedModule:Module;
		protected var _selectedQuestion:Question;
		
		public function get selectedModule():Module {
			return _selectedModule;			
		}
		
		public function get selectedQuestion():Question {
			return _selectedQuestion;		
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
				
		protected function doSearch(evt:Event=null):void {
			
			var pattern:RegExp = new RegExp(searchField.text, "i")
			
			clearLinks();
			var hits:Array = [];				
			findHits(pattern, QuestionsBank.lookup, hits);
			//findHits(pattern, AnimationsBank.lookup, hits);
			//findHits(pattern, ImagesBank.lookup, hits);
			//findHits(pattern, OutlinesBank.lookup, hits);
			//findHits(pattern, TablesBank.lookup, hits);				
			hits.sortOn("score", Array.DESCENDING | Array.NUMERIC);
			
			var hitsAdded:int = 0;
			
			for (var i:int = 0; i<hits.length; i++) {
				if (hits[i].item.type==ResourceItem.QUESTION && hits[i].item.modulesList.length>0) {
					addLink(hits[i].item, i+1);
					hitsAdded++;
				}
			}			
						
			_message.text = "";
			_message.height = 0;
			if (hitsAdded>0) _message.text = "results for \"" + searchField.text + "\":";
			else _message.text = "nothing found for \"" + searchField.text + "\"";
			
			_panes.y = _message.y + 3 + _message.height;
						
			var timeNow:Number = getTimer();
			
			var targetHeight:Number;
			
			if (hitsAdded==0) targetHeight = _panes.y + _margin;
			else if (_panes.numPanes<=1) targetHeight = _panes.y + _panes.cursorY + _margin;
			else targetHeight = _panes.y + _panesHeightLimit + _margin;
			
			_heightEaser.setTarget(timeNow, _panelHeight, timeNow+_expandTime, targetHeight);
			
			_heightTimer.start();
		}
		
		
		
		
		override public function set width(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _panelWidth;
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get height():Number {
			return _panelHeight;
		}
		
	}
}

