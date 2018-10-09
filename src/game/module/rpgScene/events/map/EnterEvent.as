package game.module.rpgScene.events.map
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 进入地图
	 * @author LOLO
	 */
	public class EnterEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "map.EnterEvent";
		
		
		public function EnterEvent(data:Object=null)
		{
			super(EVENT_ID, data);
		}
		//
	}
}