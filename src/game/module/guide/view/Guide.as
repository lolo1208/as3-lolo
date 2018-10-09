package game.module.guide.view
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	
	/**
	 * 新手引导模块
	 * @author LOLO
	 */
	public class Guide extends Sprite implements IGuide
	{
		/**单例的实例*/
		public static var instance:Guide;
		
		
		/**模态焦点*/
		private var _modalFocus:ModalFocus;
		
		
		
		
		public function Guide()
		{
			super();
			if(instance != null) return;
			instance = this;
			initialize();
		}
		
		
		/**
		 * 初始化
		 */
		private function initialize():void
		{
			_modalFocus = new ModalFocus();
			this.addChild(_modalFocus);
		}
		
		/**
		 * 舞台尺寸有改变
		 * @param event
		 */
		private function stage_resizeHandler(event:Event=null):void
		{
			_modalFocus.resize();
		}
		
		
		
		public function addTarget(target:InteractiveObject, targetName:String):void
		{
			_modalFocus.addTarget(target, targetName);
		}
		
		
		public function setFocus(targetName:String):void
		{
			_modalFocus.setFocus(targetName);
			show();
		}
		
		
		
		public function show():void
		{
			Common.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			stage_resizeHandler();
			
			Common.ui.addChildToLayer(this, Constants.LAYER_NAME_GUIDE);
			_modalFocus.enabled = true;
		}
		
		
		
		public function hide():void
		{
			Common.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			
			Common.ui.removeChildToLayer(this, Constants.LAYER_NAME_GUIDE);
		}
		//
	}
}