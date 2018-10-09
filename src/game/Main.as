package game
{
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import game.ui.Loading;
	
	import lolo.core.Common;
	import lolo.core.ConfigManager;
	import lolo.core.Constants;
	import lolo.core.LanguageManager;
	import lolo.core.LoadManager;
	import lolo.data.LoadItemModel;
	import lolo.events.LoadEvent;
	import lolo.utils.TimeUtil;
	import lolo.utils.logging.Logger;
	
	
	[SWF(width="1000", height="600", backgroundColor="#7F7F7F", frameRate="60")]
	/**
	 * LOLO的Web框架
	 * @author LOLO
	 */
	public class Main extends Sprite
	{
		/**在Loading动画还没加载进来之前，显示Loading...字样*/
		private var _loadingText:TextField;
		/**游戏开始时的加载条*/
		private var _loading:Loading;
		/**进场动画*/
		private var _welcome:MovieClip;
		
		
		public function Main()
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			
			this.mouseEnabled = false;
			stage.stageFocusRect = false;
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			_loadingText = new TextField();
			_loadingText.selectable = _loadingText.mouseWheelEnabled = false;
			var format:TextFormat = new TextFormat("宋体", 14, 0xFFFFFF);
			format.align = "center";
			_loadingText.defaultTextFormat = format;
			_loadingText.autoSize = "left";
			_loadingText.text = "Loading...";
			this.addChild(_loadingText);
			
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
			
			TimeUtil.initialize();
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Logger.uncaughtErrorHandler);
			
			var arr:Array = root.loaderInfo.loaderURL.match(/Main_(.*?).swf/);
			Common.version = (arr != null) ? arr[1] : "debug";
			
			Common.stage = this.stage;
			Common.initData = LoaderInfo(root.loaderInfo).parameters;
			Common.config = ConfigManager.getInstance();
			Common.language = LanguageManager.getInstance();
			Common.loader = LoadManager.getInstance();
			
			Common.loader.addEventListener(LoadEvent.ITEM_COMPLETE, loader_completeHandler);
			Common.loader.add(new LoadItemModel(null, false, 0, null, null, "Config.xml", Constants.RES_TYPE_XML));
			Common.loader.start();
		}
		
		
		/**
		 * 加载单个文件完成
		 * @param event
		 */
		private function loader_completeHandler(event:LoadEvent):void
		{
			switch(event.lim.configName)
			{
				case "loadingMovie":
					this.removeChild(_loadingText);
					_loadingText = null;
					_loading = new Loading(Common.loader.getResByConfigName("loadingMovie", true));
					this.addChildAt(_loading, 0);
					stage_resizeHandler();
					
					Common.loader.add(new LoadItemModel("language"));
					_loading.start();
					break;
				
				case "language":
					Common.language.initialize();
					
					Common.loader.add(new LoadItemModel("skin"));
					Common.loader.add(new LoadItemModel("style"));
					Common.loader.add(new LoadItemModel("uiConfig"));
					Common.loader.add(new LoadItemModel("embedFontConfig"));
					Common.loader.add(new LoadItemModel("animationConfig"));
					Common.loader.add(new LoadItemModel("movieClipConfig"));
					Common.loader.add(new LoadItemModel("bitmapSpriteConfig"));
					
					Common.loader.add(new LoadItemModel("mainUIConfig"));
					Common.loader.add(new LoadItemModel("game"));
					Common.loader.add(new LoadItemModel("welcome"));
					
					Common.loader.add(new LoadItemModel("guideModule").addUrlListByCN("game"));
					
					Common.loader.start(null, allComplete_callback);
					break;
				
				case "skin":
					Common.config.initSkinConfig();
					break;
					
				case "style":
					Common.config.initStyleConfig();
					break;
				
				case "uiConfig":
					Common.config.initUIConfig();
					break;
				
				default:
					switch(event.lim.url)
					{
						case "Config.xml":
							Common.config.initConfig();
							var resurl:String = Common.getInitDataByKey("resurl");
							if(resurl != null) Common.resServerUrl = resurl;
							
							if(Common.isDebug) {
								Common.loader.add(new LoadItemModel(null, false, 0, null, null,
									resConfigUrl, Constants.RES_TYPE_XML));
							}
							else {
								Common.loader.add(new LoadItemModel(null, false, 0, null, null,
									resListUrl, Constants.RES_TYPE_BINARY));
							}
							
							break;
						
						case resListUrl:
							if(!Common.isDebug) Common.initResList(resListUrl);
							
							Common.loader.add(new LoadItemModel(null, false, 0, null, null,
								resConfigUrl, Constants.RES_TYPE_XML));
							break;
						
						case resConfigUrl:
							Common.config.initResConfig(resConfigUrl);
							Common.loader.add(new LoadItemModel("loadingMovie"));
							break;
					}
			}
			
			if(event.lim.configName != null && event.lim.url != null) {
				Common.loader.start();
			}
		}
		
		
		
		/**
		 * 加载所有文件完成
		 * @param event
		 */
		private function allComplete_callback():void
		{
			Common.loader.removeEventListener(LoadEvent.ITEM_COMPLETE, loader_completeHandler);
			this.removeChild(_loading);
			_loading.dispose();
			_loading = null;
			
			_welcome = Common.loader.getResByConfigName("welcome", true);
			_welcome.gotoAndPlay(1);
			_welcome.addEventListener("skip", welcome_skipHandler);
			this.addChild(_welcome);
			stage_resizeHandler();
		}
		
		
		/**
		 * 进场动画播放完成
		 * @param event
		 */
		private function welcome_skipHandler(event:Event):void
		{
			_welcome.removeEventListener("skip", welcome_skipHandler);
			this.removeChild(_welcome);
			_welcome = null;
			this.addChild(Common.loader.getResByConfigName("game", true));
			
			stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
		}
		
		
		
		/**
		 * 舞台尺寸有改变
		 */
		private function stage_resizeHandler(event:Event=null):void
		{
			if(_loadingText != null) {
				_loadingText.x = stage.stageWidth - _loadingText.width >> 1;
				_loadingText.y = stage.stageHeight - _loadingText.height >> 1;
			}
			if(_loading != null) {
				_loading.x = stage.stageWidth - 1000 >> 1;
				_loading.y = stage.stageHeight - 600 >> 1;
			}
			if(_welcome != null) {
				_welcome.x = stage.stageWidth - 1000 >> 1;
				_welcome.y = stage.stageHeight - 600 >> 1;
			}
		}
		
		
		
		
		/**
		 * 获取resList文件的url
		 * @return 
		 */
		private function get resListUrl():String
		{
			return "resList_" + Common.version + ".txt";
		}
		
		/**
		 * 获取resConfig文件的url
		 * @return 
		 */
		private function get resConfigUrl():String
		{
			return "assets/{resVersion}/xml/core/ResConfig.xml";
		}
		//
	}
}