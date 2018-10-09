package game.module.rpgScene.model
{
	
	import flash.geom.Point;
	
	
	import lolo.utils.TimeUtil;
	
	/**
	 * 角色的数据
	 * @author LOLO
	 */
	public class AvatarData
	{
		public var mapID:String;
		public var name:String;
		public var key:String;
		public var pic:String;
		public var hair:String;
		public var dress:String;
		public var weapon:String;
		public var direction:uint;
		public var tile:Object = {};
		public var hpMax:int = 2000;
		public var hpCurrent:int = 2000;
		public var isDead:Boolean;
		
		
		/**是否是怪物*/
		public var monster:Boolean;
		/**是否已经醒来*/
		public var wake:Boolean = true;
		/**是否已出场（现身）*/
		public var appear:Boolean = true;
		
		/**技能列表 skillList[skillID]={ useTime:上次使用时间, state:状态 }*/
		public var skillList:Object;
		
		
		
		
		
		
		public function AvatarData(data:Object=null)
		{
			skillList = {};
			parse(data);
		}
		
		public function parse(data:Object):void
		{
			if(data == null) return;
			for(var k:String in data) {
				this[k] = data[k];
				if(k == "tile") tile = { x:data[k].x, y:data[k].y };
			}
		}
		
		public function getObject():Object
		{
			return {
				key			: key,
				name		: name,
				pic			: pic,
				hair		: hair,
				dress		: dress,
				weapon		: weapon,
				direction	: direction,
				tile		: { x:tile.x, y:tile.y },
				mapID		: mapID,
				monster		: monster,
				wake		: wake,
				appear		: appear,
				
				hpMax		: hpMax,
				hpCurrent	: hpCurrent,
				isDead		: isDead,
				
				skillList	: skillList
			};
		}
		
		
		
		/**
		 * 获取转换为Point的tile
		 */
		public function get tileP():Point { return new Point(tile.x, tile.y); }
		
		
		
		
		/**
		 * 获取技能状态信息
		 * @param skillID
		 * @return { useTime:上次使用时间, state:状态 }
		 */
		public function getSkillInfo(skillID:int):Object
		{
			if(skillList[skillID] == null) skillList[skillID] = { useTime:0, state:0 };
			return skillList[skillID];
		}
		
		
		/**
		 * 获取剩余技能CD时间
		 * @param skillID
		 * @return 
		 */
		public function getCD(skillID:int):int
		{
			var info:Object = getSkillInfo(skillID);
			var time:Number = FightConstants.CD_LIST[skillID] - (TimeUtil.getTime() - info.useTime);
			return (time < 0) ? 0 : time;
		}
		//
	}
}