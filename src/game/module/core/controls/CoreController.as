package game.module.core.controls
{
	import game.common.GameConstants;
	import game.module.core.events.ChangeServiceTypeEvent;
	import game.module.core.events.ConsoleEvent;
	import game.module.core.events.UpdateEvent;
	
	import lolo.mvc.control.FrontController;
	import lolo.mvc.control.MvcEventDispatcher;

	/**
	 * 【游戏核心】命令管理
	 * @author LOLO
	 */
	public class CoreController extends FrontController
	{
		public function CoreController()
		{
			super();
			_eventDispatcher = MvcEventDispatcher.getInstance(GameConstants.MN_CORE);
			
			
			addCommand(ConsoleEvent.EVENT_ID, ConsoleCommand);
			addCommand(ChangeServiceTypeEvent.EVENT_ID, ChangeServiceTypeCommand);
			
			addCommand(UpdateEvent.EVENT_ID, UpdateCommand);
		}
		//
	}
}