package game.module.core.controls
{
	import game.module.core.events.ConsoleEvent;
	
	import lolo.core.Common;
	import lolo.data.RequestModel;
	import lolo.mvc.command.ICommand;
	import lolo.mvc.control.MvcEvent;
	import lolo.ui.Console;
	
	/**
	 * 处理控制台推送过来的数据
	 * @author LOLO
	 */
	public class ConsoleCommand implements ICommand
	{
		/**控制台推送过来的内容*/
		private var _content:String;
		
		
		public function execute(event:MvcEvent):void
		{
			_content = (event as ConsoleEvent).data;
			
			//发送GM指令
			if(_content.charAt(0) == "#")
			{
				return;
			}
			
			
			//前端命令
			var arr:Array = _content.split(" ");
			var args:Array = [];
			var len:int = arr.length;
			for(var i:int = 0; i < len; i++) if(arr[i] != "") args.push(arr[i]);
			if(args.length == 0) args[0] = "";
			
			switch(args[0].toLocaleLowerCase())
			{
				case "send":
					var sendData:Object;
					if(args[2] != null) {
						try {
							sendData = JSON.parse(args[2]);
						}
						catch(error:Error) {
							Console.trace("要发送的数据JSON格式有误！");
							return;
						}
					}
					Common.service.send(new RequestModel(args[1]), sendData, result_sendData);
					break;
				
				
				case "帮助": case "help": case "h":
					showHelp();
					break;
			}
		}
		
		
		
		
		
		
		/**
		 * 发送数据的结果
		 * @param success
		 * @param data
		 */
		private function result_sendData(success:Boolean, data:Object):void
		{
			Console.appendText(JSON.stringify(data));
		}
		
		
		
		/**
		 * 显示前端命令的帮助信息
		 */
		private function showHelp():void
		{
			Console.getInstance().outputText.htmlText = "" +
				"<b>前端命令列表：</b><font size='12'>" +
				
				"\n\n</font>框架：<font size='12'>" +
				"\n  log           显示日志。参数1:日志类型(可选)[na,ns,bf,np,debug,info,warn,error,fatal,或其他]" +
				"\n  stats         显示或隐藏统计信息。统计面板可双击锁定透明度，可拖动" +
				"\n  gc            强制回收垃圾内存。可多敲几遍，确保回收成功" +
				"\n  sysinfo       显示系统信息" +
				"\n  html          以html形式显示控制台输出文本的内容" +
				"\n  cmd           显示最近的15条CMD历史记录" +
				"\n  illog         显示ImageLoader的缓存情况" +
				"\n  bmclog        显示BitmapMovieClip的缓存情况" +
				"\n  anilog        显示Animation的缓存情况" +
				"\n  bslog         显示BitmapSprite的缓存情况" +
				
				"\n\n</font>游戏：<font size='12'>" +
				"\n  send          发送数据包。参数1:接口名，参数2:要发送数据的json字符串(可选)" +
				
				"\n\n</font>RpgMap：<font size='12'>" +
				"\n  tile          显示或隐藏区块。参数1:任意字符，表示是否显示区块坐标(可选)" +
				"\n  avatar key    显示角色的key" +
				"\n  avatar speed  显示角色的移动速度" +
				"\n  avatar tile   显示角色当前所在的区块坐标" +
				
				"</font>";
		}
		//
	}
}