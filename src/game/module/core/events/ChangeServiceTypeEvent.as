package game.module.core.events
{
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 更改后台服务类型
	 * @author LOLO
	 */
	public class ChangeServiceTypeEvent extends MvcEvent
	{
		/**事件的ID*/
		public static const EVENT_ID:String = "core.ChangeServiceTypeEvent";
		
		
		/**要切换至的类型*/
		public var serviceType:String;
		/**指定的Url*/
		public var serviceUrl:String;
		
		
		public function ChangeServiceTypeEvent(serviceType:String="", serviceUrl:String="")
		{
			super(EVENT_ID);
			this.serviceType = serviceType;
			this.serviceUrl = serviceUrl;
		}
		//
	}
}