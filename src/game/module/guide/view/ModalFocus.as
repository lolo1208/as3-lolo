package game.module.guide.view
{
	import com.greensock.TweenMax;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	
	
	/**
	 * 模态焦点
	 * @author LOLO
	 */
	public class ModalFocus extends Sprite
	{
		/**已注册的焦点目标列表*/
		private var _targetList:Dictionary;
		
		/**黑色背景*/
		private var _blackBG:Bitmap;
		/**焦点区域白框*/
		private var _focusRect:Bitmap;
		
		/**是否启用*/
		private var _enabled:Boolean;
		
		/**焦点目标*/
		private var _target:InteractiveObject;
		/**焦点目标在舞台的位置*/
		private var _rect:Rectangle;
		
		
		
		public function ModalFocus()
		{
			super();
			_rect = new Rectangle();
			_targetList = new Dictionary();
			
			var bd:BitmapData = new BitmapData(1, 1, false, 0);
			
			_blackBG = new Bitmap(bd);
			_blackBG.alpha = 0.5;
			this.addChild(_blackBG);
			
			_focusRect = new Bitmap(bd);
			this.addChild(_focusRect);
			
			this.alpha = 0;
			this.blendMode = BlendMode.LAYER;
			_focusRect.blendMode = BlendMode.ERASE;
		}
		
		
		/**
		 * 添加一个会模态焦点的目标
		 * @param target 目标
		 * @param targetName 目标的名称
		 */
		public function addTarget(target:InteractiveObject, targetName:String):void
		{
			if(_targetList[targetName] != null)
			{
				throw new Error("已存在名称为：" + targetName + " 的模态焦点！");
				return;
			}
			_targetList[targetName] = target;
		}
		
		
		/**
		 * 设置模态焦点目标
		 * @param targetName 目标的名称
		 */
		public function setFocus(targetName:String):void
		{
			_target = _targetList[targetName];
			
			if(_target == null)
			{
				throw new Error("指定的模态焦点：" + targetName + " 并不存在！");
				return;
			}
			
			calculateRect();
		}
		
		
		/**
		 * 计算出焦点目标在舞台上的矩形
		 */
		private function calculateRect():void
		{
			if(_target == null) return;
			
			_rect = _target.getBounds(Common.stage);
			_focusRect.x = _rect.x;
			_focusRect.y = _rect.y;
			_focusRect.width = _rect.width;
			_focusRect.height = _rect.height;
		}
		
		
		/**
		 * 舞台尺寸有改变
		 */
		public function resize():void
		{
			_blackBG.width = Common.ui.stageWidth;
			_blackBG.height = Common.ui.stageHeight;
			calculateRect();
		}
		
		
		
		/**
		 * 是否启用
		 */
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			if(_enabled) {
				Common.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, true, 999);
				this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
			else {
				Common.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, true);
				this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}
		
		
		/**
		 * 鼠标在舞台移动
		 * @param event
		 */
		private function stage_mouseMoveHandler(event:MouseEvent):void
		{
			var x:int = Common.stage.mouseX;
			if(x > _rect.x && x < _rect.width + _rect.x) {
				var y:int = Common.stage.mouseY;
				if(y > _rect.y && y < _rect.height + _rect.y) {
					mouseEnabled = mouseChildren = false;
					return;
				}
			}
			mouseEnabled = true;
		}
		
		
		/**
		 * 鼠标按下
		 * @param event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if(!mouseEnabled) return;
			
			TweenMax.killTweensOf(_focusRect);
			_focusRect.width = _rect.width * 2.8;
			_focusRect.height = _rect.height * 2.8;
			_focusRect.x = _rect.x - (_focusRect.width - _rect.width) / 2;
			_focusRect.y = _rect.y - (_focusRect.height - _rect.height) / 2;
			TweenMax.to(_focusRect, 0.5,
				{ x:_rect.x, y:_rect.y, width:_rect.width, height:_rect.height,onComplete:showEffectEnd }
			);
			
			TweenMax.killTweensOf(this);
			this.alpha = 0;
			TweenMax.to(this, 0.3, { alpha:1 });
		}
		
		private function showEffectEnd():void
		{
			TweenMax.to(this, 0.3, { alpha:0, delay:0.1 });
		}
		//
	}
}