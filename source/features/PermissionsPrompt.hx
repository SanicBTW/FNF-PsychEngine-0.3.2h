package features;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Constraints.Function;

using StringTools;

#if android
import com.player03.android6.Permissions;
#end

class PermissionsPrompt extends MusicBeatState
{
	var storagePrompt:Prompt;

	override function create()
	{
		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		#if (!STORAGE_ACCESS) // send to title state if none of the features are enabled
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
		#end

		#if (STORAGE_ACCESS) // do the griddy if some feature was found enabled
		if (!ClientPrefs.answeredReq)
		{
			var bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"), false, FlxG.width, FlxG.height);
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
			#if STORAGE_ACCESS
			storagePrompt = new Prompt('FileSystem Access', "Do you want to allow access to the filesystem?");
			storagePrompt.screenCenter();
			storagePrompt.titleTxt.size = 20;
			storagePrompt.infoTxt.size = 23;
			storagePrompt.b1Callback = accepted;
			storagePrompt.b2Callback = denied;
			add(storagePrompt);
			#end
		}
		else
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new TitleState());
		}
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function accepted()
	{
		#if !android
		strgePrmptTwn(function()
		{
			remove(storagePrompt);
			ClientPrefs.allowFileSys = true;
			ClientPrefs.answeredReq = true;
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new TitleState());
		});
		#else
		Permissions.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
		// im stupid okay?
		Permissions.onPermissionsDenied.add(function(args)
		{
			denied();
		});

		// IM REALLY REALLY STUPID OKAY?
		Permissions.onPermissionsGranted.add(function(args)
		{
			androidAccepted();
		});
		#end
	}

	function denied()
	{
		strgePrmptTwn(function()
		{
			remove(storagePrompt);
			ClientPrefs.allowFileSys = false;
			ClientPrefs.answeredReq = true;
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new TitleState());
		});
	}

	function androidAccepted()
	{
		strgePrmptTwn(function()
		{
			remove(storagePrompt);
			ClientPrefs.allowFileSys = true;
			ClientPrefs.answeredReq = true;
			ClientPrefs.saveSettings();
			MusicBeatState.switchState(new TitleState());
		});
	}

	function strgePrmptTwn(onComplete:Function)
	{
		FlxTween.tween(storagePrompt, {alpha: 0}, 1, {onComplete: onComplete()});
	}
}
