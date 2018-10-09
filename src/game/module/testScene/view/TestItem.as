package game.module.testScene.view
{
	import flash.display.Shape;
	
	import lolo.components.ItemRenderer;
	import lolo.components.Label;

	public class TestItem extends ItemRenderer
	{
		private var _count:uint;
		private var _label:Label;
		private var _s:Shape;
		
		
		override public function set index(value:uint):void
		{
			super.index = value;
			
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC);
			this.graphics.drawRect(0, 0, 30, 20);
			this.graphics.endFill();
			
			if(_s == null) {
				_s = new Shape();
				this.addChild(_s);
			}
			
			if(_label == null) _label = new Label();
			_label.text = _index.toString();
			_label.x = 30 - _label.textWidth >> 1;
			_label.y = 20 - _label.textHeight >> 1;
			this.addChild(_label);
			
			if(_index == 3) {
				_s.graphics.clear();
				_s.graphics.beginFill(0xFFFFFF);
				_s.graphics.drawRect(5, 5, 20, 10);
				_s.graphics.endFill();
				
				_count++;
				_label.text = _count.toString();
			}
		}
		//
	}
}