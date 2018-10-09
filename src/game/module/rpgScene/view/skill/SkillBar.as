package game.module.rpgScene.view.skill
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import game.common.GameConstants;
	import game.module.rpgScene.manager.MoveManager;
	import game.module.rpgScene.manager.SkillManager;
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.model.SkillVO;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.components.List;
	import lolo.core.Common;
	import lolo.data.HashMap;
	import lolo.display.Container;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 技能条
	 * @author LOLO
	 */
	public class SkillBar extends Container
	{
		/**技能列表*/
		public var skillList:List;
		
		/**技能ID与按键的映射*/
		private var _skillKeyList:Dictionary;
		
		/**地图*/
		private var _map:IRpgMap;
		
		
		
		public function SkillBar()
		{
			super();
		}
		
		
		override public function initUI(config:XML):void
		{
			super.initUI(config);
			skillList.itemRendererClass = SkillItemRenderer;
			
			var vo:SkillVO;
			var hm:HashMap = new HashMap();
			vo = new SkillVO(FightConstants.SID_GONG_JI, "gongJi", 0, "A"); hm.add(vo, vo.id);
			vo = new SkillVO(FightConstants.SID_XU_LI, "xuLi", 1, "Q"); hm.add(vo, vo.id);
			vo = new SkillVO(FightConstants.SID_HUO_QIANG, "huoQiang", 0, "W"); hm.add(vo, vo.id);
			vo = new SkillVO(FightConstants.SID_LEI_DIAN, "leiDian", 0, "E"); hm.add(vo, vo.id);
			vo = new SkillVO(FightConstants.SID_MO_FA_DUN, "moFaDun", 0, "R"); hm.add(vo, vo.id);
			vo = new SkillVO(FightConstants.SID_SHUN_YI, "shunYi", 0, "D"); hm.add(vo, vo.id);
			skillList.data = hm;
			
			_skillKeyList = new Dictionary();
			_skillKeyList[Keyboard.A] = FightConstants.SID_GONG_JI;
			_skillKeyList[Keyboard.E] = FightConstants.SID_LEI_DIAN;
			_skillKeyList[Keyboard.D] = FightConstants.SID_SHUN_YI;
		}
		
		
		
		
		/**
		 * 舞台有按键
		 * @param event
		 */
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			var avatar:IAvatar = _map.getAvatarByKey(RpgSceneData.getInstance().roleKey);
			if(avatar.isDead) return;
			
			var skillID:int = _skillKeyList[event.keyCode];
			if(skillID == 0) return;//没按到技能快捷键
			
			//技能的受击者
			var target:IAvatar = _map.mouseAvatar;
			if(target == avatar) target = null;
			if(target == null) target = SkillManager.instance.target;
			if(target != null && target.isDead) return;
			
			//普通攻击
			if(skillID == FightConstants.SID_GONG_JI)
			{
				if(target == null) return;
				if(_map.mouseAvatar == avatar) return;
				MoveManager.instance.attack(target);
			}
			else
			{
				SkillManager.instance.target = target;
				SkillManager.instance.useSkill(skillID);
			}
		}
		
		
		
		override protected function startup():void
		{
			super.startup();
			Common.layout.stageLayout(this);
			Common.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			
			if(_map == null) _map = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
		}
		//
	}
}