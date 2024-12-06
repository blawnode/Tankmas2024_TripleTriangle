package data;

import http.HttpError;
import net.tankmas.TankmasClient;
import ui.sheets.CostumeSelectSheet;
import ui.sheets.EmoteSelectSheet;

class SaveManager
{
	public static var savedPresents:Array<String> = [];
	public static var savedCostumes:Array<String> = [];
	public static var savedEmotes:Array<String> = [];
	public static var savedRoom:String;

	public static var saved_emote_collection:Array<String>;
	public static var saved_costume_collection:Array<String>;

	public static var current_costume(default, default):String;
	public static var current_emote(default, default):String;

	public static var on_save_stored:() -> Void = null;

	public static var data = {
		saved_room: Main.default_room,
	}

	public static function init()
	{
		savedRoom = Main.default_room;
		saved_emote_collection = Main.default_emote_collection;
		saved_costume_collection = Main.default_costume_collection;
		current_emote = Main.default_emote;
		current_costume = Main.default_costume;
	}

	static function finalize_load()
	{
		// opened presents
		load_presents();

		// unlocked costumes, as well as what the player is currently wearing
		load_costumes();

		// unlocked emotes, as well as what emote the player is currently using
		load_emotes();

		// if it's December 1st, reset it...?
		// if(Date.now().getMonth() == 11 && Date.now().getDate() == 1) return;

		// opened presents
		load_presents();

		// loads current room
		load_room();
	}

	public static function upload()
	{
		// Serialize data
		var encodedData = haxe.Serializer.run(FlxG.save.data);

		// Upload data
		TankmasClient.post_save(encodedData, (data:Dynamic) ->
		{
			trace("Successfully uploaded save data.");
			if (on_save_stored != null)
				on_save_stored();
		});
	}

	public static function load(on_complete:() -> Void = null, ?on_fail:() -> Void)
	{
		SaveManager.load_costumes();
		SaveManager.load_emotes();

		#if offline
		finalize_load();
		if (on_complete != null)
			on_complete();
		#else
		// Download data
		TankmasClient.get_save((data:Dynamic) ->
		{
			trace("Successfully downloaded save data.");

			var encodedData = data?.data;

			if (encodedData != null)
			{
				// Deserialize data
				var data = haxe.Unserializer.run(encodedData);
				trace('Successfully deserialized save data.');
				trace(data);
				FlxG.save.mergeData(data, true);
			}

			finalize_load();

			if (on_complete != null)
				on_complete();
		}, (error:HttpError) ->
			{
				if (on_fail != null)
					on_fail();
				trace('Failed to download save');
			});
		#end
	}

	public static function save()
	{
		save_presents();
		save_costumes();
		save_emotes();
		save_room();
		save_collections();
		flush();

		upload();
	}

	public static function flush()
	{
		try
		{
			FlxG.save.flush();
		}
		catch (e)
		{
			trace("SAVE ERROR: " + e);
		}
	}

	public static function save_collections(force:Bool = false):Void
	{
		save_costume_collection(force);
		save_emote_collection(force);
	}

	public static function save_costume_collection(force:Bool = false):Void
	{
		FlxG.save.data.costume_collection = saved_costume_collection;
		if (force)
			flush();
	}

	public static function save_emote_collection(force:Bool = false):Void
	{
		FlxG.save.data.sticker_collection = saved_emote_collection;
		if (force)
			flush();
	}

	public static function load_costume_collection(force:Bool = false):Void
	{
		if (FlxG.save.data.saved_costume_collection == null)
		{
			trace("Error loading saved costumes (might be empty)");
			save_costume_collection(true);
		}
		saved_costume_collection = FlxG.save.data.costume_collection;
	}

	public static function load_emote_collection(force:Bool = false):Void
	{
		if (FlxG.save.data.saved_emote_collection == null)
		{
			trace("Error loading saved stickers (might be empty)");
			save_emote_collection(true);
		}
		saved_emote_collection = FlxG.save.data.sticker_collection;
	}

	public static function load_presents(force:Bool = false):Void
	{
		if (FlxG.save.data.savedPresents == null)
		{
			trace("Error loading saved presents (might be empty)");
			save_presents(true);
		}
		savedPresents = FlxG.save.data.savedPresents;
	}

