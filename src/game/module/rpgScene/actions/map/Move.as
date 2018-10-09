package game.module.rpgScene.actions.map
{
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.map.IRpgMap;
	
	
	/**
	 * 有角色移动（104）
	 * @author LOLO
	 */
	public class Move implements IAction
	{
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var avatar:IAvatar = map.getAvatarByKey(data.avatar.key);
			(avatar.data as AvatarData).tile = { x:data.avatar.tile.x, y:data.avatar.tile.y };
			avatar.moveToTile(new Point(data.avatar.tile.x, data.avatar.tile.y));
		}
		//
	}
}