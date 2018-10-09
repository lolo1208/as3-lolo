package game.module.rpgScene.model
{
	import flash.utils.Dictionary;
	
	import lolo.core.Common;

	/**
	 * 特效动画VO
	 * @author LOLO
	 */
	public class EffectVO
	{
		/**已解析好的VO列表*/
		private static var _voList:Dictionary;
		
		
		/**特效ID*/
		public var id:String;
		/**特效动画sourceName*/
		public var sourceName:String;
		/**特效动画FPS*/
		public var fps:uint;
		
		
		
		
		public static function getVO(id:String):EffectVO
		{
			if(_voList == null)
			{
				_voList = new Dictionary();
				var children:XMLList = XML(Common.loader.getResByConfigName("fightConfig").effects).item;
				for each(var item:XML in children)
				{
					var vo:EffectVO = new EffectVO();
					vo.id			= String(item.@id);
					vo.sourceName	= String(item.@sn);
					vo.fps			= uint(item.@fps);
					_voList[vo.id] = vo;
				}
			}
			
			return _voList[id];
		}
		//
	}
}