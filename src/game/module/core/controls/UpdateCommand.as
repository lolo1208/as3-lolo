package game.module.core.controls
{
	import flash.utils.Dictionary;
	
	import game.common.GameConstants;
	import game.module.core.events.UpdateEvent;
	import game.module.rpgScene.events.RpgUpdateEvent;
	
	import lolo.core.Common;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	import lolo.mvc.control.MvcEventDispatcher;
	
	/**
	 * 后端主动推送过来的更新数据
	 * @author LOLO
	 */
	public class UpdateCommand implements ICommand
	{
		/**
		 * 处理命令的映射列表
		 * _commands[conmand] =
		 * {
		 * 	dispatcherName:String	命令的派发器名称，一般为所在模块的名称
		 * 	commandEvent:MvcEvent	命令的事件类，构造函数的第一个参数必须为data:Object
		 * 	sceneNameList:Array		触发场景名称列表，值为null时在所有场景都会触发
		 * }
		 */
		private static var _commands:Dictionary;
		
		
		
		
		public function UpdateCommand():void
		{
			if(_commands != null) return;
			_commands = new Dictionary();
			
			//RPG数据更新
			_commands["rpg@update"] = {
				dispatcherName	: GameConstants.MN_SCENE_RPG,
				commandEvent	: RpgUpdateEvent,
				sceneNameList	: [GameConstants.MN_SCENE_RPG]
			};
		}
		
		
		
		
		
		public function execute(event:MvcEvent):void
		{
			//命令的相关数据
			var info:Object = _commands[(event as UpdateEvent).command];
			if(info == null) return;
			
			//在所有场景触发
			var inScene:Boolean;
			if(info.sceneNameList == null) {
				inScene = true;
			}
			//在指定场景触发
			else {
				for(var i:int=0; i < info.sceneNameList.length; i++) {
					if(info.sceneNameList[i] == Common.ui.currentSceneName) {
						inScene = true;
						break;
					}
				}
			}
			
			if(inScene) {
				MvcEventDispatcher.dispatch(info.dispatcherName, new info.commandEvent(event.data));
			}
		}
		//
	}
}