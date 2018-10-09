package game.module.rpgScene.view
{
	import lolo.display.IScene;
	import lolo.rpg.map.IRpgMap;

	/**
	 * 测试场景
	 * @author LOLO
	 */
	public interface IRpgScene extends IScene
	{
		/**
		 * 地图
		 */
		function get map():IRpgMap;
		
	}
	//
}