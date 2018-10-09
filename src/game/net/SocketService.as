package game.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import game.common.GameConstants;
	import game.module.core.events.UpdateEvent;
	
	import lolo.components.AlertText;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.RequestModel;
	import lolo.mvc.control.MvcEventDispatcher;
	import lolo.net.IService;
	import lolo.ui.Console;
	import lolo.utils.TimeUtil;
	import lolo.utils.logging.LogSampler;
	import lolo.utils.logging.Logger;
	import lolo.utils.optimize.CachePool;
	
	/**
	 * 与后台通信的TcpSocket服务
	 * @author LOLO
	 */
	public class SocketService extends Socket implements IService
	{
		/**单例的实例*/
		private static var _instance:SocketService;
		
		/**正在通信的数据模型列表（rm.command为key）*/
		private var _rmList:Dictionary;
		/**请求的代号（唯一标识符）*/
		private static var _token:Number = 0;
		
		/**当前主机地址*/
		private var _host:String = null;
		/**当前主机端口*/
		private var _port:int;
		
		/**当前要读取的数据长度*/
		private var _dataLength:int = 0;
		/**当前时间Date对象*/
		private var _date:Date;
		
		
		/**
		 * 获取单例的实例
		 * @return 
		 */
		public static function getInstance():SocketService
		{
			if(_instance == null) _instance = new SocketService(new Enforcer());
			return _instance;
		}
		
		
		
		
		public function SocketService(enforcer:Enforcer)
		{
			super();
			if(enforcer == null) {
				throw new Error("请通过Common.service获取实例");
				return;
			}
			
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		}
		
		
		
		public function send(rm:RequestModel, data:Object=null, callback:Function=null, alertError:Boolean=true):void
		{
			if(!connected) return;//还未链接
			rm.token = ++_token;
			
			//记录请求的信息
			if(_rmList[rm.command] == null) _rmList[rm.command] = [];
			_rmList[rm.command].push({
				rm			: rm,
				token		: _token,
				callback	: callback,
				alertError	: alertError,
				time		: TimeUtil.getTime(),
				sendData	: data,
				mousePoint	: CachePool.getPoint(Common.stage.mouseX, Common.stage.mouseY)
			});
			
			//请求的命令
			var command:ByteArray = new ByteArray();
			command.writeUTFBytes(rm.command);
			command.length = 32;
			
			//请求的代号
			var token:ByteArray = new ByteArray();
			token.writeInt(rm.token);
			
			//内容
			var content:ByteArray = new ByteArray();
			if(data != null) {
				//var vars:URLVariables = new URLVariables();
				//for(var key:String in data) vars[key] = data[key];
				//content.writeUTFBytes(vars.toString());
				content.writeUTFBytes(JSON.stringify(data));
			}
			
			//请求需要模态
			if(rm.modal) Common.ui.requestModal.startModal(rm);
			
			//写先入要发送的数据包的总长度，然后依次写入数据
			writeInt(command.length + token.length + content.length);
			writeBytes(command);
			writeBytes(token);
			writeBytes(content);
			flush();
		}
		
		
		public function setTimeout(rm:RequestModel):void
		{
			var msg:String = Common.language.getLanguage("010303");
			callback(false, {msg:msg}, rm.command, rm.token, true);
		}
		
		
		
		/**
		 * 收到数据
		 * @param event
		 */
		private function socketDataHandler(event:ProgressEvent=null):void
		{
			_date = TimeUtil.getDate();
			
			while(bytesAvailable > 0)
			{
				//目前还没有读到数据长度
				if(_dataLength == 0) {
					if(bytesAvailable >= 4) {
						_dataLength = readInt();
					}
					else {
						return;
					}
				}
				//缓冲区的数据长度不够
				if(bytesAvailable < _dataLength) return;
				
				
				//读取命令
				var command:String = readUTFBytes(32);
				//读取代号
				var token:Number = readInt();
				//读取内容
				var content:String;
				if(Common.config.getConfig("decompress") == "true")//需要解压数据
				{
					var contentBytes:ByteArray = new ByteArray();
					readBytes(contentBytes, 0, _dataLength - 4 - 32);
					contentBytes.uncompress();
					content = contentBytes.toString();
				}
				else {
					content = readUTFBytes(_dataLength - 4 - 32);
				}
				
				//置空当前要读取的数据长度
				_dataLength = 0;
				
				var msg:String;
				var data:Object;
				//转换数据
				try {
					data = JSON.parse(content);
				}
				catch(error:Error) {
					msg = Common.language.getLanguage("010302");
					callback(false, {msg:msg, str:content}, command, token);
					if(bytesAvailable > 0) socketDataHandler();
					return;
				}
				
				var state:int = data.state;
				//操作成功
				if(state == 1)
				{
					callback(true, data, command, token);
				}
					
				//操作异常
				else if(state == 2)
				{
					msg = Common.language.getLanguage("010304", data.errorCode);
					callback(false, {msg:msg}, command, token);
				}
					
				//后台主动推送过来的数据
				else if(state == 3)
				{
					//记录到日志中
					Logger.addNetworkLog({
						serviceType	: Constants.SERVICE_TYPE_SOCKET,
						type		: Logger.LOG_TYPE_NETWORK_PUSH,
						command		: command,
						token		: ++_token,
						data		: data
					}, _date);
					MvcEventDispatcher.dispatch(GameConstants.MN_CORE, new UpdateEvent(data, command));
				}
					
				//操作失败
				else {
					callback(false, data, command, token);
				}
				
			}
		}
		
		
		
		/**
		 * 请求已有结果，进行回调
		 * @param success 通信是否成功
		 * @param data 数据
		 * @param command 请求的命令
		 * @param token 请求的唯一代号
		 * @param timeout 通信是否超时
		 */
		private function callback(success:Boolean, data:Object, command:String, token:Number, timeout:Boolean=false):void
		{
			//查找对应的数据
			var rmData:Object;
			if(_rmList[command] != null) {
				for(var i:int=0; i < _rmList[command].length; i++)
				{
					if(_rmList[command][i].token == token)
					{
						rmData = _rmList[command][i];
						_rmList[command].splice(i, 1);
						break;
					}
				}
			}
			
			//记录到日志中
			var time:Number = rmData ? _date.time - rmData.time : 0;
			Logger.addNetworkLog({
				serviceType	: Constants.SERVICE_TYPE_SOCKET,
				type		: ((success && rmData) ? Logger.LOG_TYPE_NETWORK_SUCC : Logger.LOG_TYPE_NETWORK_FAIL),
				command		: command,
				token		: token,
				sendData	: (rmData ? rmData.sendData : "找不到这个数据包的发送和回调信息"),
				data		: data,
				time		: time
			}, _date);
			LogSampler.addNetworkSampleLog(time, Constants.SERVICE_TYPE_SOCKET, command, token);
			
			//没有对应的数据
			if(rmData == null) return;
			
			if(rmData.rm.modal) Common.ui.requestModal.endModal(rmData.rm);
			
			if(!success && rmData.alertError)
			{
				var alertText:AlertText = AlertText.getInstance("serviceError");
				alertText.x = rmData.mousePoint.x;
				alertText.y = rmData.mousePoint.y;
				alertText.show(data.msg);
			}
			CachePool.recover(rmData.mousePoint);
			
			if(rmData.callback != null) rmData.callback(success, data);
		}
		
		
		
		/**
		 * 连接成功
		 * @param event
		 */
		private function connectHandler(event:Event):void
		{
			_rmList = new Dictionary();
			//Console.trace("连接成功！");
		}
		
		
		/**
		 * 连接断开
		 * @param event
		 */
		private function closeHandler(event:Event):void
		{
			Console.trace("连接断开！");
		}
		
		
		/**
		 * 连接错误
		 * @param event
		 */
		private function errorHandler(event:Event):void
		{
			Console.trace("连接错误！", event);
		}
		
		
		
		/**
		 * 重连服务器
		 * 如果从未连接过，将会解析Common.serviceUrl进行连接
		 * 如果之前有连接过，将会重连到之前的主机
		 */
		public function reconnect():void
		{
			if(_host == null) {
				var arr:Array = Common.serviceUrl.split(":");
				connect(arr[0], arr[1]);
			}
			else {
				connect(_host, _port);
			}
		}
		
		
		
		/**
		 * 断开后，是否需要自动重连
		 */
		public function set autoReconnect(value:Boolean):void
		{
			
		}
		
		
		/**
		 * 当前主机地址
		 */
		public function get host():String { return _host; }
		
		/**
		 * 当前主机端口
		 */
		public function get port():int { return _port; }
		
		
		
		
		override public function connect(host:String, port:int):void
		{
			super.connect(host, port);
			_host = host;
			_port = port;
		}
		
		override public function close():void
		{
			if(connected) super.close();
		}
		//
	}
}


class Enforcer{}