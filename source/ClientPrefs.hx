package;

import Controls;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

class ClientPrefs
{
	// TO DO: Redo ClientPrefs in a way that isn't too stupid
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;

	public static var showMemory:Bool = true;
	public static var optScoreZoom:Bool = true;
	public static var cameraMovement:Bool = true;
	public static var iconBoping:Bool = false;
	public static var pauseMusic:String = "Tea Time";
	public static var missVolume:Float = 0.2;
	public static var hitsoundVolume:Float = 0;
	public static var scoreTextDesign:String = "Engine";
	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var inputType:String = "Kade 1.5.3";
	public static var smoothCamZoom:Bool = true;
	public static var opponentNoteSplash:Bool = true;
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var shitWindow:Int = 166;
	public static var safeFrames:Float = 10;
	public static var allowFileSys:Bool = false;
	public static var answeredReq:Bool = false;
	public static var ghostTappingBFSing:Bool = true;
	public static var comboStacking:Bool = true;
	public static var pauseOnFocusLost:Bool = true;
	public static var snapCameraOnGameover:Bool = true;
	public static var counterFont:String = "Funkin";
	public static var osuManiaSimulation:Bool = true; //not exactly a simulation but yeah
	public static var ratingsStyle:String = "Classic";
	public static var allowOnlineFetching:Bool = false;
	public static var smallRatingSize:Bool = true;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	// ayo i might change this, im too fucking tired of adding FlxG.save.data for each new option
	public static function saveSettings()
	{
		saveFlxGPrefs();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs()
	{
		loadFlxGPrefs();

		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}

		//uhhhh do i try to make this a settings file too or???
		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	static function loadFlxGPrefs()
	{
		if (FlxG.save.data.downScroll != null)
			downScroll = FlxG.save.data.downScroll;
		if (FlxG.save.data.middleScroll != null)
			middleScroll = FlxG.save.data.middleScroll;
		if (FlxG.save.data.showFPS != null)
		{
			showFPS = FlxG.save.data.showFPS;
			if (Main.fpsVar != null)
				Main.fpsVar.visible = showFPS;
		}
		if (FlxG.save.data.flashing != null)
			flashing = FlxG.save.data.flashing;
		if (FlxG.save.data.globalAntialiasing != null)
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		if (FlxG.save.data.noteSplashes != null)
			noteSplashes = FlxG.save.data.noteSplashes;
		if (FlxG.save.data.lowQuality != null)
			lowQuality = FlxG.save.data.lowQuality;
		if (FlxG.save.data.framerate != null)
		{
			framerate = FlxG.save.data.framerate;
			if (framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			}
			else
			{
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if (FlxG.save.data.camZooms != null)
			camZooms = FlxG.save.data.camZooms;
		if (FlxG.save.data.hideHud != null)
			hideHud = FlxG.save.data.hideHud;
		if (FlxG.save.data.noteOffset != null)
			noteOffset = FlxG.save.data.noteOffset;
		if (FlxG.save.data.arrowHSV != null)
			arrowHSV = FlxG.save.data.arrowHSV;
		if (FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;
		if (FlxG.save.data.hideTime != null)
			hideTime = FlxG.save.data.hideTime;

		if (FlxG.save.data.showMemory != null)
		{
			showMemory = FlxG.save.data.showMemory;
			if (Main.memoryVar != null)
				Main.memoryVar.visible = showMemory;
		}
		if (FlxG.save.data.optScoreZoom != null)
			optScoreZoom = FlxG.save.data.optScoreZoom;
		if (FlxG.save.data.cameraMovement != null)
			cameraMovement = FlxG.save.data.cameraMovement;
		if (FlxG.save.data.iconBoping != null)
			iconBoping = FlxG.save.data.iconBoping;
		if (FlxG.save.data.pauseMusic != null)
			pauseMusic = FlxG.save.data.pauseMusic;
		if (FlxG.save.data.missVolume != null)
			missVolume = FlxG.save.data.missVolume;
		if (FlxG.save.data.hitsoundVolume != null)
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		if (FlxG.save.data.scoreTextDesign != null)
			scoreTextDesign = FlxG.save.data.scoreTextDesign;
		if (FlxG.save.data.comboOffset != null)
			comboOffset = FlxG.save.data.comboOffset;
		if (FlxG.save.data.inputType != null)
			inputType = FlxG.save.data.inputType;
		if (FlxG.save.data.smoothCamZoom != null)
			smoothCamZoom = FlxG.save.data.smoothCamZoom;
		if (FlxG.save.data.opponentNoteSplash != null)
			opponentNoteSplash = FlxG.save.data.opponentNoteSplash;
		if (FlxG.save.data.ratingOffset != null)
			ratingOffset = FlxG.save.data.ratingOffset;
		if (FlxG.save.data.sickWindow != null)
			sickWindow = FlxG.save.data.sickWindow;
		if (FlxG.save.data.goodWindow != null)
			goodWindow = FlxG.save.data.goodWindow;
		if (FlxG.save.data.badWindow != null)
			badWindow = FlxG.save.data.badWindow;
		if (FlxG.save.data.safeFrames != null)
			safeFrames = FlxG.save.data.safeFrames;
		if (FlxG.save.data.allowFileSys != null)
			allowFileSys = FlxG.save.data.allowFileSys;
		if (FlxG.save.data.answeredReq != null)
			answeredReq = FlxG.save.data.answeredReq;
		if (FlxG.save.data.ghostTappingBFSing != null)
			ghostTappingBFSing = FlxG.save.data.ghostTappingBFSing;
		if (FlxG.save.data.comboStacking != null)
			comboStacking = FlxG.save.data.comboStacking;
		if (FlxG.save.data.pauseOnFocusLost != null)
			pauseOnFocusLost = FlxG.save.data.pauseOnFocusLost;
		if (FlxG.save.data.snapCameraOnGameover != null)
			snapCameraOnGameover = FlxG.save.data.snapCameraOnGameover;
		if (FlxG.save.data.counterFont != null)
			counterFont = FlxG.save.data.counterFont;
		if (FlxG.save.data.osuManiaSimulation != null)
			osuManiaSimulation = FlxG.save.data.osuManiaSimulation;
		if (FlxG.save.data.ratingsStyle != null)
			ratingsStyle = FlxG.save.data.ratingsStyle;
		if (FlxG.save.data.allowOnlineFetching != null)
			allowOnlineFetching = FlxG.save.data.allowOnlineFetching;
		if (FlxG.save.data.smallRatingSize != null)
			smallRatingSize = FlxG.save.data.smallRatingSize;
		if (FlxG.save.data.shitWindow != null)
			shitWindow = FlxG.save.data.shitWindow;
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
	}

	static function saveFlxGPrefs()
	{
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.cursing = cursing;
		FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.hideTime = hideTime;

		FlxG.save.data.showMemory = showMemory;
		FlxG.save.data.optScoreZoom = optScoreZoom;
		FlxG.save.data.cameraMovement = cameraMovement;
		FlxG.save.data.iconBoping = iconBoping;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.missVolume = missVolume;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.scoreTextDesign = scoreTextDesign;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.inputType = inputType;
		FlxG.save.data.smoothCamZoom = smoothCamZoom;
		FlxG.save.data.opponentNoteSplash = opponentNoteSplash;
		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.allowFileSys = allowFileSys;
		FlxG.save.data.answeredReq = answeredReq;
		FlxG.save.data.ghostTappingBFSing = ghostTappingBFSing;
		FlxG.save.data.comboStacking = comboStacking;
		FlxG.save.data.pauseOnFocusLost = pauseOnFocusLost;
		FlxG.save.data.snapCameraOnGameover = snapCameraOnGameover;
		FlxG.save.data.counterFont = counterFont;
		FlxG.save.data.osuManiaSimulation = osuManiaSimulation;
		FlxG.save.data.ratingsStyle = ratingsStyle;
		FlxG.save.data.allowOnlineFetching = allowOnlineFetching;
		FlxG.save.data.smallRatingSize = smallRatingSize;
		FlxG.save.data.shitWindow = shitWindow;
		FlxG.save.data.gameplaySettings = gameplaySettings;

		FlxG.save.flush();
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}
}
