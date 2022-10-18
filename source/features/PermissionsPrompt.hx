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

	override function create()
	{
		PlayerSettings.init();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		ClientPrefs.loadPrefs();

		#if (!STORAGE_ACCESS && !ONLINE_SONGS) // send to title state if none of the features are enabled
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		MusicBeatState.switchState(new TitleState());
		#end

		#if (STORAGE_ACCESS || ONLINE_SONGS) // do the griddy if some feature was found enabled
		if (!ClientPrefs.answeredReq)
		{
			var bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"), false, FlxG.width, FlxG.height);
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			add(bg);
			#if ONLINE_SONGS
			onlineSongsPrompt = new Prompt("Online Fetching", "Do you want to allow fetching songs from an online server? (Hosted by me), it can be offline sometimes, and it needs a good internet connection :(");
			onlineSongsPrompt.screenCenter();
			onlineSongsPrompt.b1Callback = accepted;
			onlineSongsPrompt.b2Callback = denied;
			#if STORAGE_ACCESS
			onlineSongsPrompt.x -= 220;
			#end
			add(onlineSongsPrompt);
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

	function accepted(promptName:String)
	{
		switch(promptName)
		{
			case "Online Fetching":
				promptShit(onlineSongsPrompt, storagePrompt, "allowOnlineFetching", true);
			case "FileSystem Access":
				#if !android
				promptShit(storagePrompt, onlineSongsPrompt, "allowFileSys", true);
				#else
				Permissions.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
				Permissions.onPermissionsDenied.add(function(args)
				{
					promptShit(storagePrompt, onlineSongsPrompt, "allowFileSys", false);
				});

				Permissions.onPermissionsGranted.add(function(args)
				{
					promptShit(storagePrompt, onlineSongsPrompt, "allowFileSys", true);
				});
				#end
		}
	}

	// dumb much??
	function denied(promptName:String)
	{
		switch(promptName)
		{
			case "Online Fetching":
				promptShit(onlineSongsPrompt, storagePrompt, "allowOnlineFetching", false);
			case "FileSystem Access":
				promptShit(storagePrompt, onlineSongsPrompt, "allowFileSys", false);
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

		if(prompt.x == 675)
			newX = prompt.x - 220;
		else if(prompt.x == 235)
			newX = prompt.x + 220;

		return newX;
	}

	function everythingDone()
	{
		ClientPrefs.answeredReq = true;
		ClientPrefs.saveSettings();
		MusicBeatState.switchState(new TitleState());
	}


	// easier but hardcoded
	function promptShit(curPrompt:Prompt, nextPrompt:Prompt, field:String, state:Bool)
	{
		promptAlphaTween(curPrompt, function()
		{
			Reflect.setProperty(ClientPrefs, field, state);

			remove(curPrompt);

			if(nextPrompt != null)
				promptMoveTween(nextPrompt);
			else
				everythingDone();
		});
	}
}
