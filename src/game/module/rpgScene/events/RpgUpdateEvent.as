package game.module.rpgScene.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * RPG数据更新
	 * @author LOLO
	 */
	public class RpgUpdateEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "rpgScene.RpgUpdateEvent";
		
		
		public function RpgUpdateEvent(data:Object=null)
		{
			super(EVENT_ID, data);
		}
		//
	}
}