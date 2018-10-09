package game.module.rpgScene.view.skill
{
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.SkillVO;
	
	import lolo.components.ImageLoader;
	import lolo.components.ItemRenderer;
	import lolo.components.Label;
	import lolo.components.ToolTip;
	import lolo.core.Common;
	import lolo.utils.AutoUtil;
	
	/**
	 * 技能Item
	 * @author LOLO
	 */
	public class SkillItemRenderer extends ItemRenderer
	{
		public var icon:ImageLoader;
		public var keyText:Label;
		
		
		public function SkillItemRenderer()
		{
			super();
			AutoUtil.autoUI(this, XML( Common.loader.getResByConfigName("rpgSceneConfig").skillItem ));
		}
		
		
		override public function set data(value:*):void
		{
			super.data = value;
			var vo:SkillVO = _data;
			
			keyText.text = vo.keyIntro;
			icon.fileName = (vo.state > 0) ? (vo.pic + vo.state) : vo.pic;
			
			switch(vo.id)
			{
				case FightConstants.SID_GONG_JI:
					vo.intro = "<font color='#CC6600' size='14'><b>攻击</b></font>　　快捷键：<font color='#0'><b>[A]<br/>0.57</b></font>秒冷却时间<br/>普通攻击，A人你懂吗？"
					break;
				
				case FightConstants.SID_XU_LI:
					vo.intro = "<font color='#CC6600' size='14'><b>蓄力一击</b></font>　　快捷键：<font color='#0'><b>[Q]<br/>2</b></font>秒冷却时间<br/>未开放！"
					break;
				
				case FightConstants.SID_HUO_QIANG:
					vo.intro = "<font color='#CC6600' size='14'><b>火墙</b></font>　　快捷键：<font color='#0'><b>[W]<br/>5</b></font>秒冷却时间<br/>未开放！"
					break;
				
				case FightConstants.SID_LEI_DIAN:
					vo.intro = "<font color='#CC6600' size='14'><b>雷电术</b></font>　　快捷键：<font color='#0'><b>[E]<br/>1</b></font>秒冷却时间<br/>施法范围：800（400-800距离越远miss几率越大）<br/>召唤一道雷电，从目标头上劈下，将其劈傻！"
					break;
				
				case FightConstants.SID_MO_FA_DUN:
					vo.intro = "<font color='#CC6600' size='14'><b>魔法盾</b></font>　　快捷键：<font color='#0'><b>[R]<br/>10</b></font>秒冷却时间<br/>未开放！"
					break;
				
				case FightConstants.SID_SHUN_YI:
					vo.intro = "<font color='#CC6600' size='14'><b>瞬移</b></font>　　快捷键：<font color='#0'><b>[D]<br/>15</b></font>秒冷却时间<br/>未开放！"
					break;
			}
			
			ToolTip.register(this, vo.intro);
		}
		//
	}
}