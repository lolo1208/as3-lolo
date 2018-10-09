package game.module.testScene.view
{
	import game.module.rpgScene.model.RpgSceneData;
	
	import lolo.utils.bind.Data;

	public class TestData extends Data
	{
		
		
		
		
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