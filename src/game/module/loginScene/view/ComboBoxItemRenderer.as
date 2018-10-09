package game.module.loginScene.view
{
	import lolo.components.BaseButton;
	import lolo.components.ItemRenderer;
	import lolo.components.Label;
	import lolo.components.ToolTip;
	import lolo.core.Common;
	import lolo.events.components.ToolTipEvent;
	import lolo.utils.AutoUtil;
	
	/**
	 * 组合框，列表，子项
	 * @author LOLO
	 */
	public class ComboBoxItemRenderer extends ItemRenderer
	{
		/**显示文本*/
		public var labelText:Label;
		/**背景按钮*/
		public var btn:BaseButton;
		
		
		public function ComboBoxItemRenderer()
		{
			super();
			AutoUtil.autoUI(this, XML( Common.loader.getResByConfigName("loginSceneConfig").comboBoxItemRenderer ));
			
			labelText.addEventListener(ToolTipEvent.SHOW, labelText_showToolTipHandler);
		}
		
		override public function set data(value:*):void
		{
			super.data = value;
			
			labelText.text = value;
		}
		
		override public function set selected(value:Boolean):void
		{
			if(btn) btn.selected = value;
		}
		
		
		/**
		 * 文本的tooltip有改变时
		 * @param event
		 */
		private function labelText_showToolTipHandler(event:ToolTipEvent):void
		{
			ToolTip.register(this, event.toolTip);
		}
		
		
		/**
		 * 在被选中时，ComboBox.label的内容
		 * @return 
		 */
		public function get label():String
		{
			return _data;
		}
		
		
		override public function dispose():void
		{
			ToolTip.unregister(this);
			
			super.dispose();
		}
		//
	}
}