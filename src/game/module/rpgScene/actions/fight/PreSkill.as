package game.module.rpgScene.actions.fight
{
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.model.EffectVO;
	import game.module.rpgScene.model.SkillVO;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.events.AnimationEvent;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 播放施法动作（204）
	 * @author LOLO
	 */
	public class PreSkill implements IAction
	{
		/**攻击者*/
		private var _attacker:IAvatar;
		/**攻击者在施法这一刻的数据*/
		private var _attackerData:AvatarData;
		/**技能ID*/
		private var _skillID:int;
		
		
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			_attackerData = new AvatarData(data.avatar);
			_attacker = map.getAvatarByKey(_attackerData.key);
			_skillID = data.skillID;
			
			if(_attacker.moveing) {
				_attacker.addEventListener(AvatarEvent.MOVE_END, avatar_moveEnd);
			}
			else {
				avatar_moveEnd();
			}
		}
		
		
		/**
		 * 移动结束后，播放施法动作
		 * @param event
		 */
		private function avatar_moveEnd(event:AvatarEvent=null):void
		{
			//还没移动到正确的位置
			if(!_attacker.tile.equals(_attackerData.tileP)) return;
			
			_attacker.removeEventListener(AvatarEvent.MOVE_END, avatar_moveEnd);
			_attacker.direction = _attackerData.direction;
			_attacker.playAction(RpgConstants.A_CONJURE);
			
			//需要播发技能引导动画
			if(_skillID > 0)
			{
				var vo:EffectVO = EffectVO.getVO(SkillVO.getEffectID(_skillID, true));
				var ani:Animation = new Animation(vo.sourceName, vo.fps);
				var p:Point = RpgUtil.getTileCenter(_attacker.tile, _attacker.map.info);
				ani.x = p.x;
				ani.y = p.y;
				_attacker.map.addElement(ani, true);
				ani.addEventListener(AnimationEvent.ANIMATION_END, aniEndHandler);
				ani.play(1, 1);
			}
		}
		
		
		/**
		 * 技能引导动画播放完毕
		 * @param event
		 */
		private function aniEndHandler(event:AnimationEvent):void
		{
			var ani:Animation = event.target as Animation;
			ani.removeEventListener(AnimationEvent.ANIMATION_END, aniEndHandler);
			if(ani.parent != null) ani.parent.removeChild(ani);
		}
		//
	}
}