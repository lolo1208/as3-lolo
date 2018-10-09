package game.module.core.model
{
	

	/**
	 * 控制台数据
	 * @author LOLO
	 */
	public class ConsoleData
	{
		/**单例的实例*/
		private static var _instance:ConsoleData;
		
		/**
		 * 获取实例
		 * @return 
		 */
		public static function getInstance():ConsoleData
		{
			if(_instance == null) _instance = new ConsoleData();
			return _instance;
		}
		//
	}
}