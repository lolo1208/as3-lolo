package game.module.loginScene.controls
{
	import game.common.RmList;
	import game.module.loginScene.events.RegisterEvent;
	
	import lolo.core.Common;
	import lolo.components.Alert;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 注册帐号
	 * @author LOLO
	 */
	public class RegisterCommand implements ICommand
	{
		
		public function execute(event:MvcEvent):void
		{
			var e:RegisterEvent = event as RegisterEvent;
			
			var data:Object = { username:e.username, password:e.password };
			Common.service.send(RmList.USER_REGISTER, data, result);
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
				Alert.show("注册成功！");
			}
		}
		//
	}
}