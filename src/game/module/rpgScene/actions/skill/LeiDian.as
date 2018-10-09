package game.module.rpgScene.actions.skill
{
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.model.EffectVO;
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.SkillVO;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.events.AnimationEvent;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.map.IRpgMap;
	
	/**
	 * 技能 - 雷电术（301）
	 * @author LOLO
	 */
	public class LeiDian implements IAction
	{
		
		public function execute(data:Object):void
		{
			var map:IRpgMap = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			
			var vo:EffectVO = EffectVO.getVO(SkillVO.getEffectID(FightConstants.SID_LEI_DIAN, false));
			var ani:Animation = new Animation(vo.sourceName, vo.fps);
			var p:Point = RpgUtil.getTileCenter(new Point(data.tile.x, data.tile.y), map.info);
			ani.x = p.x;
			ani.y = p.y;
			map.addElement(ani, true);
			ani.addEventListener(AnimationEvent.ANIMATION_END, aniEndHandler);
			ani.play(1, 1);
		}
		
		
		
		/**
		 * 技能动画播放完毕
		 * @param event
		 */
		private function aniEndHandler(event:AnimationEvent):void
		{
			var ani:Animation = event.target as Animation;
			ani.removeEventListener(AnimationEvent.ANIMATION_END, aniEndHandler);
			if(ani.parent != null) ani.parent.removeChild(ani);
		}
		//
	}
}