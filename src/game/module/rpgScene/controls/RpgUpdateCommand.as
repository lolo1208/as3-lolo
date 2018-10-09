package game.module.rpgScene.controls
{
	import flash.utils.Dictionary;
	
	import game.module.rpgScene.actions.IAction;
	import game.module.rpgScene.actions.fight.Attack;
	import game.module.rpgScene.actions.fight.ChangeHP;
	import game.module.rpgScene.actions.fight.Dead;
	import game.module.rpgScene.actions.fight.PreSkill;
	import game.module.rpgScene.actions.map.Avatars;
	import game.module.rpgScene.actions.map.ChangeDirection;
	import game.module.rpgScene.actions.map.Enter;
	import game.module.rpgScene.actions.map.Leave;
	import game.module.rpgScene.actions.map.Move;
	import game.module.rpgScene.actions.map.Stand;
	import game.module.rpgScene.actions.notice.Tips;
	import game.module.rpgScene.actions.skill.LeiDian;
	
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * RPG数据更新
	 * @author LOLO
	 */
	public class RpgUpdateCommand implements ICommand
	{
		private static var _actions:Dictionary;
		
		
		
		public function execute(event:MvcEvent):void
		{
			var data:Object = event.data;
			var action:IAction = new _actions[data.action]();
			action.execute(data);
		}
		
		
		
		public function RpgUpdateCommand()
		{
			if(_actions != null) return;
			_actions = new Dictionary();
			
			_actions[101]	= Enter;
			_actions[102]	= Leave;
			_actions[103]	= Avatars;
			_actions[104]	= Move;
			_actions[105]	= ChangeDirection;
			_actions[106]	= Stand;
			
			_actions[201]	= Attack;
			_actions[202]	= ChangeHP;
			_actions[203]	= Dead;
			_actions[204]	= PreSkill;
			
			_actions[301]	= LeiDian;
			
			_actions[901]	= Tips;
		}
		//
	}
}