package game.module.rpgScene.actions.map
{
	import com.greensock.TweenMax;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;
	
	
	/**
	 * 有角色进入待机状态（106）
	 * @author LOLO
	 */
	public class Stand implements IAction
	{
		private var _avatar:IAvatar;
		private var _avatarData:AvatarData;
		
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			_avatarData = new AvatarData(data.avatar);
			
			_avatar = map.getAvatarByKey(_avatarData.key);
			if(_avatar.action == RpgConstants.A_STAND) {
				avatar_actionEndHandler();
			}
			else {
				_avatar.addEventListener(AvatarEvent.ACTION_END, avatar_actionEndHandler);
			}
		}
		
		
		
		/**
		 * 动作播放完成
		 * @param event
		 */
		private function avatar_actionEndHandler(event:AvatarEvent=null):void
		{
			_avatar.removeEventListener(AvatarEvent.ACTION_END, avatar_actionEndHandler);
			TweenMax.delayedCall(0.35, delayedStand);
		}
		
		
		private function delayedStand():void
		{
			if(_avatar.isDead) return;
			_avatar.playStand(_avatarData.direction);
		}
		//
	}
}