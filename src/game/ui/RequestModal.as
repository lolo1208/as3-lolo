package game.ui
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	
	import lolo.components.ModalBackground;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.RequestModel;
	import lolo.display.Animation;
	import lolo.display.BitmapSprite;
	import lolo.ui.IRequestModal;
	import lolo.utils.AutoUtil;
	import lolo.utils.FrameTimer;
	import lolo.utils.TimeUtil;
	
	/**
	 * 与服务端通信时，模态的提示界面
	 * @author LOLO
	 */
	public class RequestModal extends Sprite implements IRequestModal
	{
		/**请求无响应，该时间后显示加载中界面（毫秒）*/
		private static const DELAY_LOADING:int = 3000;
		/**请求无响应，该时间后显示加载失败界面（毫秒）*/
		private static const DELAY_TIMEOUT:int = 9000;
		
		/**模态背景*/
		public var modalBG:ModalBackground;
		/**背景*/
		public var bg:BitmapSprite;
		/**加载中动画*/
		public var loadingAni:Animation;
		/**加载中提示文字*/
		public var loadingText:BitmapSprite;
		/**加载超时提示文字*/
		public var timeoutText:BitmapSprite;
		
		/**模态背景透明度{ normal, deep }*/
		public var modalTransparency:Object;
		
		/**当前正在通信的接口列表*/
		private var _list:Array;
		/**用于定时检查通信状态*/
		private var _timer:FrameTimer;
		
		
		
		public function RequestModal()
		{
			super();
			AutoUtil.autoUI(this, new XML(Common.loader.getResByConfigName("mainUIConfig").requestModal));
			_timer = new FrameTimer(1000, timerHandler);
			_list = [];
		}
		
		
		public function startModal(rm:RequestModel):void
		{
			//如果当前正在通信的接口列表中有该接口，不必继续执行
			for each(var item:Object in _list) if(item.rm == rm) return;
			_list.push({ rm:rm, time:TimeUtil.getTime() });
			
			//没有正在请求的接口
			if(!_timer.running)
			{
				TweenMax.killTweensOf(this);
				_timer.start();
				this.alpha = 1;
				Common.ui.addChildToLayer(this, Constants.LAYER_NAME_TOP);
			}
			timerHandler();
		}
		
		
		public function endModal(rm:RequestModel):void
		{
			for(var i:int = 0; i < _list.length; i++)
			{
				if(_list[i].rm == rm) _list.splice(i, 1);
			}
			
			if(_list.length == 0 && _timer.running) reset();
		}
		
		
		
		/**
		 * 定时检查通信状态
		 */
		private function timerHandler():void
		{
			if(_list.length == 0) {
				reset();
				return;
			}
			var time:int = TimeUtil.getTime() - _list[0].time;
			
			//该出现Loding了
			if(time >= DELAY_LOADING)
			{
				bg.visible = true;
				modalBG.alpha = modalTransparency.deep;
				
				loadingText.visible = loadingAni.visible = time < DELAY_TIMEOUT;
				loadingAni.playing = loadingText.visible;
				
				timeoutText.visible = !loadingText.visible;
				
				//通信超时
				if(time >= DELAY_TIMEOUT)
				{
					_timer.reset();
					TweenMax.to(this, 0.5, { alpha:0, delay:1.5, onComplete:reset });
					
					//将正在通信的请求，全部设置为超时
					for each(var item:Object in _list) Common.service.setTimeout(item.rm);
					_list = [];
				}
			}
			else {
				modalBG.alpha = modalTransparency.normal;
				
				loadingText.visible = loadingAni.visible = timeoutText.visible = bg.visible = false;
				loadingAni.stop();
			}
		}
		
		
		
		override public function get width():Number { return bg.width; }
		override public function get height():Number { return bg.height; }
		
		
		
		/**
		 * 重置所有模态的通信
		 */
		public function reset():void
		{
			TweenMax.killTweensOf(this);
			loadingAni.stop();
			_timer.reset();
			_list = [];
			
			Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_TOP);
		}
		//
	}
}