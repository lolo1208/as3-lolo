package game.module.loginScene.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 登录游戏
	 * @author LOLO
	 */
	public class LoginEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "loginScene.LoginEvent";
		
		/**帐号*/
		public var username:String;
		/**密码*/
		public var password:String;
		
		
		public function LoginEvent(username:String="", password:String="")
		{
			super(EVENT_ID);
			this.username = username;
			this.password = password;
		}
		//
	}
}