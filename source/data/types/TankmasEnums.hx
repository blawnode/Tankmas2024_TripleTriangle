package data.types;

import data.types.TankmasDefs.CostumeDef;
import data.types.TankmasDefs.SpriteAnimationDef;

/**
 * Enum of costume defs, these are just examples
 */
class Costumes
{
	/**The problems of the future, today!**/
	public static final TANKMAN = {name: "tankman"};

	/**The most popular school shooter hero of 1999**/
	public static final PACO = {name: "paco"};

	/**Castle Crasher video game but red**/
	public static final KNIGHT_RED = {name: "knight-red"};

	/**Castle Crasher video game but blue**/
	public static final KNIGHT_BLUE = {name: "knight-blue"};

	/**Castle Crasher video game but green**/
	public static final KNIGHT_GREEN = {name: "knight-green"};

	/**Castle Crasher video game but orange**/
	public static final KNIGHT_ORANGE = {name: "knight-orange"};

	/**Castle Crasher video game but pink uwu**/
	public static final KNIGHT_PINK = {name: "knight-pink"};

	/**BEEP BEEP BEEP ⬆️⬇️⬅️➡️ BEEP BEEP BEEP**/
	public static final BOYFRIEND = {name: "boyfriend"};

	/**as seen on addicting games dot com**/
	public static final MADNESS_GRUNT = {name: "madness-grunt"};

	/**It's an absolute invasion!**/
	public static final ALIEN_HOMINID = {name: "alien-hominid"};

	/**"I'm gonna go watch hentai cartoons and play dating sims on newgrounds"**/
	public static final THOMAS = {name: "thomas", unlock: UnlockCondition.ANGRY_FAIC};

	/**It's the guy! Unlocks on 12/25/2024 at exactly 00:00:00 unix time**/
	public static final SANTA = {name: "santa", unlock: UnlockCondition.DATE, data: 1735102800};

	public static function string_to_costume(name:String):CostumeDef
	{
		var janky_hard_coded_array:Array<CostumeDef> = [
			TANKMAN,
			PACO,
			KNIGHT_RED,
			KNIGHT_BLUE,
			KNIGHT_GREEN,
			KNIGHT_ORANGE,
			KNIGHT_PINK,
			BOYFRIEND,
			MADNESS_GRUNT,
			ALIEN_HOMINID,
			THOMAS,
			SANTA
		];
		for (jank in janky_hard_coded_array)
			if (jank.name == name)
				return jank;
		return null;
	}
}

enum abstract UnlockCondition(String) from String to String
{
	/**On a specific date, data contains the unix timestamp, see: https://www.unixtimestamp.com/index.php**/
	final DATE;

	/**Checks if you have an achievement, by achievement name*/
	final ACHIEVEMENT;

	/**Always true, because you're always a special little boy. This is the same as no unlock condition at all (i.e. null)*/
	final YOUR_A_SPECIAL_LITTLE_BOY;

	/**Always false >:(*/
	final ANGRY_FAIC;

	/**Checks on flag, data is a String representing flag(s)*/
	final FLAG;

	public static inline function get_unlocked(condition:UnlockCondition, data:Dynamic):Bool
        switch (cast(condition, UnlockCondition))
        {
            default:
                return true;
            case UnlockCondition.YOUR_A_SPECIAL_LITTLE_BOY:
                return true;
            case UnlockCondition.ANGRY_FAIC:
                return false;
            case UnlockCondition.DATE:
                return Date.now().getTime() >= data; // where data is a unix timestamp, see above
            case UnlockCondition.ACHIEVEMENT:
				return true;
                // TODO: insert code that handles achievements from NG API here
			case UnlockCondition.FLAG:
				return Flags.get(data);
        }
}


/**
 * Enum of fixed player animations, probably will be moved
 */
enum abstract PlayerAnimation(SpriteAnimationDef) from SpriteAnimationDef to SpriteAnimationDef
{
	public static final IDLE:SpriteAnimationDef = {
		name: "idle",
		fps: Utils.ms_to_frames_per_second("40ms"),
		looping: true,
		frames: [
			{
				duration: 1,
				x: 0,
				y: 0,
				angle: 0,
				height: 1.0,
				width: 1.0
			}
		]
	};

	public static final MOVING:SpriteAnimationDef = {
		name: "moving",
		fps: Utils.ms_to_frames_per_second("40ms"),
		looping: true,
		frames: [
			{
				duration: 2,
				x: -5,
				y: -16,
				angle: 7
			},
			{
				duration: 2,
				y: -20,
			},
			{
				duration: 3,
				x: 0,
				y: 0,
				angle: 0
			},
			{
				duration: 2,
				x: 5,
				y: -16,
				angle: -7
			},
			{
				duration: 2,
				y: -20,
			},
			{
				duration: 3,
				x: 0,
				y: 0,
				angle: 0
			},
		]
	};

	public static final START_STOP:SpriteAnimationDef = {
		name: "start-stop",
		fps: Utils.ms_to_frames_per_second("40ms"),
		looping: false,
		frames: [
			{
				duration: 3,
				x: 0,
				y: 0,
				angle: 0,
				height: 1.0,
				width: 1.0
			},
			{
				duration: 5,
				x: 0,
				y: -10,
				angle: -10,
			},
			{
				duration: 5,
				x: 0,
				y: -5,
				angle: 5,
			},
		]
	};
}
/**
 * Enum of fixed player animations, probably will be moved
 */
enum abstract PresentAnimation(SpriteAnimationDef) from SpriteAnimationDef to SpriteAnimationDef
{
	public static final IDLE:SpriteAnimationDef = {
		name: "idle",
		fps: Utils.ms_to_frames_per_second("40ms"),
		looping: true,
		frames: [
			{
				duration: 1,
				x: 0,
				y: 0,
				angle: 0,
				height: 1.0,
				width: 1.0
			}
		]
	};

	public static final NEARBY:SpriteAnimationDef = {
		name: "nearby",
		fps: Utils.ms_to_frames_per_second("40ms"),
		looping: true,
		frames: [
			{
				duration: 2,
				x: 0,
				y: 0,
				angle: 0,
				height: 1.0,
				width: 1.0
			}, // frame 1
			{
				duration: 2,
				height: 1.2,
			}, // frame 4
			{
				duration: 2,
				y: -36,
				height: 0.9,
				angle: -15
			}, // frame 6
			{
				duration: 2,
				height: 1.2,
				angle: 15,
				y: -46
			}, // frame 8
			{
				duration: 2,
				height: 1,
				angle: -15
			}, // frame 10
			{
				duration: 2,
				angle: 15,
				y: -50
			}, // frame 12
			{
				duration: 2,
				angle: -15,
				y: -53
			}, // frame 13
			{
				duration: 2,
				angle: 15,
				y: -56
			}, // frame 15
			{
				duration: 3,
				height: 1.2,
				angle: -12,
				y: -40
			}, // frame 18
			{
				duration: 1,
				height: 1.5,
				angle: 0,
				y: -40,
			}, // frame 19
			{
				duration: 2,
				y: -20,
			}, // frame 21
			{
				duration: 1,
				height: 0.7,
				y: 10,
			}, // frame 22 + extra bounce not in anim
			{
				duration: 1,
				height: 1,
				y: -10,
			},
			{
				duration: 1,
				y: -6,
			},
			{
				duration: 5,
				height: 1,
				y: 0
			},
		]
	};
}