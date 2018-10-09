package game.module.rpgScene.model
{
	import flash.utils.Dictionary;
	
	import lolo.data.LastTime;

	/**
	 * 技能VO
	 * @author LOLO
	 */
	public class SkillVO
	{
		/**技能特效对应的 effectID 列表*/
		private static var _effectIDList:Dictionary;
		
		
		/**技能ID*/
		public var id:int;
		/**技能pic*/
		public var pic:String;
		/**状态等级*/
		public var state:int;
		/**技能描述*/
		public var intro:String;
		
		/**快捷键描述*/
		public var keyIntro:String;
		
		/**技能CD*/
		public var cd:LastTime;
		
		
		
		/**
		 * 获取技能特效对应的 effectID
		 * @param skillID
		 * @param pre
		 * @return 
		 */
		public static function getEffectID(skillID:int, pre:Boolean):String
		{
			var effectID:String = _effectIDList[skillID];
			if(pre) effectID += "_pre";
			return effectID;
		}
		
		
		
		public function SkillVO(id:int, pic:String, state:int, keyIntro:String, intro:String=null)
		{
			this.id = id;
			this.pic = pic;
			this.state = state;
			this.intro = intro;
			this.keyIntro = keyIntro;
			
			cd = new LastTime();
			
			if(_effectIDList == null)
			{
				_effectIDList = new Dictionary();
				_effectIDList[FightConstants.SID_LEI_DIAN] = "leiDian";
			}
		}
		//
	}
}