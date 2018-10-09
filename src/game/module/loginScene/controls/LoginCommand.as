package game.module.loginScene.controls
{
	import game.common.RmList;
	import game.module.loginScene.events.LoginEvent;
	
	import lolo.core.Common;
	import lolo.data.SO;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 登录游戏
	 * @author LOLO
	 */
	public class LoginCommand implements ICommand
	{
		private var _e:LoginEvent;
		
		
		public function execute(event:MvcEvent):void
		{
			_e = event as LoginEvent;
			
			var data:Object = { username:_e.username, password:_e.password };
			Common.service.send(RmList.USER_LOGION, data, result);
		}
		
		
		/**
		 * 向后端发送请求的结果
		 * @param success
		 * @param data
		 */
		private function result(success:Boolean, data:Object):void
		{
			if(success)
			{
				SO.data.login.username = _e.username;
				SO.data.login.password = _e.password;
				SO.save();
			}
		}
		//
	}
}