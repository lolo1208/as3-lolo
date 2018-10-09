package game.module.rpgScene.manager
{
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.common.RmList;
	import game.module.rpgScene.model.EffectVO;
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.view.IRpgScene;
	import game.module.rpgScene.view.avatar.AvatarUnderUI;
	
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;

	/**
	 * 技能控制器
	 * @author LOLO
	 */
	public class SkillManager
	{
		/**单例的实例*/
		private static var _instance:SkillManager;
		
		/**地图*/
		private var _map:IRpgMap;
		/**玩家的角色*/
		private var _avatar:IAvatar;
		/**技能目标角色*/
		private var _target:IAvatar;
		
		/**技能锁定目标脚下的光圈*/
		private var _guangQuan:Animation;
		
		/**在移动结束后，要释放的技能的ID*/
		private var _skillID:int;
		
		
		
		/**
		 * 单例的实例
		 */
		public static function get instance():SkillManager
		{
			if(_instance == null) _instance = new SkillManager();
			return _instance;
		}
		
		
		public function SkillManager()
		{
			if(_instance != null) return;
			_instance = this;
			
			_map = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			_avatar = _map.getAvatarByKey(RpgSceneData.getInstance().roleKey);
			
			var vo:EffectVO = EffectVO.getVO("guangQuan_hong");
			_guangQuan = new Animation(vo.sourceName, vo.fps);
		}
		
		
		
		/**
		 * 使用某个技能
		 * @param id
		 */
		public function useSkill(id:int):void
		{
			if(id == _skillID) return;
			if(_avatar.action == RpgConstants.A_CONJURE) return;
			
			
			
			
			if(id == FightConstants.SID_GONG_JI)
			{
				if(_target != null) {
					var data:Object = {};
					data.direction = _avatar.direction;
					data.target = _target.data.getObject();
					Common.service.send(RmList.FIGHT_ATTACK, data);
				}
			}
			else
			{
				//取消攻击和移动
				MoveManager.instance.cancelAttack();
				MoveManager.instance.moveTo(_avatar.tile);
				
				//等待移动结束
				_skillID = id;
				if(_avatar.moveing) {
					_avatar.addEventListener(AvatarEvent.MOVE_END, avatar_moveEnd);
				}
				else {
					avatar_moveEnd();
				}
			}
		}
		
		
		/**
		 * 移动结束后，施法技能
		 * @param event
		 */
		private function avatar_moveEnd(event:AvatarEvent=null):void
		{
			//默认方向
			var data:Object = {};
			if(_target != null) {
				data.direction = RpgUtil.getDirection(
					new Point(_avatar.x, _avatar.y),
					new Point(_target.x, _target.y)
				);
			}
			else {
				data.direction = RpgUtil.getDirection(
					RpgUtil.getTileCenter(_avatar.tile, _map.info),
					new Point(_map.container.mouseX, _map.container.mouseY)
				);
			}
			
			var mouseTile:Point = _map.mouseTile;
			
			switch(_skillID)
			{
				case FightConstants.SID_LEI_DIAN:
					if(_target != null) (data.target = _target.data.getObject())
					else (data.tile = {x:mouseTile.x, y:mouseTile.y});
					Common.service.send(RmList.FIGHT_LEI_DIAN, data);
					break;
			}
			
			_skillID = 0;
		}
		
		
		
		/**
		 * 技能目标角色
		 */
		public function set target(value:IAvatar):void
		{
			_target = value;
			
			if(_target != null) {
				var ui:AvatarUnderUI = _target.getUI(GameConstants.AVATAR_UI_UNDER) as AvatarUnderUI;
				ui.addChild(_guangQuan);
				_guangQuan.play();
			}
			else {
				if(_guangQuan.parent) _guangQuan.parent.removeChild(_guangQuan);
				_guangQuan.stop();
			}
		}
		public function get target():IAvatar { return _target; }
		//
	}
}