package game.module.rpgScene.manager
{
	import com.greensock.TweenMax;
	
	import flash.geom.Point;
	
	import game.common.GameConstants;
	import game.common.RmList;
	import game.module.rpgScene.model.AvatarData;
	import game.module.rpgScene.model.FightConstants;
	import game.module.rpgScene.model.RpgSceneData;
	import game.module.rpgScene.view.IRpgScene;
	
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.Wayfinding;
	import lolo.rpg.avatar.IAvatar;
	import lolo.rpg.events.AvatarEvent;
	import lolo.rpg.events.RpgMapEvent;
	import lolo.rpg.map.IRpgMap;
	import lolo.rpg.map.MapBackground;
	import lolo.utils.FrameTimer;

	/**
	 * 移动控制器
	 * @author LOLO
	 */
	public class MoveManager
	{
		/**单例的实例*/
		private static var _instance:MoveManager;
		
		/**玩家的主角*/
		private var _avatar:IAvatar;
		/**需要移动的路径*/
		private var _road:Array = [];
		
		/**是否在攻击动画播放完成时，需要追击*/
		private var _chase:Boolean;
		
		/**地图*/
		private var _map:IRpgMap;
		
		/**在指定的延迟后，发包攻击*/
		private var _attackTimer:FrameTimer;
		
		
		
		
		
		/**
		 * 单例的实例
		 */
		public static function get instance():MoveManager
		{
			if(_instance == null) _instance = new MoveManager();
			return _instance;
		}
		
		
		public function MoveManager()
		{
			if(_instance != null) return;
			_instance = this;
			
			_map = (Common.ui.getModule(GameConstants.MN_SCENE_RPG) as IRpgScene).map;
			_avatar = _map.getAvatarByKey(RpgSceneData.getInstance().roleKey);
			_avatar.addEventListener(AvatarEvent.TILE_CHANGED, avatar_tileChangedHandler);
			_attackTimer = new FrameTimer(1000, attackTimer_timerHandler);
		}
		
		
		
		
		/**
		 * 移动到某点
		 * @param tile
		 */
		public function moveTo(tile:Point):void
		{
			cancelAttack();
			
			if(_avatar.isDead) return;
			if(_avatar.action == RpgConstants.A_CONJURE) return;
			
			_road = Wayfinding.search(_map.info.data, _avatar.tile, tile);
			avatar_tileChangedHandler();
		}
		
		/**
		 * 主角的区块有变动，继续往下一个区块移动
		 * @param event
		 */
		private function avatar_tileChangedHandler(event:AvatarEvent=null):void
		{
			if(_road.length == 0) return;
			
			var tile:Array = _road.shift();
			if(_avatar.tile.x == tile[0] && _avatar.tile.y == tile[1]) {
				avatar_tileChangedHandler();
				return;
			}
			
			Common.service.send(RmList.MAP_MOVE, { tile:{x:tile[0], y:tile[1]}, direction:_avatar.direction });
		}
		
		
		/**
		 * 取消追击
		 */
		public function cancelAttack():void
		{
			_attackTimer.stop();
			TweenMax.killDelayedCallsTo(continueToAttack);
			
			if(target != null) {
				target.removeEventListener(AvatarEvent.TILE_CHANGED, attackTarget_tileChangedHandler);
				_avatar.removeEventListener(AvatarEvent.MOVE_END, avatar_moveEndHandler);
			}
		}
		
		
		
		/**
		 * 追踪并攻击目标角色
		 * @param target
		 */
		public function attack(avatar:IAvatar):void
		{
			cancelAttack();
			
			if(_avatar.isDead) return;
			if(_avatar.action == RpgConstants.A_CONJURE) return;
			
			//攻击目标已死亡，算鼠标点击
			if(avatar != null && avatar.isDead)
			{
				var bg:MapBackground = avatar.map.container.getChildByName(Constants.LAYER_NAME_BG) as MapBackground;
				if(avatar.map.autoPlayMouseDownAnimation) bg.playMouseDownAnimation();
				avatar.map.dispatchEvent(new RpgMapEvent(RpgMapEvent.MOUSE_DOWN, avatar.map.mouseTile));
				avatar = null;
			}
			
			SkillManager.instance.target = avatar;
			if(target == null || target.isDead) return;
			
			target.addEventListener(AvatarEvent.TILE_CHANGED, attackTarget_tileChangedHandler);
			_avatar.addEventListener(AvatarEvent.MOVE_END, avatar_moveEndHandler);
			attackTarget_tileChangedHandler();
		}
		
		/**
		 * 攻击目标的区块有变动，追击！
		 * @param event
		 */
		private function attackTarget_tileChangedHandler(event:AvatarEvent=null):void
		{
			if(_avatar.action == RpgConstants.A_ATTACK) {
				_chase = true;
				return;
			}
			
			//拿距离主角最近的，攻击目标周围的一个点
			var d:uint = RpgUtil.getDirection(
				RpgUtil.getTileCenter(target.tile, _map.info),
				RpgUtil.getTileCenter(_avatar.tile, _map.info)
			);
			var p:Point = RpgUtil.getSideTile(target.tile, d, _avatar.map.info);
			
			//点不能通行，取周围8方向随机的一个点
			var tiles:Vector.<Point>;
			if(!RpgUtil.canPassTile(p, _map.info)) {
				tiles = RpgUtil.getTileArea(p, 1, _map.info);
				p = tiles[int(Math.random() * tiles.length)];
			}
			
			//周围没有点可以通行，就往攻击目标的方向移动，并取消攻击
			if(tiles != null && tiles.length == 0) {
				p = RpgUtil.closestCanPassTile(_avatar.tile, target.tile, _map.info);
				moveTo(p);
			}
			else {
				//开始移动到攻击目标的身边
				_road = Wayfinding.search(_map.info.data, _avatar.tile, p);
				if(_road.length == 0 && !_avatar.moveing) {
					avatar_moveEndHandler();
				}
				else {
					avatar_tileChangedHandler();
				}
			}
		}
		
		/**
		 * 主角移动结束，攻击目标角色
		 * @param event
		 */
		private function avatar_moveEndHandler(event:AvatarEvent=null):void
		{
			_avatar.direction = RpgUtil.getDirection(
				RpgUtil.getTileCenter(_avatar.tile, _map.info),
				RpgUtil.getTileCenter(target.tile, _map.info)
			);
			
			delayAttack();
		}
		
		
		
		
		/**
		 * 延时后发包攻击
		 */
		private function delayAttack():void
		{
			_attackTimer.delay = (_avatar.data as AvatarData).getCD(FightConstants.SID_GONG_JI) + 50;
			_attackTimer.start();
		}
		
		private function attackTimer_timerHandler():void
		{
			_attackTimer.stop();
			
			if(_avatar.isDead) {
				cancelAttack();
			}
			else {
				SkillManager.instance.useSkill(FightConstants.SID_GONG_JI);
			}
		}
		
		
		
		
		/**
		 * 继续对目标角色进行攻击（攻击动作的动画播放结束，或者其他情况）
		 */
		public function continueToAttack():void
		{
			if(_avatar.isDead) cancelAttack();
			
			if(target == null) return;
			
			if(_chase) {
				_chase = false;
				attackTarget_tileChangedHandler();
				return;
			}
			
			if(target.isDead) {
				
			}
			else {
				attackTarget_tileChangedHandler();
			}
		}
		
		
		/**
		 * 追击的目标
		 */
		private function get target():IAvatar
		{
			return SkillManager.instance.target;
		}
		//
	}
}