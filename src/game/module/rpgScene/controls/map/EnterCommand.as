package game.module.rpgScene.controls.map
{
	import game.common.GameConstants;
	import game.common.RmList;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 进入地图
	 * @author LOLO
	 */
	public class EnterCommand implements ICommand
	{
		
		public function execute(event:MvcEvent):void
		{
			Common.service.send(RmList.MAP_ENTER, event.data, result);
		}
		
		
		/**
		 * 向后端发送请求的结果
		 * @param success
		 * @param data
		 */
		private function result(success:Boolean, data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			var role:IAvatar = map.getAvatarByKey(RpgSceneData.getInstance().roleKey);
			map.removeAvatar(role);
			
			RpgSceneData.getInstance().roleKey = data.key;
		}
		//
	}
}