package;

import Controls;
import flash.text.TextField;
import flash.text.TextField;
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

// TO DO: Redo the menu creation system for not being as dumb
class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Notes',
		'Adjust Delay and Combo',
		#if android 'Mobile Controls', #end
		'Controls',
		'Preferences',
		#if (STORAGE_ACCESS) 'Revoke permissions', #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			grpOptions.add(optionText);
		}
		changeSelection();

		#if android
		addVirtualPad(LEFT_FULL, A_B);
		#end

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		FlxTransitionableState.skipNextTransOut = true;
		FlxG.resetState();
		ClientPrefs.saveSettings();
		changeSelection();
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
			for (item in grpOptions.members)
			{
				item.alpha = 0;
			}

			switch (options[curSelected])
			{
				case 'Notes':
					openSubState(new options.NotesSubstate());

				#if android
				case 'Mobile Controls':
					openSubState(new android.AndroidControlsSubState());
				#end

				case 'Controls':
					openSubState(new options.ControlsSubstate());

				case 'Preferences':
					openSubState(new options.PreferencesSubstate());

				case 'Adjust Delay and Combo':
					LoadingState.loadAndSwitchState(new options.NoteOffsetState());

				// on android, if you gave perms to the app you need to manually remove them in settings, this only removes the code access to filesystem nothing else
				case 'Revoke permissions':
					#if windows
					DiscordClient.shutdown();
					#end

					TitleState.initialized = false;
					TitleState.closedState = false;

					ClientPrefs.allowFileSys = false;
					ClientPrefs.answeredReq = false;
					ClientPrefs.saveSettings();

					FlxG.mouse.visible = true;

					FlxG.sound.music.fadeOut(0.3);
					Main.tweenFPS(false, 0.5);
					Main.tweenMemory(false, 0.5);
					FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
			}
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
	}
}
