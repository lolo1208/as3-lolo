package game.module.testScene.view
{
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import lolo.components.Alert;
	import lolo.components.BaseButton;
	import lolo.core.Common;
	import lolo.display.Animation;
	import lolo.display.Scene;
	
	/**
	 * 测试场景
	 * @author LOLO
	 */
	public class TestScene extends Scene implements ITestScene
	{
		/**单例的实例*/
		public static var instance:TestScene;
		
		
		public var btn1:BaseButton;
		public var btn2:BaseButton;
		public var btn3:BaseButton;
		
		private var _arr:Array;
		
		
		
		public function TestScene()
		{
			super();
			if(instance != null) return;
			instance = this;
		}
		
		
		
		override public function initialize(...args):void
		{
			initUI(Common.loader.getResByConfigName("testSceneConfig"));
			
			btn1.addEventListener(MouseEvent.CLICK, test1);
			btn2.addEventListener(MouseEvent.CLICK, test2);
			btn3.addEventListener(MouseEvent.CLICK, test3);
		}
		
		
		
		private function test1(event:MouseEvent):void
		{
			Alert.show("asdasd");
			
			return;
			
			
			var avatars:Array = ["banShouRen", "female", "jiangShi", "jinQianBao",
				"kuLouSheShou", "langRenZhanShi", "male", "shuangTouMo"];
			var actions:Array = ["attack", "dead", "run", "stand"];
			
			_arr = [];
			for(var i:int = 0; i < 200; i++)
			{
				var ani:Animation = new Animation();
				ani.sourceName = "avatar." + avatars[int(avatars.length * Math.random())]
					+ "." + actions[int(actions.length * Math.random())]
					+ int(Math.random() * 8 + 1);
				ani.x = int(Math.random() * 800) + 100;
				ani.y = int(Math.random() * 400) + 100;
				ani.fps = Math.random() * 60 + 1;
				ani.play();
				this.addChild(ani);
				
				_arr.push(ani);
			}
		}
		
		
		private function test2(event:MouseEvent):void
		{
			var t:Number = getTimer();
			for(var i:int = 0; i < _arr.length; i++) {
				this.addChild(_arr[i]);
			}
			trace(getTimer() - t);
		}
		
		
		private function test3(event:MouseEvent):void
		{
			
			var t:Number = getTimer();
			for(var i:int = 0; i < _arr.length; i++) {
				this.addChildAt(_arr[i], i);
			}
			trace(getTimer() - t);
		}
		//
	}
}