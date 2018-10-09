package game.module.rpgScene.view
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import game.module.rpgScene.controls.RpgSceneController;
	import game.module.rpgScene.manager.MoveManager;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.view.skill.SkillBar;
	
	import lolo.core.Common;
	import lolo.display.Scene;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.RpgMapEvent;
	import lolo.rpg.map.IRpgMap;
	import lolo.rpg.map.RpgMap;

	/**
	 * 测试场景
	 * @author LOLO
	 */
	public class RpgScene extends Scene implements IRpgScene
	{
		/**单例的实例*/
		public static var instance:RpgScene;
		
		/**rpg底图容器*/
		public var mapContainer:Sprite;
		
		public var createRole:CreateRole = new CreateRole();
		public var skillView:SkillBar = new SkillBar();
		
		private var _data:RpgSceneData;
		private var _map:IRpgMap;
		private var _moveManager:MoveManager;
		
		
		public function RpgScene()
		{
			super();
			if(instance != null) return;
			instance = this;
			new RpgSceneController();
		}
		
		override public function initialize(...args):void
		{
			_data = RpgSceneData.getInstance();
			
			initUI(Common.loader.getResByConfigName("rpgSceneConfig"));
			xmlConfigName = "rpgSceneConfig";
			
			_map = new RpgMap(mapContainer);
			_map.autoPlayMouseDownAnimation = true;
			_map.addEventListener(RpgMapEvent.MOUSE_DOWN, mapMouseDownHandler);
			
			Common.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
		}
		
		
		
		
		private function stage_mouseDownHandler(event:MouseEvent):void
		{
			
		}
		
		
		
		/**
		 * 鼠标在地图上按下
		 * @param event
		 */
		private function mapMouseDownHandler(event:RpgMapEvent):void
		{
			var avatar:IAvatar = _map.getAvatarByKey(_data.roleKey);
			var tile:Point = RpgUtil.closestCanPassTile(avatar.tile, event.tile, _map.info);
			
			//还没有进入游戏
			if(_data.roleKey == "lolo") {
				avatar.moveToTile(tile);
			}
			else {
				MoveManager.instance.moveTo(tile);
			}
		}
		
		
		
		public function get map():IRpgMap { return _map; }
		
		
		
		override protected function startup():void
		{
			_map.init(RpgSceneData.DEFAULT_MAP_ID);
			_data.roleKey = "lolo";
			_map.trackingAvatar = _map.createAvatar(_data.roleKey);
			createRole.show();
			
			super.startup();
		}
		//
	}
}