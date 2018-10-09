package game.module.rpgScene.actions.fight
{
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.view.IRpgScene;
	import game.module.rpgScene.view.avatar.AvatarBasicUI;
	
	import lolo.core.Common;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 血量有改变（202）
	 * @author LOLO
	 */
	public class ChangeHP implements IAction
	{
		
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var avatar:IAvatar = map.getAvatarByKey(data.avatar.key);
			
			avatar.data.hpMax = data.avatar.hpMax;
			avatar.data.hpCurrent = data.avatar.hpCurrent;
			(avatar.getUI() as AvatarBasicUI).changeHP(data.miss, data.num);
		}
		//
	}
}