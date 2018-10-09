package game.module.rpgScene.actions.fight
{
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.actions.map.Avatars;
	import game.module.rpgScene.manager.SkillManager;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 有角色死亡（203）
	 * @author LOLO
	 */
	public class Dead implements IAction
	{
		
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var avatar:IAvatar = map.getAvatarByKey(data.avatar.key);
			
			avatar.removeEventListener(AvatarEvent.MOUSE_OVER, Avatars.avatar_mouseEventHandler);
			avatar.removeEventListener(AvatarEvent.MOUSE_OUT, Avatars.avatar_mouseEventHandler);
			avatar.removeEventListener(AvatarEvent.MOUSE_DOWN, Avatars.avatar_mouseEventHandler);
			
			avatar.data.isDead = avatar.isDead = true;
			avatar.stopMove();
			avatar.playAction(RpgConstants.A_DEAD, false, 1, false);
			
			
			if(avatar == SkillManager.instance.target) SkillManager.instance.target = null;
		}
		
		
		//
	}
}