package game.module.rpgScene.controls
{
	import game.common.GameConstants;
	import game.module.rpgScene.controls.map.EnterCommand;
	import game.module.rpgScene.events.RpgUpdateEvent;
	import game.module.rpgScene.events.map.EnterEvent;
	
	import lolo.mvc.control.FrontController;
	import lolo.mvc.control.MvcEventDispatcher;

	/**
	 * 【测试场景】命令管理
	 * @author LOLO
	 */
	public class RpgSceneController extends FrontController
	{
		public function RpgSceneController()
		{
			super();
			_eventDispatcher = MvcEventDispatcher.getInstance(GameConstants.MN_SCENE_RPG);
			
			addCommand(RpgUpdateEvent.EVENT_ID, RpgUpdateCommand);
			
			addCommand(EnterEvent.EVENT_ID, EnterCommand);
		}
		//
	}
}