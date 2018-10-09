package game.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import lolo.components.AlertText;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.RequestModel;
	import lolo.net.IService;
	import lolo.ui.Console;
	import lolo.utils.FrameTimer;
	import lolo.utils.TimeUtil;
	import lolo.utils.logging.LogSampler;
	import lolo.utils.logging.Logger;
	
	/**
	 * 与后台通信的HTTP服务
	 * @author LOLO
	 */
	public class HttpService implements IService
	{
		/**长连接超时时限*/
		private static const LONG_CONNECT_TIMEOUT:uint = 40000;
		
		/**单例的实例*/
		private static var _instance:HttpService;
		/**请求的代号（唯一标识符）*/
		private static var _token:Number = 0;
		
		/**通信实例列表（RequestModel为key）*/
		private var _loaderList:Dictionary;
		/**用于长连接*/
		private var _longConnect:URLStream;
		/**长连接当前要读取的数据长度*/
		private var _lcDataLength:int = 0;
		
		/**长连接当前是否已连接*/
		private var _lcConnected:Boolean;
		/**长连接在断开后，是否需要重新连接*/
		private var _lcAutoReconnect:Boolean = true;
		/**长连接已重连次数*/
		private var _lcReconnectTimes:uint = 0;
		/**长连接上次收到数据的时间*/
		private var _lcLastUpdateTime:Number;
		/**用于判定长连接超时*/
		private var _lcTimeoutTimer:FrameTimer;
		/**用于在指定时限后连接服务器*/
		private var _lcDelayConnectTimer:FrameTimer;
		
		/**是否正在请求数据*/
		private var _requesting:Boolean;
		/**还未发送的请求列表*/
		private var _requestList:Array;
		
		
		
		
		
		/**
		 * 获取单例的实例
		 * @return 
		 */
		public static function getInstance():HttpService
		{
			if(_instance == null) _instance = new HttpService(new Enforcer());
			return _instance;
		}
		
		
		
		public function HttpService(enforcer:Enforcer)
		{
			super();
			if(enforcer == null) {
				throw new Error("请通过Common.service获取实例");
				return;
			}
			
			_loaderList = new Dictionary();
			_requestList = [];
			
			_longConnect = new URLStream();
			_longConnect.addEventListener(ProgressEvent.PROGRESS, longConnect_progressHandler);
			_longConnect.addEventListener(Event.COMPLETE, longConnectReconnect);
			_longConnect.addEventListener(IOErrorEvent.IO_ERROR, longConnectReconnect);
			_longConnect.addEventListener(SecurityErrorEvent.SECURITY_ERROR, longConnectReconnect);
			
			_lcTimeoutTimer = new FrameTimer(1000 * 20, lcTimeoutTimerHandler);
			_lcDelayConnectTimer = new FrameTimer(1000 * 5, lcDelayConnectTimerHandler);
		}
		
		
		public function send(rm:RequestModel, data:Object=null, callback:Function=null, alertError:Boolean=true):void
		{
			//正在请求中，将需要发送的请求队列起来
			if(_requesting) {
				_requestList.push([rm, data, callback, alertError]);
				return;
			}
			
			_requesting = true;
			if(rm.modal) Common.ui.requestModal.startModal(rm);
			rm.token = ++_token;
			
			var loader:HttpLoader = getLoader(rm);
			loader.close();
			loader.callback = callback;
			loader.alertError = alertError;
			loader.time = TimeUtil.getTime();
			loader.sendData = data;
			
			var url:String = Common.serviceUrl + rm.command + "?t=" + rm.token;
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			
			if(data != null)
			{
				var vars:URLVariables = new URLVariables();
				for(var key:String in data) vars[key] = data[key];
				request.data = vars;
			}
			
			loader.load(request);
		}
		
		
		/**
		 * 发送下一条请求
		 */
		private function sendNextRequest():void
		{
			if(_requesting) return;
			if(_requestList.length == 0) return;
			
			if(Common.service == this) {
				send.apply(null, _requestList.shift());
			}
			else {
				//socket不用队列
				while(_requestList.length > 0) Common.service.send.apply(null, _requestList.shift());
			}
		}
		
		
		public function setTimeout(rm:RequestModel):void
		{
			getLoader(rm).close();
			var msg:String = Common.language.getLanguage("010303");
			callback(rm, false, {msg:msg}, true);
		}
		
		
		
		/**
		 * 获取数据完成
		 * @param event
		 */
		private function completeHandler(event:Event):void
		{
			var rm:RequestModel = (event.target as HttpLoader).requestModel;
			var bytes:ByteArray = event.target.data as ByteArray;
			var msg:String;
			
			//解压数据
			if(Common.config.getConfig("decompress") == "true")
			{
				try {
					bytes.uncompress();
				}
				catch(error:Error) {
					msg = Common.language.getLanguage("010301");
					callback(rm, false, {msg:msg});
					return;
				}
			}
			
			//转换数据
			var data:Object;
			try {
				data = JSON.parse(bytes.toString());
			}
			catch(error:Error) {
				msg = Common.language.getLanguage("010302");
				callback(rm, false, {msg:msg});
				return;
			}
			
			var state:int = data.state;
			//操作成功
			if(state == 1)
			{
				callback(rm, true, data);
			}
				
			//操作异常
			else if(state == 2)
			{
				msg = Common.language.getLanguage("010304", data.errorCode);
				callback(rm, false, {msg:msg});
			}
				
			//操作失败
			else {
				callback(rm, false, data);
			}
		}
		
		/**
		 * 获取数据失败
		 * @param event
		 */
		private function errorHandler(event:Event):void
		{
			var msg:String = Common.language.getLanguage("010305");
			callback(event.target.requestModel, false, {msg:msg});
		}
		
		
		
		/**
		 * 请求已有结果，进行回调
		 * @param rm 通信接口模型
		 * @param success 通信是否成功
		 * @param data 数据
		 * @param timeout 通信是否超时
		 */
		private function callback(rm:RequestModel, success:Boolean, data:Object, timeout:Boolean=false):void
		{
			var loader:HttpLoader = getLoader(rm);
			data.timeout = timeout;
			
			if(rm.modal) Common.ui.requestModal.endModal(rm);
			if(timeout) loader.close();
			
			if(!success && loader.alertError)
			{
				var alertText:AlertText = AlertText.getInstance("serviceError");
				alertText.x = loader.mousePoint.x;
				alertText.y = loader.mousePoint.y;
				alertText.show(data.msg);
			}
			
			//记录到日志中
			var date:Date = TimeUtil.getDate();
			var time:Number = date.time - loader.time;
			Logger.addNetworkLog({
				serviceType	: Constants.SERVICE_TYPE_HTTP,
				type		: (success ? Logger.LOG_TYPE_NETWORK_SUCC : Logger.LOG_TYPE_NETWORK_FAIL),
				command		: loader.requestModel.command,
				token		: loader.requestModel.token,
				sendData	: loader.sendData,
				data		: data,
				time		: time
			}, date);
			LogSampler.addNetworkSampleLog(time, Constants.SERVICE_TYPE_HTTP, loader.requestModel.command, loader.requestModel.token);
			
			try {
				if(loader.callback != null) loader.callback(success, data);
			}
			catch(error:Error) {}
			
			//继续发送队列中的请求
			_requesting = false;
			sendNextRequest();
		}
		
		
		
		
		/**
		 * 长连接收到数据
		 * @param event
		 */
		private function longConnect_progressHandler(event:ProgressEvent=null):void
		{
			if(!_lcConnected) {
				_lcConnected = true;
				_lcReconnectTimes = 0;
			}
			
			var date:Date = TimeUtil.getDate();
			_lcLastUpdateTime = date.time;
			
			while(_longConnect.bytesAvailable > 0)
			{
				//目前还没有读到数据长度
				if(_lcDataLength == 0) {
					if(_longConnect.bytesAvailable >= 4) {
						_lcDataLength = _longConnect.readInt();
						if(_lcDataLength == 0) return;
					}
					else {
						return;
					}
				}
				
				//缓冲区的数据长度不够
				if(_longConnect.bytesAvailable < _lcDataLength) return;
				
				
				//读取数据
				var bytes:ByteArray = new ByteArray();
				_longConnect.readBytes(bytes, 0, _lcDataLength);
				
				//数据包长度
				var dataLength:int = bytes.readInt();
				//读取命令
				var command:String = bytes.readUTFBytes(32);
				//读取代号
				var token:Number = bytes.readInt();
				//读取内容
				var content:String;
				if(Common.config.getConfig("decompress") == "true")//需要解压数据
				{
					var contentBytes:ByteArray = new ByteArray();
					bytes.readBytes(contentBytes, 0, dataLength - 4 - 32);
					contentBytes.uncompress();
					content = contentBytes.toString();
				}
				else {
					content = bytes.readUTFBytes(dataLength - 4 - 32);
				}
				
				//置空当前要读取的数据长度
				_lcDataLength = 0;
				
				var msg:String;
				var data:Object;
				//转换数据
				try {
					data = JSON.parse(content);
				}
				catch(error:Error) {
					msg = Common.language.getLanguage("010302");
					data = { msg:msg };
				}
				
				if(data != null) {
					
				}
				
				//记录到日志中
				Logger.addNetworkLog({
					serviceType	: Constants.SERVICE_TYPE_HTTP,
					type		: Logger.LOG_TYPE_NETWORK_PUSH,
					command		: command,
					token		: ++_token,
					data		: data
				}, date);
			}
		}
		
		
		/**
		 * 长连接重连
		 * @param event
		 * @param delay 是否需要延时后再连接
		 */
		public function longConnectReconnect(event:Event=null, delay:Boolean=true):void
		{
			var str:String = (event != null) ? (event.type + "  之前剩余数据长度：" + _longConnect.bytesAvailable) : "";
			Console.trace("HTTP长连接重连", str);
			
			if(event != null) _lcConnected = false;
			if(_lcConnected) return;
			if(!_lcAutoReconnect) return;
			
			if(_lcReconnectTimes < 30) {
				delay ? _lcDelayConnectTimer.start() : lcDelayConnectTimerHandler();
				_lcLastUpdateTime = TimeUtil.getTime();
				_lcTimeoutTimer.start();
			}
		}
		
		/**
		 * 在指定的间隔后，进行长连接
		 */
		private function lcDelayConnectTimerHandler():void
		{
			_lcDelayConnectTimer.reset();
			_lcReconnectTimes++;
		}
		
		/**
		 * 长连接超时判定
		 */
		private function lcTimeoutTimerHandler():void
		{
			var time:Number = TimeUtil.getTime();
			if(time - _lcLastUpdateTime > LONG_CONNECT_TIMEOUT) {
				_lcTimeoutTimer.reset();
				longConnectReconnect(null, false);
			}
		}
		
		/**
		 * 长连接在断开后，是否需要重新连接
		 */
		public function set lcAutoReconnect(value:Boolean):void
		{
			_lcAutoReconnect = value;
			if(!value) _lcDelayConnectTimer.reset();
		}
		public function get lcAutoReconnect():Boolean { return _lcAutoReconnect; }
		
		/**
		 * 长连接当前是否已连接
		 */
		public function get lcConnected():Boolean { return _lcConnected; }
		
		
		
		
		/**
		 * 通过rm获取对应的HttpLoader
		 * @param rm
		 */
		private function getLoader(rm:RequestModel):HttpLoader
		{
			if(_loaderList[rm] == null)
			{
				var loader:HttpLoader = new HttpLoader(rm);
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_loaderList[rm] = loader;
			}
			return _loaderList[rm];
		}
		//
	}
}


class Enforcer{}