package game.module.core.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 处理控制台推送过来的数据
	 * @author LOLO
	 */
	public class ConsoleEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "core.ConsoleEvent";
		
		
		public function ConsoleEvent(data:*=null)
		{
			super(EVENT_ID);
			this.data = data;
		}
		//
	}
}