package game.module.core.view
{
	import flash.utils.getDefinitionByName;
	
	import game.common.GameConstants;
	import game.module.guide.view.IGuide;
	import game.module.rpgScene.model.RpgSceneData;
	import game.ui.LoadBar;
	import game.ui.RequestModal;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.core.UIManager;
	import lolo.data.LoadItemModel;
	import lolo.rpg.RpgConstants;
	import lolo.ui.Stats;

	/**
	 * 游戏用户界面管理
	 * @author LOLO
	 */
	public class GameUIManager extends UIManager implements IGameUIManager
	{
		/**单例的实例*/
		private static var _instance:GameUIManager;
		
		
		/**新手引导模块*/
		private var _guide:IGuide
		
		
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():GameUIManager
		{
			if(_instance == null) _instance = new GameUIManager(new Enforcer());
			return _instance;
		}
		
		public function GameUIManager(enforcer:Enforcer)
		{
			if(!enforcer) {
				throw new Error("请通过 Common.ui 获取实例");
				return;
			}
		}
		
		
		
		override public function initialize(...args):void
		{
			super.initialize.apply(null, args);
			
			_loadBar = new LoadBar();
			_requestModal = new RequestModal();
			
			_guide = getDefinitionByName(GameConstants.MN_GUIDE).instance;
			
			
			//注册好游戏内的所有模块
			addModule(GameConstants.MN_SCENE_LOGIN, [
				new LoadItemModel("loginSceneModule"),
				new LoadItemModel("loginSceneConfig")
			]);
			
			addModule(GameConstants.MN_SCENE_TEST, [
				new LoadItemModel("testSceneModule"),
				new LoadItemModel("testSceneConfig")
			]);
			
			addModule(GameConstants.MN_SCENE_RPG, [
				new LoadItemModel("rpgSceneModule"),
				new LoadItemModel("rpgSceneConfig"),
				new LoadItemModel("fightConfig")
			]);
			
//			showModule(GameConstants.MN_SCENE_TEST);
			showModule(GameConstants.MN_SCENE_RPG);
//			showModule(GameConstants.MN_SCENE_LOGIN);
			
			if(Common.isDebug) Stats.getInstance().show();
		}
		
		
		
		override protected function loadModule(moduleName:String, limList:Array, args:Array):void
		{
			switch(moduleName)
			{
				//RPG场景
				case GameConstants.MN_SCENE_RPG:
					loadRpgMap(RpgSceneData.DEFAULT_MAP_ID);
					break;
			}
			
			super.loadModule(moduleName, limList, args);
		}
		
		
		
		override protected function showNowModule(moduleName:String, args:Array):void
		{
			super.showNowModule(moduleName, args);
		}
		
		
		
		public function loadRpgMap(id:String, callback:Function=null):void
		{
			var lim:LoadItemModel = new LoadItemModel();
			lim.parseUrl(Common.config.getUIConfig(RpgConstants.CN_MAP_DATA, id));
			lim.type = Constants.RES_TYPE_BINARY;
			lim.name = Common.language.getLanguage("020191");
			Common.loader.add(lim);
			
			lim = new LoadItemModel();
			lim.url = Common.config.getUIConfig(RpgConstants.CN_MAP_THUMBNAIL, id);
			lim.type = Constants.RES_TYPE_IMG;
			lim.name = Common.language.getLanguage("020192");
			Common.loader.add(lim);
			
			Common.loader.start(callback);
		}
		
		
		public function get guide():IGuide { return _guide; }
		//
	}
}


class Enforcer {}