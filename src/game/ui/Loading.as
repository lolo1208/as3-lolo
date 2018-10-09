package game.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import lolo.core.Common;
	import lolo.events.LoadEvent;

	/**
	 * 游戏开始时的加载条
	 * @author LOLO
	 */
	public class Loading extends Sprite
	{
		/**加载条*/
		private var _bar:MovieClip;
		
		/**目标帧（当前已加载百分比）*/
		private var _targetFarme:int;
		
		
		public function Loading(bar:MovieClip)
		{
			super();
			_bar = bar;
			_bar.gotoAndStop(1);
			this.addChild(_bar);
		}
		
		
		
		/**
		 * 开始侦听
		 */
		public function start():void
		{
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, completeHandler);
			Common.loader.addEventListener(LoadEvent.PROGRESS, progressHandler);
			Common.loader.addEventListener(LoadEvent.ERROR, errorHandler);
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		/**
		 * 销毁
		 */
		public function dispose():void
		{
			Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, completeHandler);
			Common.loader.removeEventListener(LoadEvent.PROGRESS, progressHandler);
			Common.loader.removeEventListener(LoadEvent.ERROR, errorHandler);
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		/**
		 * 资源加载中
		 * @param event
		 */
		private function progressHandler(event:LoadEvent):void
		{
			var progress:Number = (event.lim.bytesLoaded / event.lim.bytesTotal + Common.loader.numCurrent) / Common.loader.numTotal;
			this.progress = progress;
			
			if(event.lim.name == "") {
				this.text = "Loading...   " + Common.loader.numCurrent + "/" + Common.loader.numTotal;
			}
			else {
				this.text = Common.language.getLanguage(
					"010101", event.lim.name,
					int(progress * 100),
					Common.loader.numCurrent, Common.loader.numTotal
				);
			}
		}
		
		/**
		 * 加载单个资源完成
		 * @param event
		 */
		private function completeHandler(event:LoadEvent):void
		{
			if(event.lim.name == "") {
				this.text = "Loading...   " + Common.loader.numCurrent + "/" + Common.loader.numTotal;
			}
			else {
				this.text = Common.language.getLanguage("010103", event.lim.name);
			}
		}
		
		/**
		 * 加载所有资源完成
		 * @param event
		 */
		private function allCompleteHandler(event:LoadEvent):void
		{
			this.progress = 1;
			this.text = Common.language.getLanguage("010104");
		}
		
		/**
		 * 加载资源失败
		 * @param event
		 */
		private function errorHandler(event:LoadEvent):void
		{
			this.progress = 1;
			this.text = Common.language.getLanguage("010105", event.lim.name);
		}
		
		
		
		/**
		 * 帧刷新
		 * @param event
		 */
		private function enterFrameHandler(event:Event):void
		{
			//需要继续播放loading动画
			if(_targetFarme > _bar.currentFrame) {
				_bar.nextFrame();
			}
			//loading进度播放完毕
			else if(_targetFarme < _bar.currentFrame) {
				_bar.gotoAndStop(_targetFarme);
			}
		}
		
		
		private function set text(value:String):void
		{
			_bar["progressText"].text = value;
		}
		
		private function set progress(value:Number):void
		{
			_targetFarme = value * 100;
		}
		//
	}
}