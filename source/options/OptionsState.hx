package options;

import Controls;
import flash.text.TextField;
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class OptionsState extends MusicBeatState
{
	// this shit huge like yo mom haha
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Gameplay',
		'Input',
		'Camera',
		'Visuals and UI',
		'Audio',
		'Ratings',
		'Miscellaneous',
		#if android 'Mobile Controls', #end
		#if (STORAGE_ACCESS || ONLINE_SONGS) 'Revoke permissions' #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Note Colors':
				openSubState(new NotesSubState());
			case 'Controls':
				openSubState(new ControlsSubState());
			case 'Graphics':
				openSubState(new GraphicsSettingsSubState());
			case 'Gameplay':
				openSubState(new GameplaySettingsSubState());
			case 'Input':
				openSubState(new InputSettingsSubState());
			case 'Camera':
				openSubState(new CameraSettingsSubState());
			case 'Visuals and UI':
				openSubState(new VisualsUISubState());
			case 'Audio':
				openSubState(new AudioSettingsSubState());
			case 'Ratings':
				openSubState(new RatingsSubState());
			// placeholder
			case 'Miscellaneous':
				openSubState(new MiscSettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			#if android
			case 'Mobile Controls':
				openSubState(new android.AndroidControlsSubState());
			#end
			case 'Revoke permissions':
				#if windows
				DiscordClient.shutdown();
				#end

				TitleState.initialized = false;
				TitleState.closedState = false;

				SaveData.set(ALLOW_FILESYS, false);
				SaveData.set(ALLOW_ONLINE, false);
				SaveData.set(ANSWERED, false);
				SaveData.saveSettings();

				FlxG.mouse.visible = true;

				FlxG.sound.music.fadeOut(0.3);
				Main.tweenFPS(false, 0.5);
				Main.tweenMemory(false, 0.5);
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
		}
	}

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = SaveData.get(ANTIALIASING);
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		changeSelection();

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		FlxTransitionableState.skipNextTransOut = true;
		FlxG.resetState();
		SaveData.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			#if android
			removeVirtualPad();
			#end
			openSelectedSubstate(options[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
