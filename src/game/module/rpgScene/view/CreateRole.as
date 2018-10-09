package game.module.rpgScene.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import game.common.GameConstants;
	import game.module.core.events.ChangeServiceTypeEvent;
	import game.module.rpgScene.events.map.EnterEvent;
	import game.module.rpgScene.model.RpgSceneData;
	import game.net.SocketService;
	
	import lolo.components.Button;
	import lolo.components.InputText;
	import lolo.components.ItemGroup;
	import lolo.core.Common;
	import lolo.core.Constants;
	import lolo.data.SO;
	import lolo.display.Container;
	import lolo.events.components.ListEvent;
	import lolo.mvc.control.MvcEventDispatcher;
	import lolo.rpg.RpgConstants;
	import lolo.rpg.avatar.IAvatar;
	
	/**
	 * 创角界面
	 * @author LOLO
	 */
	public class CreateRole extends Container
	{
		public var nameText:InputText;
		
		public var sexGroup:ItemGroup;
		public var hairGroup:ItemGroup;
		public var dressGroup:ItemGroup;
		public var weaponGroup:ItemGroup;
		
		public var serviceText:InputText;
		
		public var startBtn:Button;
		
		private var _role:IAvatar;
		
		
		
		
		
		public function CreateRole()
		{
			super();
		}
		
		override public function initUI(config:XML):void
		{
			super.initUI(config);
			nameText.restrict = "^~!@#$%&*()_+-= 　[]\{}|;':\",./<>?";
			nameText.maxChars = 8;
			
			var str:String = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASFGHJKLZXCVBNM0123456789";
			var name:String = "";
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			name += str.charAt(int(str.length * Math.random()));
			nameText.text = name;
			
			if(SO.data.roleName != null) nameText.text = SO.data.roleName;
			
			serviceText.text = Common.config.getConfig("socketServiceUrl");
			
			sexGroup.addEventListener(ListEvent.ITEM_SELECTED, group_itemSelectedHandler);
			hairGroup.addEventListener(ListEvent.ITEM_SELECTED, group_itemSelectedHandler);
			dressGroup.addEventListener(ListEvent.ITEM_SELECTED, group_itemSelectedHandler);
			weaponGroup.addEventListener(ListEvent.ITEM_SELECTED, group_itemSelectedHandler);
			
			startBtn.addEventListener(MouseEvent.CLICK, startBtn_clickHandler);
		}
		
		
		private function group_itemSelectedHandler(event:ListEvent):void
		{
			switch(event.target)
			{
				case sexGroup:
					_role.removeAdjunct();
					_role.pic = sexGroup.selectedItemData;
					if(hairGroup.selectedItemData) _role.addAdjunct(RpgConstants.ADJUNCT_TYPE_HAIR, _role.pic + hairGroup.selectedItemData);
					if(dressGroup.selectedItemData) _role.addAdjunct(RpgConstants.ADJUNCT_TYPE_DRESS, _role.pic + dressGroup.selectedItemData);
					if(weaponGroup.selectedItemData) _role.addAdjunct(RpgConstants.ADJUNCT_TYPE_WEAPON, weaponGroup.selectedItemData);
					break;
				
				case hairGroup:
					_role.removeAdjunct(RpgConstants.ADJUNCT_TYPE_HAIR);
					_role.addAdjunct(RpgConstants.ADJUNCT_TYPE_HAIR, _role.pic + hairGroup.selectedItemData);
					break;
				
				case dressGroup:
					_role.removeAdjunct(RpgConstants.ADJUNCT_TYPE_DRESS);
					_role.addAdjunct(RpgConstants.ADJUNCT_TYPE_DRESS, _role.pic + dressGroup.selectedItemData);
					break;
				
				case weaponGroup:
					_role.removeAdjunct(RpgConstants.ADJUNCT_TYPE_WEAPON);
					_role.addAdjunct(RpgConstants.ADJUNCT_TYPE_WEAPON, weaponGroup.selectedItemData);
					break;
			}
		}
		
		
		private function startBtn_clickHandler(event:MouseEvent):void
		{
			SocketService.getInstance().addEventListener(Event.CONNECT, socketConnectHandler);
			MvcEventDispatcher.dispatch(
				GameConstants.MN_CORE,
				new ChangeServiceTypeEvent(Constants.SERVICE_TYPE_SOCKET, serviceText.text)
			);
		}
		
		private function socketConnectHandler(event:Event):void
		{
			SocketService.getInstance().removeEventListener(Event.CONNECT, socketConnectHandler);
			_role.stopMove();
			
			var data:Object = {
				name		: nameText.text,
				tile		: { x:_role.tile.x, y:_role.tile.y },
				pic			: sexGroup.selectedItemData,
				hair		: _role.pic + hairGroup.selectedItemData,
				dress		: _role.pic + dressGroup.selectedItemData,
				weapon		: weaponGroup.selectedItemData,
				direction	: _role.direction,
				mapID		: RpgSceneData.DEFAULT_MAP_ID
			};
			MvcEventDispatcher.dispatch(GameConstants.MN_SCENE_RPG, new EnterEvent(data));
			
			this.hide();
			RpgScene.instance.skillView.show();
			
			SO.data.roleName = nameText.text;
			SO.save();
		}
		
		
		
		
		override protected function startup():void
		{
			_role = RpgScene.instance.map.getAvatarByKey(RpgSceneData.getInstance().roleKey);
			
			sexGroup.selectItemByIndex(Math.random() * sexGroup.numItems);
			hairGroup.selectItemByIndex(Math.random() * hairGroup.numItems);
			dressGroup.selectItemByIndex(Math.random() * dressGroup.numItems);
			weaponGroup.selectItemByIndex(Math.random() * weaponGroup.numItems);
			
			super.startup();
		}
		//
	}
}