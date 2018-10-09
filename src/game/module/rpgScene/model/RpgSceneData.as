package game.module.rpgScene.model
{
	import lolo.utils.bind.Data;
	
	/**
	 * 【测试场景】数据
	 * @author LOLO
	 */
	public class RpgSceneData extends Data
	{
		/**默认地图ID*/
		public static const DEFAULT_MAP_ID:String = "203";
		
		
		/**当前角色在 rpgMap 中的 key*/
		public var roleKey:String;
		
		
		
		
		/**数据更新*/
		public function set update(value:int):void { setProperty("update", value); }
		public function get update():int { return getProperty("update"); }
		
		
		
		
		
		/**单例的实例*/
		private static var _instance:RpgSceneData = null;
		/**获取实例*/
		public static function getInstance():RpgSceneData
		{
			if(_instance == null) _instance = new RpgSceneData();
			return _instance;
		}
		//
	}
}