package game.module.rpgScene.actions.map
{
	import game.module.rpgScene.actions.IAction;
	
	/**
	 * 有角色进入地图（101）
	 * @author LOLO
	 */
	public class Enter implements IAction
	{
		
		public function execute(data:Object):void
		{
			Avatars.createAvatar(data.avatar);
		}
		//
	}
}