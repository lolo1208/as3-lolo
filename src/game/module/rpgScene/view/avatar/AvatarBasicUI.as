package game.module.rpgScene.view.avatar
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	
	import game.module.rpgScene.manager.SkillManager;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.model.RpgSceneData;
	
	import lolo.components.ArtText;
	import lolo.components.Label;
	import lolo.core.Common;
	import lolo.display.BitmapSprite;
	import lolo.effects.float.IFloat;
	import lolo.effects.float.UpFloat;
	import lolo.rpg.avatar.AvatarUI;
	import lolo.rpg.avatar.IAvatar;
	import lolo.utils.AutoUtil;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * 角色基础UI
	 * @author LOLO
	 */
	public class AvatarBasicUI extends AvatarUI
	{
		public var nameText:Label;
		public var hpBarC:Sprite;
		public var hpBar:BitmapSprite;
		public var hpText:Label;
		
		private var _data:AvatarData;
		
		
		public function AvatarBasicUI()
		{
			super();
			this.mouseEnabled = this.mouseChildren = false;
			AutoUtil.autoUI(this, XML(Common.loader.getResByConfigName("rpgSceneConfig").basicUI));
			hpBarC.alpha = 0;
			hpBarC.visible = false;
		}
		
		
		override public function set avatar(value:IAvatar):void
		{
			super.avatar = value;
			_data = _avatar.data;
			
			if(_avatar.key == RpgSceneData.getInstance().roleKey) nameText.color = 0xFFFFFF;
			nameText.text = _data.name;
			nameText.x = -nameText.textWidth >> 1;
			showHP();
		}
		
		
		private function showHP():void
		{
			TweenMax.killTweensOf(hpBar);
			TweenMax.to(hpBar, 0.2, { scaleX:_avatar.data.hpCurrent / _avatar.data.hpMax });
			
			hpText.text = _avatar.data.hpCurrent + "/" + _avatar.data.hpMax;
		}
		
		
		
		/**
		 * 
		 * @param miss
		 * @param num
		 * @param floatType 浮动类型 [ 0:UpFloat ]
		 */
		public function changeHP(miss:Boolean, num:int, floatType:int=0):void
		{
			var at:ArtText = CachePool.getArtText(0, -80);
			at.align = "center";
			this.addChild(at);
			
			if(miss) {
				at.prefix = "public.artText.text";
				at.text = "m";
			}
			else {
				showHP();
				hpBarC.alpha = 1;
				hpBarC.visible = true;
				showOrHideHpBar(false, 3);
				
				at.prefix = "public.artText.num2";
				at.text = String(num);
			}
			
			if(floatType == 0) {
				new UpFloat(at, textFloatEnd).start();
			}
		}
		
		
		
		/**
		 * 文字浮动结束
		 * @param complete
		 * @param float
		 */
		private function textFloatEnd(complete:Boolean, float:IFloat):void
		{
			CachePool.recover(float.target);
		}
		
		
		
		/**
		 * 显示或隐藏血条
		 * @param isShow
		 * @param duration
		 * @param delay
		 */
		public function showOrHideHpBar(isShow:Boolean, delay:Number=0, duration:Number=0.2):void
		{
			if(_avatar.isDead) {
				isShow = false;
				delay = duration = 0;
			}
			
			if(!isShow && hpBarC.alpha > 0) hpBarC.alpha = 1;
			
			TweenMax.killTweensOf(hpBarC);
			TweenMax.to(hpBarC, duration, { autoAlpha:isShow ? 1 : 0, delay:delay });
			
			hpText.visible = _avatar == _avatar.map.mouseAvatar//鼠标下的角色
				|| _avatar == SkillManager.instance.target//技能目标
				|| _avatar.key == RpgSceneData.getInstance().roleKey;//玩家自己
		}
		//
	}
}