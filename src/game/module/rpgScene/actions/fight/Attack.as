package game.module.rpgScene.actions.fight
{
	import com.greensock.TweenMax;
	
	import flash.utils.Dictionary;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.manager.MoveManager;
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 攻击（201）
	 * @author LOLO
	 */
	public class Attack implements IAction
	{
		/**移动结束后，攻击的方向*/
		private static var _directionList:Dictionary = new Dictionary();
		
		
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var avatar:IAvatar = map.getAvatarByKey(data.avatar.key);
			(avatar.data as AvatarData).parse(data.avatar);
			
			_directionList[avatar] = data.avatar.direction;
			if(avatar.moveing) {
				avatar.addEventListener(AvatarEvent.MOVE_END, avatar_moveEnd);
			}
			else {
				avatar_moveEnd(null, avatar);
			}
		}
		
		
		/**
		 * 移动结束后，播放攻击动作
		 * @param event
		 * @param avatar
		 */
		private function avatar_moveEnd(event:AvatarEvent=null, avatar:IAvatar=null):void
		{
			if(event != null) avatar = event.target as IAvatar;
			avatar.removeEventListener(AvatarEvent.MOVE_END, avatar_moveEnd);
			avatar.direction = _directionList[avatar];
			delete _directionList[avatar];
			
			avatar.addEventListener(AvatarEvent.ACTION_END, attack_actionEndHandler);
			avatar.playAction(RpgConstants.A_ATTACK, false, 1, false);
		}
		
		
		/**
		 * 攻击动画播放完成
		 * @param event
		 */
		private function attack_actionEndHandler(event:AvatarEvent):void
		{
			var avatar:IAvatar = event.target as IAvatar;
			avatar.removeEventListener(AvatarEvent.ACTION_END, attack_actionEndHandler);
			
			TweenMax.delayedCall(
				(avatar.data as AvatarData).getCD(FightConstants.SID_GONG_JI) / 1000 + 0.05,
				MoveManager.instance.continueToAttack
			);
		}
		//
	}
}