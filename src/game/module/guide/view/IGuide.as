package game.module.guide.view
{
	import flash.display.InteractiveObject;
	

	/**
	 * 新手引导模块接口
	 * @author LOLO
	 */
	public interface IGuide
	{
		/**
		 * 添加一个会模态焦点的目标
		 * @param target 目标
		 * @param targetName 目标的名称
		 */
		function addTarget(target:InteractiveObject, targetName:String):void;
		
		
		/**
		 * 设置模态焦点目标
		 * @param targetName 目标的名称
		 */
		function setFocus(targetName:String):void;
		
		
		
		/**
		 * 显示
		 */
		function show():void;
		
		
		/**
		 * 隐藏
		 */
		function hide():void;
		//
	}
}