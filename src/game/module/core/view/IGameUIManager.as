package game.module.core.view
{
	import game.module.guide.view.IGuide;
	
	import lolo.core.IUIManager;

	/**
	 * 游戏用户界面管理
	 * @author LOLO
	 */
	public interface IGameUIManager extends IUIManager
	{
		/**
		 * 新手指导模块
		 */
		function get guide():IGuide;
		
		
		
		/**
		 * 加载Rpg地图
		 * @param id 地图的ID
		 * @param callback 地图加载完成后的回调
		 */
		function loadRpgMap(id:String, callback:Function=null):void;
		//
	}
}