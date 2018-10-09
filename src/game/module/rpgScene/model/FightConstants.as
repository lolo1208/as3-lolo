package game.module.rpgScene.model
{
	/**
	 * 战斗中用到的常量集合
	 * @author LOLO
	 */
	public class FightConstants
	{
		/**技能ID - 普通攻击*/
		public static const SID_GONG_JI:int = 1;
		/**技能ID - 蓄力一击*/
		public static const SID_XU_LI:int = 2;
		/**技能ID - 火墙*/
		public static const SID_HUO_QIANG:int = 3;
		/**技能ID - 雷电术*/
		public static const SID_LEI_DIAN:int = 4;
		/**技能ID - 魔法盾*/
		public static const SID_MO_FA_DUN:int = 5;
		/**技能ID - 瞬移*/
		public static const SID_SHUN_YI:int = 6;
		
		
		/**技能CD时长 列表*/
		public static const CD_LIST:Array = [0,
			570,
			1000 * 2,
			1000 * 5,
			1000 * 1,
			1000 * 10,
			1000 * 15
		];
		
		//
	}
}