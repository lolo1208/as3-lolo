package game.module.rpgScene.actions.map
{
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 有角色离开地图（102）
	 * @author LOLO
	 */
	public class Leave implements IAction
	{
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var avatar:IAvatar = map.getAvatarByKey(data.avatar.key);
			map.removeAvatar(avatar);
		}
		//
	}
}