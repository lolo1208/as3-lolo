package game.module.rpgScene.actions.notice
{
	import game.module.rpgScene.actions.IAction;
	
	import lolo.components.Label;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.effects.float.UpFloat;
	
	/**
	 * 屏幕中间显示的提示（901）
	 * @author LOLO
	 */
	public class Tips implements IAction
	{
		
		public function execute(data:Object):void
		{
			var label:Label = new Label();
			label.stroke = "0x0";
			label.color = 0xCC0000;
			label.size = 14;
			label.text = data.msg;
			
			label.x = Common.ui.stageWidth - label.textWidth >> 1;
			label.y = Common.ui.stageHeight - 150;
			Common.ui.addChildToLayer(label, Constants.LAYER_NAME_ALERT);
			
			new UpFloat(label).step3_delay = 1;
		}
		//
	}
}