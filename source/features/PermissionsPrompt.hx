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
	var onlineSongsPrompt:Prompt;
	var mapPrompts:Map<String, Prompt> = new Map();

	override function create()
	{
		PlayerSettings.init();

		FlxG.save.bind('funkin', 'sanicbtw');
		SaveData.loadSettings();
		#if js
		MainWorker.startWorker();
		#end
		Paths.prepareLibraries();

		#if (!STORAGE_ACCESS && !ONLINE_SONGS) // send to title state if none of the features are enabled
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
		#end

		#if (STORAGE_ACCESS || ONLINE_SONGS) // do the griddy if some feature was found enabled
		if (!SaveData.get(ANSWERED))
		{
			var bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"), false, FlxG.width, FlxG.height);
			bg.screenCenter();
			bg.antialiasing = SaveData.get(ANTIALIASING);
			add(bg);
			#if ONLINE_SONGS
			onlineSongsPrompt = new Prompt("Online Fetching",
				"Do you want to allow fetching songs from an online server? (Hosted by me), it can be offline sometimes, and it needs a good internet connection :(");
			onlineSongsPrompt.screenCenter();
			onlineSongsPrompt.b1Callback = accepted;
			onlineSongsPrompt.b2Callback = denied;
			#if STORAGE_ACCESS
			onlineSongsPrompt.x -= 220;
			#end
			add(onlineSongsPrompt);
			mapPrompts.set("Online Fetching", onlineSongsPrompt);
			#end

			#if STORAGE_ACCESS
			storagePrompt = new Prompt('FileSystem Access', "Do you want to allow access to the filesystem?");
			storagePrompt.screenCenter();
			storagePrompt.titleTxt.size = 20;
			storagePrompt.infoTxt.size = 23;
			storagePrompt.b1Callback = accepted;
			storagePrompt.b2Callback = denied;
			#if ONLINE_SONGS
			storagePrompt.x += 220;
			#end
			add(storagePrompt);
			mapPrompts.set("FileSystem Access", storagePrompt);
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

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// because i want to kms so badly
		if (!mapPrompts.exists("Online Fetching") && !mapPrompts.exists("FileSystem Access") && !transitioning)
		{
			everythingDone();
		}
	}

	function accepted(promptName:String)
	{
		switch (promptName)
		{
			case "Online Fetching":
				promptShit(onlineSongsPrompt, storagePrompt, ALLOW_ONLINE, true);
			case "FileSystem Access":
				#if !android
				promptShit(storagePrompt, onlineSongsPrompt, ALLOW_FILESYS, true);
				#else
				Permissions.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
				Permissions.onPermissionsDenied.add(function(args)
				{
					promptShit(storagePrompt, onlineSongsPrompt, ALLOW_FILESYS, false);
				});

				Permissions.onPermissionsGranted.add(function(args)
				{
					promptShit(storagePrompt, onlineSongsPrompt, ALLOW_FILESYS, true);
				});
				#end
		}
	}

	// dumb much??
	function denied(promptName:String)
	{
		switch (promptName)
		{
			case "Online Fetching":
				promptShit(onlineSongsPrompt, storagePrompt, ALLOW_ONLINE, false);
			case "FileSystem Access":
				promptShit(storagePrompt, onlineSongsPrompt, ALLOW_FILESYS, false);
		}
	}

	function promptAlphaTween(prompt:Prompt, onComplete:Function)
	{
		FlxTween.tween(prompt, {alpha: 0}, 1, {onComplete: onComplete()});
	}

	function promptMoveTween(prompt:Prompt)
	{
		FlxTween.tween(prompt, {x: getNewXPos(prompt)}, 1, {ease: FlxEase.smoothStepInOut});
	}

	function getNewXPos(prompt:Prompt):Float
	{
		var newX:Float = 0;

		if (prompt.x == 675)
			newX = prompt.x - 220;
		else if (prompt.x == 235)
			newX = prompt.x + 220;

		return newX;
	}

	function everythingDone()
	{
		transitioning = true;
		SaveData.set(ANSWERED, true);
		SaveData.saveSettings();
		MusicBeatState.switchState(new TitleState());
	}

	// easier but hardcoded
	function promptShit(curPrompt:Prompt, nextPrompt:Prompt, field:SaveData.Settings, state:Bool)
	{
		promptAlphaTween(curPrompt, function()
		{
			SaveData.set(field, state);

			mapPrompts.remove(curPrompt.titleTxt.text);
			remove(curPrompt);

			if (nextPrompt != null)
				promptMoveTween(nextPrompt);
		});
	}
}
