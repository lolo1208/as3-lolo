package game.module.loginScene.view
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import game.common.GameConstants;
	import game.module.core.events.ChangeServiceTypeEvent;
	import game.module.loginScene.controls.LoginSceneController;
	import game.module.loginScene.events.LoginEvent;
	import game.module.loginScene.events.RegisterEvent;
	
	import lolo.components.Button;
	import lolo.components.ComboBox;
	import lolo.components.InputText;
	import lolo.components.ItemGroup;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.HashMap;
	import lolo.data.SO;
	import lolo.display.Scene;
	import lolo.events.components.ListEvent;
	import lolo.mvc.control.MvcEventDispatcher;
	import lolo.utils.Validator;

	/**
	 * 登录场景
	 * @author LOLO
	 */
	public class LoginScene extends Scene implements ILoginScene
	{
		/**单例的实例*/
		public static var instance:LoginScene;
		
		/**帐号输入框*/
		public var usernameIT:InputText;
		/**密码输入框*/
		public var passwordIT:InputText;
		/**后端服务组合框*/
		public var serviceCMB:ComboBox;
		/**连接类型组*/
		public var typeGroup:ItemGroup;
		/**连接按钮*/
		public var connBtn:Button;
		/**注册按钮*/
		public var registerBtn:Button;
		/**登录按钮*/
		public var loginBtn:Button;
		
		
		public function LoginScene()
		{
			super();
			if(instance != null) return;
			instance = this;
		}
		
		
		override public function initialize(...args):void
		{
			new LoginSceneController();
			initUI(Common.loader.getResByConfigName("loginSceneConfig"));
			serviceCMB.list.itemRendererClass = ComboBoxItemRenderer;
			
			
			//显示默认的帐号密码
			if(SO.data.login != null) {
				usernameIT.text = SO.data.login.username;
				passwordIT.text = SO.data.login.password;
			}
			else {
				SO.data.login = {};
			}
			
			//设置默认的连接方式
			typeGroup.addEventListener(ListEvent.ITEM_SELECTED, typeGroup_itemSelectedHandler);
			typeGroup.selectItemByIndex((SO.data.login.serviceType != null) ? SO.data.login.serviceType : 0);
			
			//显示默认的ServiceUrl
			serviceCMB.label = Common.serviceUrl;
			
			//显示服务器列表
			var arr:Array = Common.config.getConfig("serviceList").split(",");
			var serviceList:HashMap = new HashMap();
			for(var i:int = 0; i < arr.length; i++)
			{
				serviceList.add(arr[i], arr[i]);
			}
			serviceCMB.list.data = serviceList;
			serviceCMB.list.addEventListener(ListEvent.ITEM_SELECTED, setServiceUrl);
			connBtn.addEventListener(MouseEvent.CLICK, setServiceUrl);
			
			registerBtn.addEventListener(MouseEvent.CLICK, registerBtn_clickHandler);
			loginBtn.addEventListener(MouseEvent.CLICK, loginBtn_clickHandler);
		}
		
		
		
		/**
		 * 服务类型有改变
		 * @param event
		 */
		private function typeGroup_itemSelectedHandler(event:ListEvent):void
		{
			SO.data.login.serviceType = event.item.index;
			
			var url:String;
			if(event.item.data == Constants.SERVICE_TYPE_SOCKET) {
				url = (SO.data.login.socketUrl != null) ? SO.data.login.socketUrl : Common.config.getConfig("socketServiceUrl");
			}
			else {
				url = (SO.data.login.httpUrl != null) ? SO.data.login.httpUrl : Common.config.getConfig("httpServiceUrl");
			}
			serviceCMB.label = url;
			
			MvcEventDispatcher.dispatch(GameConstants.MN_CORE, new ChangeServiceTypeEvent(event.item.data, url));
		}
		
		
		/**
		 * 设置后台服务器的网络地址
		 * @param event
		 */
		private function setServiceUrl(event:Event=null):void
		{
			if(serviceCMB.label == Common.serviceUrl) return;
			if(event as ListEvent && (event as ListEvent).item == null) return;
			
			var url:String = serviceCMB.label;
			(Common.serviceType == Constants.SERVICE_TYPE_SOCKET) ? (SO.data.login.socketUrl = url) : (SO.data.login.httpUrl = url);
			
			MvcEventDispatcher.dispatch(GameConstants.MN_CORE, new ChangeServiceTypeEvent(Common.serviceType, url));
		}
		
		
		
		
		/**
		 * 在帐号输入框，或密码输入框按下按键
		 * @param event
		 */
		private function inputText_keyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == 13)//回车
			{
				if(event.currentTarget == usernameIT) {
					if(stage) stage.focus = passwordIT;
				}
				else {
					if(stage) stage.focus = this;
					loginBtn_clickHandler();
				}
			}
		}
		
		
		
		/**
		 * 点击注册按钮
		 * @param event
		 */
		private function registerBtn_clickHandler(event:MouseEvent):void
		{
			if(Validator.noSpace(usernameIT.text) && Validator.noSpace(passwordIT.text))
			{
				MvcEventDispatcher.dispatch(GameConstants.MN_SCENE_LOGIN, new RegisterEvent(usernameIT.text, passwordIT.text));
			}
		}
		
		/**
		 * 点击登录按钮
		 * @param event
		 */
		private function loginBtn_clickHandler(event:MouseEvent=null):void
		{
			if(Validator.noSpace(usernameIT.text) && Validator.noSpace(passwordIT.text))
			{
				MvcEventDispatcher.dispatch(GameConstants.MN_SCENE_LOGIN, new LoginEvent(usernameIT.text, passwordIT.text));
			}
		}
		
		
		
		override protected function startup():void
		{
			stage.focus = usernameIT;
			usernameIT.addEventListener(KeyboardEvent.KEY_DOWN, inputText_keyDownHandler);
			passwordIT.addEventListener(KeyboardEvent.KEY_DOWN, inputText_keyDownHandler);
			
			super.startup();
		}
		
		
		override protected function reset():void
		{
			usernameIT.removeEventListener(KeyboardEvent.KEY_DOWN, inputText_keyDownHandler);
			passwordIT.removeEventListener(KeyboardEvent.KEY_DOWN, inputText_keyDownHandler);
			
			super.reset();
		}
		//
	}
}