	public static function load_costumes():Void
	{
		if (FlxG.save.data.savedCostumes == null)
		{
			trace("Error loading saved costumes (might be empty)");
			save_costumes(true);
		}
		savedCostumes = FlxG.save.data.savedCostumes;
		current_costume = FlxG.save.data.currentCostume;
		CostumeSelectSheet.saved_sheet = FlxG.save.data.savedCostumeSheet != null ? FlxG.save.data.savedCostumeSheet : 0;
		CostumeSelectSheet.saved_selection = FlxG.save.data.savedCostumeSelect != null ? FlxG.save.data.savedCostumeSelect : 0;
		CostumeSelectSheet.seenCostumes = FlxG.save.data.seenCostumes != null ? FlxG.save.data.seenCostumes : [];
	}

	public static function load_emotes():Void
	{
		if (FlxG.save.data.savedEmotes == null)
		{
			trace("Error loading saved emotes (might be empty)");
			save_emotes(true);
		}
		savedEmotes = FlxG.save.data.savedEmotes;
		EmoteSelectSheet.saved_sheet = FlxG.save.data.savedEmoteSheet != null ? FlxG.save.data.savedEmoteSheet : 0;
		EmoteSelectSheet.saved_selection = FlxG.save.data.savedEmoteSelect != null ? FlxG.save.data.savedEmoteSelect : 0;
		EmoteSelectSheet.seenStickers = FlxG.save.data.seenEmotes != null ? FlxG.save.data.seenEmotes : [];
	}

	public static function load_room():Void
	{
		if (FlxG.save.data.savedRoom == null)
		{
			trace("Error loading saved room (might be empty)");
			save_room(true);
		}
		savedRoom = FlxG.save.data.savedRoom;
	}

	public static function open_present(content:String, day:Int)
	{
		if (savedPresents.contains(content))
			return;
		savedPresents.push(content);
		save_presents(true);
		#if newgrounds
		if (day == 1 && content == "cymbourine")
			return Main.ng_api.medal_popup(Main.ng_api.medals.get("day-1"));
		if (day == 2 && content == "sevi")
			return Main.ng_api.medal_popup(Main.ng_api.medals.get("day-2"));
		if (day == 3 && content == "midgetsausage")
			return Main.ng_api.medal_popup(Main.ng_api.medals.get("day-3"));
		if (day == 4 && content == "sirlenward")
			return Main.ng_api.medal_popup(Main.ng_api.medals.get("day-4"));
		if (day == 5 && content == "theextreamh")
			return Main.ng_api.medal_popup(Main.ng_api.medals.get("day-5"));
		if ((Date.now().getMonth() != 0 && Date.now().getDate() != 1) && Date.now().getMonth() != 11)
			return;
		switch (content)
		{
			case "matthewlopz":
				return Main.ng_api.medal_popup(Main.ng_api.medals.get("little-candles"));
			default:
				return Main.ng_api.medal_popup(Main.ng_api.medals.get('day-$day'));
		}
		#end
	}

	public static function save_presents(force:Bool = false)
	{
		FlxG.save.data.savedPresents = savedPresents;
		if (force)
			flush();
	}

	public static function save_costumes(force:Bool = false)
	{
		FlxG.save.data.savedCostumes = savedCostumes;
		FlxG.save.data.currentCostume = current_costume;
		FlxG.save.data.savedCostumeSheet = CostumeSelectSheet.saved_sheet;
		FlxG.save.data.savedCostumeSelect = CostumeSelectSheet.saved_selection;
		FlxG.save.data.seenCostumes = CostumeSelectSheet.seenCostumes;
		/*trace(FlxG.save.data.savedCostumes, FlxG.save.data.currentCostume, FlxG.save.data.savedCostumeSheet, FlxG.save.data.savedCostumeSelect,
			FlxG.save.data.seenCostumes); */

		if (force)
			flush();
	}

	public static function save_emotes(force:Bool = false)
	{
		FlxG.save.data.savedEmotes = savedEmotes;
		FlxG.save.data.currentEmote = current_emote;
		FlxG.save.data.savedEmoteSheet = EmoteSelectSheet.saved_sheet;
		FlxG.save.data.savedEmoteSelect = EmoteSelectSheet.saved_selection;
		FlxG.save.data.seenEmotes = EmoteSelectSheet.seenStickers;
		if (force)
			flush();
	}

	public static function save_room(force:Bool = false)
	{
		FlxG.save.data.savedRoom = savedRoom;
		if (force)
			flush();
	}
}
