package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

class SaveData
{
	private static var settings:Map<Settings, Dynamic> = [
		VOLUME => 1,
		MUTED => false,
		DOWN_SCROLL => false,
		MIDDLE_SCROLL => false,
		SHOW_FRAMERATE => true,
		FLASHING => true,
		ANTIALIASING => true,
		NOTE_SPLASHES => true,
		LOW_QUALITY => false,
		FPS => 60,
		CAMERA_ZOOMS => true,
		HIDE_HUD => false,
		NOTE_OFFSET => 0,
		ARROW_HSV => [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]], // LMFAOOO I FORGOT THE LAST ARROW BRUHHHHH
		GHOST_TAPPING => true,
		HIDE_TIME => false,
		SHOW_MEMORY => true,
		SCORE_ZOOM => true,
		CAMERA_MOVEMENT => true,
		ICON_BOPING => false,
		PAUSE_MUSIC => "Tea Time",
		MISS_VOL => 0.2,
		HITSOUND_VOL => 0,
		SCORE_TEXT_STYLE => "Engine",
		COMBO_OFFSET => [0, 0, 0, 0],
		INPUT_TYPE => "Kade 1.5.3",
		SMOOTH_CAMERA_ZOOMS => true,
		OPPONENT_NOTE_SPLASHES => true,
		RATING_OFFSET => 0,
		SICK_WINDOW => 45,
		GOOD_WINDOW => 90,
		BAD_WINDOW => 135,
		SHIT_WINDOW => 166,
		SAFE_FRAMES => 10,
		ALLOW_FILESYS => false,
		ANSWERED => false,
		FREESTYLE_BF => true,
		COMBO_STACKING => true,
		PAUSE_ON_FOCUS_LOST => true,
		SNAP_CAMERA_ON_GAMEOVER => true,
		COUNTERS_FONT => "Funkin",
		OSU_MANIA_SIMULATION => true,
		ALLOW_ONLINE => false,
		SMALL_RATING_SIZE => true,
		LEGACY_RATINGS_STYLE => "Classic",
		USE_CLASSIC_COMBOS => false,
		RATINGS_STYLE => "Default",
		NO_RESET => false,
		OLD_SONG_SYSTEM => false,
		FULLSCREEN => false
	];

	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false
	];

	public static var keyBinds:Map<String, Array<FlxKey>> = [
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE]
	];

	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
		defaultKeys = keyBinds.copy();

	public static function get(setting:Settings)
		return settings[setting];

	// was unplayable thanks to the FUCKING ARROW HSV SHIT
	public static function getHSV(index1:Int, index2:Int)
		return (settings[ARROW_HSV][index1] == null ? 0 : settings[ARROW_HSV][index1][index2]);

	public static function setHSV(index1:Int, index2:Int, value:Dynamic)
		settings[ARROW_HSV][index1][index2] = value;

	// goofy fix lol
	public static function set(setting:Settings, value:Dynamic, index:Int = 0, index2:Int = 0)
	{
		if (setting == COMBO_OFFSET)
		{
			settings[setting][index] = value;
			return;
		}

		settings[setting] = value;
	}

	public static function saveSettings()
	{
		// br
		set(VOLUME, FlxG.sound.volume);
		set(MUTED, FlxG.sound.muted);
		for (settingName => settingValue in settings)
		{
			Reflect.setProperty(FlxG.save.data, settingName, settingValue);
		}
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('essentials', 'sanicbtw');
		save.data.keybinds = keyBinds;
		save.data.changers = gameplaySettings;
		save.flush();
	}

	public static function loadSettings()
	{
		for (settingName => settingValue in settings)
		{
			var flxProp = Reflect.getProperty(FlxG.save.data, settingName);
			if (flxProp != null)
				settings[settingName] = Reflect.getProperty(FlxG.save.data, settingName);
			else
				settings[settingName] = settingValue;
		}

		FlxG.sound.volume = get(VOLUME);
		FlxG.sound.muted = get(MUTED);

		if (get(FPS) > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = get(FPS);
			FlxG.drawFramerate = get(FPS);
		}
		else
		{
			FlxG.drawFramerate = get(FPS);
			FlxG.updateFramerate = get(FPS);
		}

		FlxG.fullscreen = get(FULLSCREEN);

		var save:FlxSave = new FlxSave();
		save.bind('essentials', 'sanicbtw');
		if (save != null)
		{
			if (save.data.keybinds != null)
			{
				var loadedShit:Map<String, Array<FlxKey>> = save.data.keybinds;
				for (control => keys in loadedShit)
					keyBinds.set(control, keys);

				reloadControls();
			}

			if (save.data.changers != null)
			{
				var savedShit:Map<String, Dynamic> = save.data.changers;
				for (name => value in savedShit)
					gameplaySettings.set(name, value);
			}
		}
		save.close();
	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = CoolUtil.copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = CoolUtil.copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = CoolUtil.copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
}

