package net.tankmas;

typedef NetUserDef =
{
	username:String,
	?x:Int,
	?y:Int,
	?sx:Int, // Scale x, if facing right or left
	?costume:String,
	?timestamp:Float,
	?room_id:Int,
	// Data can contain specific user flags that the user can set.
	// Sort of like a save file but you can read other players data too.
	// WIP - no calls in client for this yet.
	?data:
		{
			?test_value:Int,
			?marshmallows_thrown:Int,
		},

	// Whether or not to apply the changes immediately or not. Good for initial placement of players
	?immediate:Bool,
}

typedef NetEventDef =
{
	// Events can also be non user specific, if we want global events happening.
	?username:String,

	type:NetEventType,
	data:Dynamic,

	?timestamp:Float,

	// If event happened in a specific room.
	?room_id:Int,
}

typedef NetMessage =
{
	type:NetEventType,
}

enum abstract NetEventType(String) from String to String
{
	final STICKER = "sticker";
	final DROP_MARSHMALLOW = "drop_marshmallow";
}
