package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PreferencesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private static var index:Int = 0;
	static var unselectableOptions:Array<String> = ['GRAPHICS', 'GAMEPLAY', 'CAMERA', 'VISUALS AND UI', 'AUDIO',];
	static var noCheckbox:Array<String> = [
		'Framerate', 'Pause Music', 'Miss Volume', 'Hitsound Volume', 'Score Text design', 'Input', 'Rating Offset', 'Sick! Hit Window', 'Good Hit Window',
		'Bad Hit Window', 'Safe Frames', 'Camera Mov Displacement'
	];

	static var options:Array<String> = [
		'GRAPHICS',
		'Low Quality',
		'Anti-Aliasing',
		#if !html5 'Framerate', // Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		#end
		'GAMEPLAY',
		'Downscroll',
		'Middlescroll',
		'Ghost Tapping',
		'Input',
		'Rating Offset',
		'Sick! Hit Window',
		'Good Hit Window',
		'Bad Hit Window',
		'Safe Frames',
		'Freestyle BF',
		'Pause game when focus is lost',
		'CAMERA',
		'Camera Zooms',
		'Smooth cam zooms',
		'Camera Movement',
		'Camera Mov Displacement',
		'VISUALS AND UI',
		'FPS Counter',
		'Memory Counter',
		'Hide HUD',
		'Hide Song Length',
		'Flashing Lights',
		'Icon Boping',
		'Score Text design',
		'Note Splashes',
		'Opponent Note Splashes',
		'Score Text Zoom on Hit',
		'Combo Stacking',
		'AUDIO',
		'Pause Music',
		'Miss Volume',
		'Hitsound Volume',
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var descText:FlxText;

	public function new()
	{
		super();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (!isCentered)
			{
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length)
				{
					if (options[i] == noCheckbox[j])
					{
						useCheckbox = false;
						break;
					}
				}

				if (useCheckbox)
				{
					var checkbox:CheckboxThingie = new CheckboxThingie(0, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkbox.offsetX = optionText.width + 150;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				}
				else
				{
					var valueText:AttachedText = new AttachedText('0', optionText.width + 70);
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...options.length)
		{
			if (!unselectableCheck(i))
			{
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();

		#if android
		addVirtualPad(LEFT_FULL, A_B);
		#end
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			grpOptions.forEachAlive(function(spr:Alphabet)
			{
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText)
			{
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length)
			{
				var spr:CheckboxThingie = checkboxArray[i];
				if (spr != null)
				{
					spr.alpha = 0;
				}
			}
			descText.alpha = 0;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		var usesCheckbox = true;
		for (i in 0...noCheckbox.length)
		{
			if (options[curSelected] == noCheckbox[i])
			{
				usesCheckbox = false;
				break;
			}
		}

		if (usesCheckbox)
		{
			if (controls.ACCEPT && nextAccept <= 0)
			{
				switch (options[curSelected])
				{
					case 'FPS Counter':
						ClientPrefs.showFPS = !ClientPrefs.showFPS;
						if (Main.fpsVar != null)
						{
							Main.fpsVar.visible = ClientPrefs.showFPS;
							if (Main.fpsVar.alpha == 0)
								Main.tweenFPS();
						}

					case 'Low Quality':
						ClientPrefs.lowQuality = !ClientPrefs.lowQuality;

					case 'Anti-Aliasing':
						ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
						for (item in grpOptions)
						{
							item.antialiasing = ClientPrefs.globalAntialiasing;
						}
						for (i in 0...checkboxArray.length)
						{
							var spr:CheckboxThingie = checkboxArray[i];
							if (spr != null)
							{
								spr.antialiasing = ClientPrefs.globalAntialiasing;
							}
						}
						OptionsState.menuBG.antialiasing = ClientPrefs.globalAntialiasing;

					case 'Note Splashes':
						ClientPrefs.noteSplashes = !ClientPrefs.noteSplashes;

					case 'Flashing Lights':
						ClientPrefs.flashing = !ClientPrefs.flashing;

					case 'Violence':
						ClientPrefs.violence = !ClientPrefs.violence;

					case 'Swearing':
						ClientPrefs.cursing = !ClientPrefs.cursing;

					case 'Downscroll':
						ClientPrefs.downScroll = !ClientPrefs.downScroll;

					case 'Middlescroll':
						ClientPrefs.middleScroll = !ClientPrefs.middleScroll;

					case 'Ghost Tapping':
						ClientPrefs.ghostTapping = !ClientPrefs.ghostTapping;

					case 'Camera Zooms':
						ClientPrefs.camZooms = !ClientPrefs.camZooms;

					case 'Hide HUD':
						ClientPrefs.hideHud = !ClientPrefs.hideHud;

					case 'Persistent Cached Data':
						ClientPrefs.imagesPersist = !ClientPrefs.imagesPersist;

					case 'Hide Song Length':
						ClientPrefs.hideTime = !ClientPrefs.hideTime;

					case 'Memory Counter':
						ClientPrefs.showMemory = !ClientPrefs.showMemory;
						if (Main.memoryVar != null)
						{
							Main.memoryVar.visible = ClientPrefs.showMemory;
							if (Main.memoryVar.alpha == 0)
								Main.tweenMemory();
						}

					case 'Score Text Zoom on Hit':
						ClientPrefs.optScoreZoom = !ClientPrefs.optScoreZoom;
					case 'Camera Movement':
						ClientPrefs.cameraMovement = !ClientPrefs.cameraMovement;
					case 'Icon Boping':
						ClientPrefs.iconBoping = !ClientPrefs.iconBoping;
					case 'Smooth cam zooms':
						ClientPrefs.smoothCamZoom = !ClientPrefs.smoothCamZoom;
					case 'Opponent Note Splashes':
						ClientPrefs.opponentNoteSplash = !ClientPrefs.opponentNoteSplash;
					case 'Freestyle BF':
						ClientPrefs.ghostTappingBFSing = !ClientPrefs.ghostTappingBFSing;
					case 'Combo Stacking':
						ClientPrefs.comboStacking = !ClientPrefs.comboStacking;
					case 'Pause game when focus is lost':
						ClientPrefs.pauseOnFocusLost = !ClientPrefs.pauseOnFocusLost;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reloadValues();
			}
		}
		else
		{
			if (controls.UI_LEFT || controls.UI_RIGHT)
			{
				var add:Int = controls.UI_LEFT ? -1 : 1;
				var floatAdd:Float = controls.UI_LEFT ? -0.1 : 0.1;

				if (holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
					switch (options[curSelected])
					{
						case 'Framerate':
							ClientPrefs.framerate += add;
							if (ClientPrefs.framerate < 30)
								ClientPrefs.framerate = 30;
							else if (ClientPrefs.framerate > 240)
								ClientPrefs.framerate = 240;

							if (ClientPrefs.framerate > FlxG.drawFramerate)
							{
								FlxG.updateFramerate = ClientPrefs.framerate;
								FlxG.drawFramerate = ClientPrefs.framerate;
							}
							else
							{
								FlxG.drawFramerate = ClientPrefs.framerate;
								FlxG.updateFramerate = ClientPrefs.framerate;
							}
						case 'Pause Music':
							var options = ['None', 'Breakfast', 'Tea Time'];
							if (controls.UI_LEFT_P)
								changeState(-1, options);
							else if (controls.UI_RIGHT_P)
								changeState(1, options);
							ClientPrefs.pauseMusic = options[index];
						case 'Miss Volume':
							ClientPrefs.missVolume += floatAdd;
							if (ClientPrefs.missVolume < 0)
								ClientPrefs.missVolume = 0;
							else if (ClientPrefs.missVolume > 0.2)
								ClientPrefs.missVolume = 0.2; // max cap of vol on playstate
						case 'Hitsound Volume':
							ClientPrefs.hitsoundVolume += floatAdd;
							if (ClientPrefs.hitsoundVolume < 0)
								ClientPrefs.hitsoundVolume = 0;
							else if (ClientPrefs.hitsoundVolume > 1)
								ClientPrefs.hitsoundVolume = 1;
						case 'Score Text design':
							var options = ['Engine', 'Psych'];
							if (controls.UI_LEFT_P)
								changeState(-1, options);
							else if (controls.UI_RIGHT_P)
								changeState(1, options);
							ClientPrefs.scoreTextDesign = options[index];
						case 'Input':
							var options = ['Kade 1.5.3', 'Psych 0.4.2'];
							if (controls.UI_LEFT_P)
								changeState(-1, options);
							else if (controls.UI_RIGHT_P)
								changeState(1, options);
							ClientPrefs.inputType = options[index];
						case 'Rating Offset':
							ClientPrefs.ratingOffset += add;
							if (ClientPrefs.ratingOffset < -30)
								ClientPrefs.ratingOffset = -30;
							else if (ClientPrefs.ratingOffset > 30)
								ClientPrefs.ratingOffset = 30;
						case 'Sick! Hit Window':
							ClientPrefs.sickWindow += add;
							if (ClientPrefs.sickWindow < 15)
								ClientPrefs.sickWindow = 15;
							else if (ClientPrefs.sickWindow > 45)
								ClientPrefs.sickWindow = 45;
						case 'Good Hit Window':
							ClientPrefs.goodWindow += add;
							if (ClientPrefs.goodWindow < 15)
								ClientPrefs.goodWindow = 15;
							else if (ClientPrefs.goodWindow > 90)
								ClientPrefs.goodWindow = 90;
						case 'Bad Hit Window':
							ClientPrefs.badWindow += add;
							if (ClientPrefs.badWindow < 15)
								ClientPrefs.badWindow = 15;
							else if (ClientPrefs.badWindow > 135)
								ClientPrefs.badWindow = 135;
						case 'Safe Frames':
							ClientPrefs.safeFrames += floatAdd;
							if (ClientPrefs.safeFrames < 2)
								ClientPrefs.safeFrames = 2;
							else if (ClientPrefs.safeFrames > 10)
								ClientPrefs.safeFrames = 10;
						case 'Camera Mov Displacement':
							ClientPrefs.cameraMovementDisplacement += floatAdd;
							if (ClientPrefs.cameraMovementDisplacement < 5)
								ClientPrefs.cameraMovementDisplacement = 5;
							else if (ClientPrefs.cameraMovementDisplacement > 50)
								ClientPrefs.cameraMovementDisplacement = 50;
					}
				reloadValues();

				if (holdTime <= 0)
					FlxG.sound.play(Paths.sound('scrollMenu'));
				holdTime += elapsed;
			}
			else
			{
				holdTime = 0;
			}
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeState(change:Int = 0, options:Array<String>)
	{
		index += change;
		if (index < 0)
			index = options.length - 1;
		if (index >= options.length)
			index = 0;
	}

	function changeSelection(change:Int = 0)
	{
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var daText:String = '';
		switch (options[curSelected])
		{
			case 'Framerate':
				daText = "Pretty self explanatory, isn't it?\nDefault value is 60.";
			case 'Note Delay':
				daText = "Changes how late a note is spawned.\nUseful for preventing audio lag from wireless earphones.";
			case 'FPS Counter':
				daText = "If unchecked, hides FPS Counter.";
			case 'Low Quality':
				daText = "If checked, disables some background details,\ndecreases loading times and improves performance.";
			case 'Persistent Cached Data':
				daText = "If checked, images loaded will stay in memory\nuntil the game is closed, this increases memory usage,\nbut basically makes reloading times instant.";
			case 'Anti-Aliasing':
				daText = "If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth.";
			case 'Downscroll':
				daText = "If checked, notes go Down instead of Up, simple enough.";
			case 'Middlescroll':
				daText = "If checked, hides Opponent's notes and your notes get centered.";
			case 'Ghost Tapping':
				daText = "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.";
			case 'Swearing':
				daText = "If unchecked, your mom won't be angry at you.";
			case 'Violence':
				daText = "If unchecked, you won't get disgusted as frequently.";
			case 'Note Splashes':
				daText = "If unchecked, hitting \"Sick!\" notes won't show particles.";
			case 'Flashing Lights':
				daText = "Uncheck this if you're sensitive to flashing lights!";
			case 'Camera Zooms':
				daText = "If unchecked, the camera won't zoom in on a beat hit.";
			case 'Hide HUD':
				daText = "If checked, hides most HUD elements.";
			case 'Hide Song Length':
				daText = "If checked, the bar showing how much time is left\nwill be hidden.";
			case "Memory Counter":
				daText = "Displays a memory counter";

			case 'Score Text Zoom on Hit':
				daText = "If unchecked, disables the Score text zooming\neverytime you hit a note.";
			case 'Camera Movement':
				daText = 'Moves the camera to the strum direction';
			case 'Icon Boping':
				daText = "If checked, icons bop";
			case 'Pause Music':
				daText = "What song do you prefer for the Pause Screen?";
			case "Miss Volume":
				daText = "How loud should be the miss sound?";
			case "Hitsound Volume":
				daText = "How loud should be the hitsound?";
			case 'Score Text design':
				daText = "Type of formatting on score text\nEngine: Score Misses Accuracy Rating (Full Combo Rating)\nPsych: Score Misses Rating (Accuracy) - Full Combo Rating";
			case 'Input':
				daText = "Type of input for keypresses\nI think that there isnt that much of a difference but here you go";
			case 'Smooth cam zooms':
				daText = "If you want Psych cam zooms or Kade cam zooms";
			case 'Opponent Note Splashes':
				daText = "If enabled, note splashes will show on opponent note hit";
			case 'Rating Offset':
				daText = 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.';
			case 'Sick! Hit Window':
				daText = 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.';
			case 'Good Hit Window':
				daText = 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.';
			case 'Bad Hit Window':
				daText = 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.';
			case 'Safe Frames':
				daText = 'Changes how many frames you have for\nhitting a note earlier or late.';
			case 'Freestyle BF':
				daText = 'If enabled, BF will sing in the strum direction\nonly works with Ghost Tapping';
			case 'Combo Stacking':
				daText = "If unchecked, Ratings and Combo won't stack\nsaving on System Memory and making them easier to read";
			case 'Camera Mov Displacement':
				daText = "Changes the camera displace value\nOnly works if camera movement is enabled";
			case 'Pause game when focus is lost':
				daText = "I don't know if I should put something here";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
				{
					item.alpha = 1;
				}

				for (j in 0...checkboxArray.length)
				{
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if (tracker == item)
					{
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				text.alpha = 0.6;
				if (textNumber[i] == curSelected)
				{
					text.alpha = 1;
				}
			}
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadValues()
	{
		for (i in 0...checkboxArray.length)
		{
			var checkbox:CheckboxThingie = checkboxArray[i];
			if (checkbox != null)
			{
				var daValue:Bool = false;
				switch (options[checkboxNumber[i]])
				{
					case 'FPS Counter':
						daValue = ClientPrefs.showFPS;
					case 'Low Quality':
						daValue = ClientPrefs.lowQuality;
					case 'Anti-Aliasing':
						daValue = ClientPrefs.globalAntialiasing;
					case 'Note Splashes':
						daValue = ClientPrefs.noteSplashes;
					case 'Flashing Lights':
						daValue = ClientPrefs.flashing;
					case 'Downscroll':
						daValue = ClientPrefs.downScroll;
					case 'Middlescroll':
						daValue = ClientPrefs.middleScroll;
					case 'Ghost Tapping':
						daValue = ClientPrefs.ghostTapping;
					case 'Swearing':
						daValue = ClientPrefs.cursing;
					case 'Violence':
						daValue = ClientPrefs.violence;
					case 'Camera Zooms':
						daValue = ClientPrefs.camZooms;
					case 'Hide HUD':
						daValue = ClientPrefs.hideHud;
					case 'Persistent Cached Data':
						daValue = ClientPrefs.imagesPersist;
					case 'Hide Song Length':
						daValue = ClientPrefs.hideTime;
					case 'Memory Counter':
						daValue = ClientPrefs.showMemory;
					case 'Score Text Zoom on Hit':
						daValue = ClientPrefs.optScoreZoom;
					case 'Camera Movement':
						daValue = ClientPrefs.cameraMovement;
					case 'Icon Boping':
						daValue = ClientPrefs.iconBoping;
					case 'Smooth cam zooms':
						daValue = ClientPrefs.smoothCamZoom;
					case 'Opponent Note Splashes':
						daValue = ClientPrefs.opponentNoteSplash;
					case 'Freestyle BF':
						daValue = ClientPrefs.ghostTappingBFSing;
					case 'Combo Stacking':
						daValue = ClientPrefs.comboStacking;
					case 'Pause game when focus is lost':
						daValue = ClientPrefs.pauseOnFocusLost;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length)
		{
			var text:AttachedText = grpTexts.members[i];
			if (text != null)
			{
				var daText:String = '';
				switch (options[textNumber[i]])
				{
					case 'Framerate':
						daText = '' + ClientPrefs.framerate;
					case 'Pause Music':
						daText = ClientPrefs.pauseMusic;
					case "Miss Volume":
						daText = Math.round(ClientPrefs.missVolume * 100) + '%';
					case "Hitsound Volume":
						daText = Math.round(ClientPrefs.hitsoundVolume * 100) + '%';
					case 'Score Text design':
						daText = ClientPrefs.scoreTextDesign;
					case 'Input':
						daText = ClientPrefs.inputType;
					case 'Rating Offset':
						daText = ClientPrefs.ratingOffset + "ms";
					case 'Sick! Hit Window':
						daText = ClientPrefs.sickWindow + "ms";
					case 'Good Hit Window':
						daText = ClientPrefs.goodWindow + "ms";
					case 'Bad Hit Window':
						daText = ClientPrefs.badWindow + "ms";
					case 'Safe Frames':
						daText = '' + FlxMath.roundDecimal(ClientPrefs.safeFrames, 1);
					case 'Camera Mov Displacement':
						daText = '' + FlxMath.roundDecimal(ClientPrefs.cameraMovementDisplacement, 1);
				}
				var lastTracker:FlxSprite = text.sprTracker;
				text.sprTracker = null;
				text.changeText(daText);
				text.sprTracker = lastTracker;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool
	{
		for (i in 0...unselectableOptions.length)
		{
			if (options[num] == unselectableOptions[i])
			{
				return true;
			}
		}
		return options[num] == '';
	}
}
