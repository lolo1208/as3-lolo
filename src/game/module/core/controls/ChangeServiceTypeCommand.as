package game.module.core.controls
{
	import game.module.core.events.ChangeServiceTypeEvent;
	import game.net.HttpService;
	import game.net.SocketService;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	
	/**
	 * 更改后台服务类型
	 * @author LOLO
	 */
	public class ChangeServiceTypeCommand implements ICommand
	{
		public function execute(event:MvcEvent):void
		{
			var serviceType:String = (event as ChangeServiceTypeEvent).serviceType;
			var serviceUrl:String = (event as ChangeServiceTypeEvent).serviceUrl;
			var socket:SocketService = SocketService.getInstance();
			var http:HttpService = HttpService.getInstance();
			
			Common.serviceType = serviceType;
			
			//socket服务
			if(serviceType == Constants.SERVICE_TYPE_SOCKET) {
				Common.serviceUrl = (serviceUrl != "") ? serviceUrl : Common.config.getConfig("socketServiceUrl");
				Common.service = socket;
				
				if(serviceUrl != "") {
					var arr:Array = serviceUrl.split(":");
					socket.connect(arr[0], arr[1]);
				}
				else {
					socket.reconnect();
				}
			}
				//http服务
			else {
				Common.serviceUrl = (serviceUrl != null) ? serviceUrl : Common.config.getConfig("httpServiceUrl");
				Common.service = http;
				socket.close();
			}
		}
		//
	}
}