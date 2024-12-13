package levels;

import activities.ActivityArea;
import entities.Minigame;
import entities.NPC;
import entities.Player;
import entities.Present;
import entities.misc.GamingDevice;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import levels.LDTKLevel;
import levels.LdtkProject;
import zones.Door;

enum abstract RoomId(Int) from Int from Int
{
	final HotelCourtyard = 1;
	final HotelInterior = 2;
	final Theatre = 3;

	public static function from_string(world_identifier:String):RoomId
	{
		switch (world_identifier)
		{
			case "hotel_interior":
				return HotelInterior;
			case "outside_hotel":
				return HotelCourtyard;
			case "theatre":
				return Theatre;
		}

		throw 'Could not find room id by name ${world_identifier}, 
					 please add it to RoomId in TankmasLevel.hx';
	}
}

class TankmasLevel extends LDTKLevel
{
	public var bg:FlxSpriteExt;
	public var fg:FlxSpriteExt;

	public var level_data:LdtkProject_Level;

	var level_name:String;

	public function new(level:LdtkProject_Level, ?tilesheet_graphic:String)
	{
		this.level_data = level;
		super(level.identifier, tilesheet_graphic);
	}

	override function generate(LevelName:String, tilesheet_graphic:String)
	{
		PlayState.self.levels.add(this);

		level_name = LevelName;

		super.generate(level_name, tilesheet_graphic);

		// for (i in 0..._tileObjects.length)
		// setTileProperties(i, FlxObject.NONE);

		var data:LdtkProject_Level = get_level_by_name(level_name);

		setPosition(data.worldX, data.worldY);

		if (data.json.bgRelPath != null)
		{
			var image:String = data.json.bgRelPath.split("/").last().replace_multiple(["-reference", "-background", "-foreground", ".png", ".jpg"], "");
			PlayState.self.level_backgrounds.add(bg = new FlxSpriteExt(x, y, Paths.image_path('$image-background')));
			PlayState.self.level_foregrounds.add(fg = new FlxSpriteExt(x, y, Paths.image_path('$image-foreground')));
		}
	}

	public function place_entities()
	{
		var level:LdtkProject_Level = get_level_by_name(level_name);

		for (entity in level.l_Entities.all_Player.iterator())
			new Player(x + entity.pixelX, y + entity.pixelY);

		for (entity in level.l_Entities.all_NPC.iterator())
			new NPC(x + entity.pixelX, y + entity.pixelY, entity.f_name, Std.parseInt(entity.f_timelock));

		for (entity in level.l_Entities.all_Present.iterator())
			new Present(x + entity.pixelX, y + entity.pixelY, entity.f_username);

		for (entity in level.l_Entities.all_Door.iterator())
		{
			var spawn:FlxPoint = new FlxPoint(x + entity.f_spawn.cx * 16, y + entity.f_spawn.cy * 16);
			new Door(x + entity.pixelX, y + entity.pixelY, entity.width, entity.height, entity.f_linked_door, spawn, entity.iid);
		}

		for (entity in level.l_Entities.all_Minigame.iterator())
			new Minigame(x + entity.pixelX, y + entity.pixelY, entity.width, entity.height, entity.f_minigame_id);

		for (entity in level.l_Entities.all_Activity_Area.iterator())
			new ActivityArea(entity.f_ActivityType, x + entity.pixelX, y + entity.pixelY, entity.width, entity.height);

		for (entity in level.l_Entities.all_Graphic)
		{
			var sprite:FlxSpriteExt = new FlxSpriteExt(x + entity.pixelX, y + entity.pixelY);
			sprite.loadAllFromAnimationSet(entity.f_name);

			switch (entity.f_layer.getName().toLowerCase())
			{
				case "back":
					PlayState.self.props_background.add(sprite);
				case "front":
					PlayState.self.props_foreground.add(sprite);
			}
		}

		var colls = PlayState.self.collisions;
		for (c in level.l_Collision.all_CollisionCircle)
		{
			var wx = x + c.pixelX;
			var wy = y + c.pixelY;
			colls.add_circle(wx, wy, c.height * 0.5);
		}

		for (c in level.l_Collision.all_CollisionSquare)
		{
			var wx = x + c.pixelX;
			var wy = y + c.pixelY;
			colls.add_rect(wx, wy, c.width, c.height);
		}

		for (c in level.l_Entities.all_Misc)
		{
			switch (c.f_name)
			{
				case "gaming-device":
					new GamingDevice(x + c.pixelY, y + c.pixelY);
			}
		}

		for (c in level.l_Collision.all_SlopeNE)
			colls.add_slope_ne(x + c.pixelX, y + c.pixelY, c.width, c.height);
		for (c in level.l_Collision.all_SlopeNW)
			colls.add_slope_nw(x + c.pixelX, y + c.pixelY, c.width, c.height);
		for (c in level.l_Collision.all_SlopeSE)
			colls.add_slope_se(x + c.pixelX, y + c.pixelY, c.width, c.height);
		for (c in level.l_Collision.all_SlopeSW)
			colls.add_slope_sw(x + c.pixelX, y + c.pixelY, c.width, c.height);

		/**put entity iterators here**/
		/* 
			example:
				for (entity in data.l_Entities.all_Boy.iterator())
					new Boy(x + entity.pixelX, y + entity.pixelY);
		 */
	}

	public static function make_all_levels_in_world(world_name:String):Array<TankmasLevel>
	{
		var array:Array<TankmasLevel> = [];

		for (world in Main.ldtk_project.worlds)
			if (world.identifier == world_name)
				for (level in world.levels)
					array.push(new TankmasLevel(level));

		return array;
	}

	override function update(elapsed:Float)
	{
		// getTileCollisions(getTileIndexByCoords(PlayState.self.player.mp));
		super.update(elapsed);
	}
}
