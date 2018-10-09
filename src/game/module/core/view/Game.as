package game.module.core.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.ui.ContextMenuItem;
	
	import game.common.GameConstants;
	import game.module.core.controls.CoreController;
	import game.module.core.events.ConsoleEvent;
	
	import lolo.components.Alert;
	import lolo.components.ImageLoader;
	import lolo.core.Common;
	import lolo.core.ConfigManager;
	import lolo.core.LanguageManager;
	import lolo.core.LayoutManager;
	import lolo.core.LoadManager;
	import lolo.core.MouseManager;
	import lolo.core.MovieClipLoader;
	import lolo.core.SoundManager;
	import lolo.data.HashMap;
	import lolo.data.LastTime;
	import lolo.display.Animation;
	import lolo.display.BaseTextField;
	import lolo.display.BitmapMovieClip;
	import lolo.display.BitmapSprite;
	import lolo.display.Scene;
	import lolo.display.Window;
	import lolo.events.ConsoleEvent;
	import lolo.mvc.control.MvcEventDispatcher;
	import lolo.rpg.RpgConstants;
	import lolo.ui.Console;
	import lolo.ui.Stats;
	import lolo.utils.ExternalUtil;
	import lolo.utils.MathUtil;
	import lolo.utils.TimeUtil;
	import lolo.utils.Validator;
	import lolo.utils.bind.BindUtil;
	import lolo.utils.logging.LogEvent;
	import lolo.utils.logging.LogSampler;
	import lolo.utils.logging.Logger;
	
	
	
	/**
	 * 游戏核心
	 * 该类会引入其他模块中常用的类，同时，该类也是其他模块优化的针对程序
	 * @author LOLO
	 */
	public class Game extends flash.display.Sprite
	{
		/**单例的实例*/
		public static var instance:Game;
		
		
		public function Game()
		{
			super();
			if(instance != null) return;
			instance = this;
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			new CoreController();
			
			importClass();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		
		/**
		 * 添加到舞台上时
		 * @param event
		 */
		private function addedToStageHandler(event:Event):void
		{
			if(!this.parent) return;
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			TimeUtil.day	= Common.language.getLanguage("030101");
			TimeUtil.days	= Common.language.getLanguage("030102");
			TimeUtil.hour	= Common.language.getLanguage("030103");
			TimeUtil.minute	= Common.language.getLanguage("030104");
			TimeUtil.second	= Common.language.getLanguage("030105");
			
			TimeUtil.dFormat = Common.language.getLanguage("030201");
			TimeUtil.hFormat = Common.language.getLanguage("030202");
			TimeUtil.mFormat = Common.language.getLanguage("030203");
			TimeUtil.sFormat = Common.language.getLanguage("030204");
			
			Alert.OK	= Common.language.getLanguage("030301");
			Alert.CANCEL= Common.language.getLanguage("030302");
			Alert.YES	= Common.language.getLanguage("030303");
			Alert.NO	= Common.language.getLanguage("030304");
			Alert.CLOSE	= Common.language.getLanguage("030305");
			Alert.BACK	= Common.language.getLanguage("030306");
			
			RpgConstants.FPS_APPEAR	= 9;
			RpgConstants.FPS_STAND	= 3;
			RpgConstants.FPS_RUN	= 21;
			RpgConstants.FPS_ATTACK	= 12;
			RpgConstants.FPS_CONJURE= 12;
			RpgConstants.FPS_DEAD	= 9;
			
			Console.getInstance().container = Common.stage;
			Stats.getInstance().container = Common.stage;
			
			Common.sound = SoundManager.getInstance();
			Common.mouse = MouseManager.getInstance();
			Common.mouse.defaultStyle = GameConstants.MOUSE_STYLE_NORMAL;
			Common.mouse.contextMenu.customItems.push(new ContextMenuItem(Common.version, false, false));
			
			Animation.initialize();
			BaseTextField.initialize();
			BitmapSprite.initialize();
			BitmapMovieClip.initialize();
			ImageLoader.initialize();
			MovieClipLoader.initialize();
			ExternalUtil.initialize();
			
			LogSampler.enabled = true;
			
			Common.layout = LayoutManager.getInstance();
			Common.ui = GameUIManager.getInstance();
			this.parent.addChild(GameUIManager.getInstance());
			this.parent.removeChild(this);
			Common.ui.initialize();
			
			Console.getInstance().addEventListener(lolo.events.ConsoleEvent.INPUT, console_inputHandler);
			Logger.addEventListener(LogEvent.SAMPLE_LOG, logger_sampleLogHandler);
			Logger.addEventListener(LogEvent.ERROR_LOG, logger_errorLogHandler);
			LogSampler.addSystemInfoSampleLog();
		}
		
		
		/**
		 * 控制台有数据推送过来
		 * @param event
		 */
		private function console_inputHandler(event:lolo.events.ConsoleEvent):void
		{
			MvcEventDispatcher.dispatch(GameConstants.MN_CORE, new game.module.core.events.ConsoleEvent(event.data));
		}
		
		
		/**
		 * 有新的错误日志
		 * @param event
		 */
		private function logger_errorLogHandler(event:LogEvent):void
		{
			//trace(event.data.errorMsg);
		}
		
		/**
		 * 有新的采样日志
		 * @param event
		 */
		private function logger_sampleLogHandler(event:LogEvent):void
		{
			//trace(event.data.message);
		}
		
		
		
		/**
		 * 导入模块中常用到的类
		 */
		private function importClass():void
		{
			HashMap;
			LastTime;
			
			Scene;
			Window;
			
			LoadManager;
			ConfigManager;
			LanguageManager;
			
			BindUtil;
			TimeUtil;
			MathUtil;
			Validator;
		}
		//
	}
}