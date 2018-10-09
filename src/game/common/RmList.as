package game.common
{
	import lolo.data.RequestModel;

	/**
	 * 与后台通信的数据模型列表
	 * @author LOLO
	 */
	public class RmList
	{
		/**注册帐号*/
		public static const USER_REGISTER:RequestModel = new RequestModel("user!register");
		/**登录游戏*/
		public static const USER_LOGION:RequestModel = new RequestModel("user!login");
		
		
		
		public static const MAP_ENTER:RequestModel = new RequestModel("map@enter", false);
		public static const MAP_MOVE:RequestModel = new RequestModel("map@move", false);
		
		public static const FIGHT_ATTACK:RequestModel = new RequestModel("fight@attack", false);
		public static const FIGHT_LEI_DIAN:RequestModel = new RequestModel("fight@leiDian", false);
		//
	}
}