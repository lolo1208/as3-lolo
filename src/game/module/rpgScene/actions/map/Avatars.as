package game.module.rpgScene.actions.map
{
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.manager.MoveManager;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.view.IRpgScene;
	import game.module.rpgScene.view.avatar.AvatarBasicUI;
	import game.module.rpgScene.view.avatar.AvatarUnderUI;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.effects.AsEffect;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.avatar.Avatar;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.events.RpgMapEvent;
	import lolo.rpg.map.IRpgMap;
	import lolo.rpg.map.MapBackground;
	
	/**
	 * 当前玩家刚进入地图时，创建所有角色和怪物（103）
	 * @author LOLO
	 */
	public class Avatars implements IAction
	{
		
		public function execute(data:Object):void
		{
			for(var i:int = 0; i < data.avatars.length; i++)
				createAvatar(data.avatars[i]);
		}
		
		
		
		
		/**
		 * 创建一个角色
		 * @param roleData
		 * @return 
		 */
		public static function createAvatar(data:Object):IAvatar
		{
			var avatarData:AvatarData = new AvatarData(data);
			var isRole:Boolean = (avatarData.key == RpgSceneData.getInstance().roleKey);//是否为玩家自己
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			
			var avatar:IAvatar = map.createAvatar(
				avatarData.key, avatarData.pic, null, (isRole ? 9999 : 0),
				toPoint(avatarData.tile), avatarData.direction
			);
			avatar.data = avatarData;
			avatar.isDead = avatarData.isDead;
			avatar.addUI(new AvatarBasicUI());
			avatar.addUI(new AvatarUnderUI(), GameConstants.AVATAR_UI_UNDER, 0);
			
			//已死亡
			if(avatar.isDead) {
				avatar.playAction(RpgConstants.A_DEAD, false, 0.5, false);
				avatar.avatarAni.gotoAndStop(avatar.avatarAni.totalFrames);
			}
			
			//这个avatar是玩家，添加附加物
			if(!avatarData.monster) {
				avatar.addAdjunct(RpgConstants.ADJUNCT_TYPE_DRESS, avatarData.dress);
				avatar.addAdjunct(RpgConstants.ADJUNCT_TYPE_HAIR, avatarData.hair);
				avatar.addAdjunct(RpgConstants.ADJUNCT_TYPE_WEAPON, avatarData.weapon);
			}
			else {
				if(!avatarData.appear) {
					avatarData.appear = true;
					avatar.playAction(RpgConstants.A_APPEAR);
				}
			}
			
			if(isRole) {
				map.trackingAvatar = avatar;
			}
			else {
				avatar.addEventListener(AvatarEvent.MOUSE_OVER, avatar_mouseEventHandler);
				avatar.addEventListener(AvatarEvent.MOUSE_OUT, avatar_mouseEventHandler);
			}
			avatar.addEventListener(AvatarEvent.MOUSE_DOWN, avatar_mouseEventHandler);
			
			return avatar;
		}
		
		
		
		public static function avatar_mouseEventHandler(event:AvatarEvent):void
		{
			var avatar:Avatar = event.target as Avatar;
			var basicUI:AvatarBasicUI = avatar.getUI() as AvatarBasicUI;
			
			switch(event.type)
			{
				case AvatarEvent.MOUSE_OVER:
					avatar.transform.colorTransform = AsEffect.LIGHT_CTF_4;
					basicUI.showOrHideHpBar(true);
					break;
				
				case AvatarEvent.MOUSE_OUT:
					avatar.transform.colorTransform = new ColorTransform();
					basicUI.showOrHideHpBar(false, 1);
					break;
				
				case AvatarEvent.MOUSE_DOWN:
					if(avatar.data.key == RpgSceneData.getInstance().roleKey)
					{
						//鼠标点击，可穿透自己
						var bg:MapBackground = avatar.map.container.getChildByName(Constants.LAYER_NAME_BG) as MapBackground;
						if(avatar.map.autoPlayMouseDownAnimation) bg.playMouseDownAnimation();
						avatar.map.dispatchEvent(new RpgMapEvent(RpgMapEvent.MOUSE_DOWN, avatar.map.mouseTile));
					}
					else {
						//攻击其他玩家或NPC
						MoveManager.instance.attack(avatar);
					}
					break;
			}
		}
		
		
		
		private static function toPoint(value:Object):Point
		{
			return new Point(value.x, value.y);
		}
		//
	}
}