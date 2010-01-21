
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	public class ProgressIndicator extends Sprite {
		
		protected var _timer:Timer;
		
		protected var _cyclicPattern:CyclicProgressPattern;
		
		public function ProgressIndicator() {
			
			_cyclicPattern = new CyclicProgressPattern();
			addChild(_cyclicPattern);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		protected var _defaultFadeInTime:Number = 500;
		protected var _defaultFadeOutTime:Number = 500;
		
		protected var _fadeStartTimer:Number;
		protected var _fadeStartAlpha:Number;
		protected var _fadeTime:Number;
		protected var _fadingIn:Boolean;
		
		
		
		public function fadeIn(time:Number=Number.NaN):void {
			if (isNaN(time)) time = _defaultFadeInTime;
			
			_fadeStartAlpha = _cyclicPattern.alpha;
			_fadeStartTimer = getTimer();
			_fadeTime = time;
			_fadingIn = true;
			
			if (!_timer.running) _timer.start();
		}
		
		public function fadeOut(time:Number=Number.NaN):void {
			if (isNaN(time)) time = _defaultFadeOutTime;
			
			
			if (time==0) {
				if (_timer.running) _timer.stop();
				_cyclicPattern.alpha = 0;
			}
			else {				
				_fadeStartAlpha = _cyclicPattern.alpha;
				_fadeStartTimer = getTimer();
				_fadeTime = time;
				_fadingIn = false;
				
				if (!_timer.running) _timer.start();
			}
		}		
		
		public function getFadeLevel():Number {
			return _cyclicPattern.alpha;
		}
				
		public function stop():void {
			fadeOut(0);
		}
		
		protected function onTimer(evt:TimerEvent):void {
			
			var u:Number = (getTimer() - _fadeStartTimer)/_fadeTime;
			
			if (u>1) {
				u = 1;
				_timer.stop();
			}
			else if (u<0) u = 0;
			
			_cyclicPattern.alpha = (_fadingIn) ? _fadeStartAlpha*(1-u) + u : _fadeStartAlpha*(1-u);
		}
		
	}
	
}
