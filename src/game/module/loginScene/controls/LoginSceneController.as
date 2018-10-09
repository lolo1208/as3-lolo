package game.module.loginScene.controls
{
	import game.common.GameConstants;
	import game.module.loginScene.events.LoginEvent;
	import game.module.loginScene.events.RegisterEvent;
	
	import lolo.mvc.control.FrontController;
	import lolo.mvc.control.MvcEventDispatcher;

	/**
	 * 【登录场景】命令管理
	 * @author LOLO
	 */
	public class LoginSceneController extends FrontController
	{
		public function LoginSceneController()
		{
			super();
			_eventDispatcher = MvcEventDispatcher.getInstance(GameConstants.MN_SCENE_LOGIN);
			
			
			addCommand(RegisterEvent.EVENT_ID, RegisterCommand);
			addCommand(LoginEvent.EVENT_ID, LoginCommand);
		}
		//
	}
}