// the reason im doing it like this is to make it compatible with flxg save?
// no reason to be in upper case btw lol
enum abstract Settings(String) to String
{
	// flixel stuff
	var VOLUME = "Volume";
	var MUTED = "Muted";
	// psych settings 0.3.2h
	var DOWN_SCROLL = "DownScroll";
	var MIDDLE_SCROLL = "MiddleScroll";
	var SHOW_FRAMERATE = "ShowFPS";
	var FLASHING = "FlashingLights";
	var ANTIALIASING = "Antialiasing";
	var NOTE_SPLASHES = "NoteSplashes";
	var LOW_QUALITY = "LowQuality";
	var FPS = "Framerate";
	// should add cursing/violence/.. but who cares lol
	var CAMERA_ZOOMS = "CameraZooms";
	var HIDE_HUD = "HideHUD";
	var NOTE_OFFSET = "NoteOffset";
	var ARROW_HSV = "ArrowHSV";
	var GHOST_TAPPING = "GhostTapping";
	var HIDE_TIME = "HideTime";
	// engine settings
	var SHOW_MEMORY = "ShowMemory";
	var SCORE_ZOOM = "ScoreZoom";
	var CAMERA_MOVEMENT = "CameraMovement";
	var ICON_BOPING = "IconBoping";
	var PAUSE_MUSIC = "PauseMusic";
	var MISS_VOL = "MissVolume";
	var HITSOUND_VOL = "HitsoundVolume";
	var SCORE_TEXT_STYLE = "ScoreTextStyle";
	var COMBO_OFFSET = "ComboOffset";
	var INPUT_TYPE = "InputType";
	var SMOOTH_CAMERA_ZOOMS = "SmoothCameraZooms";
	var OPPONENT_NOTE_SPLASHES = "OpponentNoteSplash";
	var RATING_OFFSET = "RatingOffset";
	var SICK_WINDOW = "SickWindow";
	var GOOD_WINDOW = "GoodWindow";
	var BAD_WINDOW = "BadWindow";
	var SHIT_WINDOW = "ShitWindow";
	// miss window???
	var SAFE_FRAMES = "SafeFrames";
	var ALLOW_FILESYS = "AllowFileSys";
	var ANSWERED = "AnsweredRequests";
	var FREESTYLE_BF = "FreestyleBF";
	var COMBO_STACKING = "ComboStacking";
	var PAUSE_ON_FOCUS_LOST = "PauseOnFocusLost";
	var SNAP_CAMERA_ON_GAMEOVER = "SnapCameraOnGameover";
	var COUNTERS_FONT = "CounterFont";
	var OSU_MANIA_SIMULATION = "OsuManiaSimulation";
	var ALLOW_ONLINE = "AllowOnlineFetching";
	var SMALL_RATING_SIZE = "SmallRatingSize";
	var LEGACY_RATINGS_STYLE = "LegacyRatingStyle";
	var USE_CLASSIC_COMBOS = "UseClassicStyles";
	var RATINGS_STYLE = "RatingsStyle";
	var NO_RESET = "NoReset";
	var OLD_SONG_SYSTEM = "OldSongSystem";
	var FULLSCREEN = "FullScreen";
}
