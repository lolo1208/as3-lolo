package game.ui
{
	import flash.display.Shape;
	import flash.events.Event;
	
	import lolo.components.Label;
	import lolo.components.ModalBackground;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.LoadItemModel;
	import lolo.display.BitmapSprite;
	import lolo.display.Container;
	import lolo.events.LoadEvent;
	import lolo.ui.ILoadBar;

	/**
	 * 加载条
	 * @author LOLO
	 */
	public class LoadBar extends Container implements ILoadBar
	{
		/**模态背景*/
		public var modalBG:ModalBackground;
		/**加载条背景*/
		public var bg:BitmapSprite;
		/**进度条*/
		public var progressBar:BitmapSprite;
		/**进度显示文本*/
		public var progressText:Label;
		
		/**是否自动显示或隐藏*/
		private var _autoShow:Boolean = true;
		/**当前进度*/
		private var _progress:Number = 1;
		
		
		public function LoadBar()
		{
			super();
			
			initUI(new XML(Common.loader.getResByConfigName("mainUIConfig").loadBar));
			
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0);
			mask.graphics.drawRect(0, 0, progressBar.width, progressBar.height);
			mask.graphics.endFill();
			mask.x = progressBar.x;
			mask.y = progressBar.y;
			progressBar.mask = mask;
			this.addChild(mask);
			
			isListener = true;
		}
		
		public function set isListener(value:Boolean):void
		{
			if(value) {
				Common.loader.addEventListener(LoadEvent.START, loadEventHandler);
				Common.loader.addEventListener(LoadEvent.PROGRESS, loadEventHandler);
				Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loadEventHandler);
				Common.loader.addEventListener(LoadEvent.ALL_COMPLETE, loadEventHandler);
				Common.loader.addEventListener(LoadEvent.ERROR, loadEventHandler);
			}
			else {
				Common.loader.removeEventListener(LoadEvent.START, loadEventHandler);
				Common.loader.removeEventListener(LoadEvent.PROGRESS, loadEventHandler);
				Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loadEventHandler);
				Common.loader.removeEventListener(LoadEvent.ALL_COMPLETE, loadEventHandler);
				Common.loader.removeEventListener(LoadEvent.ERROR, loadEventHandler);
			}
		}
		
		public function get isListener():Boolean { return hasEventListener(Event.ENTER_FRAME); }
		
		
		
		public function set autoShow(value:Boolean):void
		{
			_autoShow = value;
		}
		
		public function get autoShow():Boolean { return _autoShow; }
		
		
		
		public function set text(value:String):void
		{
			progressText.text = value;
		}
		
		public function get text():String { return progressText.text; }
		
		
		
		public function set progress(value:Number):void
		{
			_progress = value;
			progressBar.mask.scaleX = value;
		}
		
		public function get progress():Number { return _progress; }
		
		
		
		public function set modalTransparency(value:Number):void
		{
			modalBG.alpha = value;
		}
		
		public function get modalTransparency():Number { return modalBG.alpha; }
		
		
		
		
		/**
		 * 加载相关的事件处理
		 * @param event
		 */
		private function loadEventHandler(event:LoadEvent):void
		{
			var lim:LoadItemModel = event.lim;
			if(event.type != LoadEvent.COMPLETE && event.type != LoadEvent.ALL_COMPLETE && _autoShow) {
				if(_showed && Common.loader.isSecretly) setShow(false);
				else if(!_showed && !event.lim.isSecretly) setShow(true);
			}
			
			if(parent == null) return;
			
			switch(event.type)
			{
				case LoadEvent.START:
					progress = 0;
					text = Common.language.getLanguage("010201", lim.name);
					break;
				
				case LoadEvent.PROGRESS:
					progress = lim.bytesLoaded / lim.bytesTotal;
					text = Common.language.getLanguage("010202", lim.name, int(_progress * 100), Common.loader.numCurrent, Common.loader.numTotal);
					break;
				
				case LoadEvent.ITEM_COMPLETE:
					text = Common.language.getLanguage("010203", lim.name);
					break;
				
				case LoadEvent.COMPLETE: case LoadEvent.ALL_COMPLETE:
					if(_showed && _autoShow && Common.loader.isSecretly) setShow(false);
					return;
				
				case LoadEvent.ERROR: case LoadEvent.TIMEOUT:
					text = Common.language.getLanguage("010204", lim.name);
					break;
			}
		}
		
		/**
		 * 设置是否显示
		 * @param value
		 */
		private function setShow(value:Boolean):void
		{
			if(value) {
				Common.ui.addChildToLayer(this, Constants.LAYER_NAME_TOP);
			}
			else {
				Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_TOP);
			}
		}
		
		
		
		override public function get width():Number { return bg.width; }
		override public function get height():Number { return bg.height; }
		//
	}
}