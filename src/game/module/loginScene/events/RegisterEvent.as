package game.module.loginScene.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 注册帐号
	 * @author LOLO
	 */
	public class RegisterEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "loginScene.RegisterEvent";
		
		/**帐号*/
		public var username:String;
		/**密码*/
		public var password:String;
		
		
		public function RegisterEvent(username:String="", password:String="")
		{
			super(EVENT_ID);
			this.username = username;
			this.password = password;
		}
		//
	}
}