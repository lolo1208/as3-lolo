package game.module.core.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 后端主动推送过来的更新数据
	 * @author LOLO
	 */
	public class UpdateEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "core.UpdateEvent";
		
		
		public var command:String;
		
		
		public function UpdateEvent(data:*=null, command:String=null)
		{
			super(EVENT_ID);
			this.data = data;
			this.command = command;
		}
		//
	}
}