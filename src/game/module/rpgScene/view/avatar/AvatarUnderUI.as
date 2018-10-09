package game.module.rpgScene.view.avatar
{
	import game.module.rpgScene.model.AvatarData;
	
	import lolo.core.Common;
	import lolo.rpg.avatar.AvatarUI;
	import lolo.rpg.avatar.IAvatar;
	import lolo.utils.AutoUtil;
	
	/**
	 * 角色身下的UI
	 * @author LOLO
	 */
	public class AvatarUnderUI extends AvatarUI
	{
		private var _data:AvatarData;
		
		
		public function AvatarUnderUI()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			AutoUtil.autoUI(this, XML(Common.loader.getResByConfigName("rpgSceneConfig").underUI));
		}
		
		
		override public function set avatar(value:IAvatar):void
		{
			super.avatar = value;
			_data = _avatar.data;
		}
		//
	}
}