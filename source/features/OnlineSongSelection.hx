package features;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.media.Sound;
import openfl.net.URLRequest;
import openfl.system.System;

using StringTools;

class OnlineSongSelection extends MusicBeatState
{
	var songsMap:Map<String, Array<String>> = new Map();
	var songs:Array<String> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var blockInputs:Bool = false;
	var fetchThis:String = "https://raw.githubusercontent.com/SanicBTW/FNF-PsychEngine-0.3.2h/master/server.sanco";
	var baseURL:String = "http://sancopublic.ddns.net:5430/api/";
	var extensionRecordsURL:String = "collections/funkin/records";
	var extensionFilesURL:String = "files/funkin/:id/:file"; // replace :id with the id and :file with file path lol
	var isHTTPS:Bool = false;

	// will add scores for the next commit/update
	// maybe i will add a difficulty display too?
	// no progress bar because it doesnt properly set the progress for some reason

	override public function new()
	{
		super();

		#if html5
		if (js.Browser.location.protocol == "https:")
		{
			isHTTPS = true;
			trace("I hate my life so fucking much");
		}

		var checkShit = js.Browser.createXMLHttpRequest();

		checkShit.addEventListener('load', function()
		{
			var servershit = checkShit.responseText.split("\n");

			for (line in servershit)
			{
				var details = line.split("|");
				trace(details[0]);
				trace(details[1]);

				if (isHTTPS && details[0] == "secure") // uh
				{
					baseURL = details[1];
					break;
				}
			}
		});

		checkShit.open("GET", fetchThis);
		checkShit.send();
		#end
	}

	override function create()
	{
		super.create();

		Paths.clearCache();

		var bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = SaveData.get(ANTIALIASING);
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		#if html5
		var request = js.Browser.createXMLHttpRequest();
		// when getting data i guess
		request.addEventListener('load', function()
		{
			var onlineSongItems:Dynamic = cast haxe.Json.parse(request.responseText).items;
			for (i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song;

				var fixedID = extensionFilesURL.replace(":id", onlineSongItems[i].id);

				var chartPath = baseURL + fixedID.replace(":file", onlineSongItems[i].chart);

				var eventPath = "";
				if (onlineSongItems[i].events != "")
					eventPath = baseURL + fixedID.replace(":file", onlineSongItems[i].events);

				var instPath = baseURL + fixedID.replace(":file", onlineSongItems[i].inst);

				var voicesPath = "";
				if (onlineSongItems[i].voices != "")
					voicesPath = baseURL + fixedID.replace(":file", onlineSongItems[i].voices);

				songsMap.set(onlineSongItemName, [chartPath, eventPath, instPath, voicesPath]);
				songs.push(onlineSongItemName);
			}
		});
		// when it finishes
		request.addEventListener('loadend', function()
		{
			// to avoid having errors, we generate the shit when it finishes loading
			regenMenu();
		});
		request.open("GET", baseURL + extensionRecordsURL);
		request.send();
		#else
		var http = new haxe.Http(baseURL + extensionRecordsURL);
		http.onData = function(data:String)
		{
			var onlineSongItems:Dynamic = cast haxe.Json.parse(data).items;
			for (i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song;

				var fixedID = extensionFilesURL.replace(":id", onlineSongItems[i].id);

				var chartPath = baseURL + fixedID.replace(":file", onlineSongItems[i].chart);

				var eventPath = "";
				if (onlineSongItems[i].events != "")
					eventPath = baseURL + fixedID.replace(":file", onlineSongItems[i].events);

				var instPath = baseURL + fixedID.replace(":file", onlineSongItems[i].inst);

				var voicesPath = "";
				if (onlineSongItems[i].voices != "")
					voicesPath = baseURL + fixedID.replace(":file", onlineSongItems[i].voices);

				songsMap.set(onlineSongItemName, [chartPath, eventPath, instPath, voicesPath]);
				songs.push(onlineSongItemName);
			}
			regenMenu();
		}
		http.request();
		#end

		#if android
		addVirtualPad(UP_DOWN, A_B);
		#end
	}

	var holdTime:Float = 0; // funky keep pressin shit

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (blockInputs == false)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplayState());
			}

			var shiftMult:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftMult = 3;

			// just in case
			if (songs.length > 1)
			{
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT)
			{
				var songShit = songsMap.get(songs[curSelected]);

				#if html5
				var request = js.Browser.createXMLHttpRequest();
				var eventsReq = js.Browser.createXMLHttpRequest();

				eventsReq.open("GET", songShit[1]);

				// gonna make it download the sounds automatically
				request.addEventListener("load", function()
				{
					blockInputs = true; // WHY IT ISNT WORKINGGGGGGG
					notificationGroup.add(new Notification("Chart loaded"));

					// to check if it needs voices
					PlayState.SONG = Song.loadFromRaw(request.responseText);

					if (songShit[1] != "")
						eventsReq.send();

					Sound.loadFromFile(songShit[2]).onComplete(function(sound)
					{
						notificationGroup.add(new Notification("Inst loaded"));
						PlayState.instSource = sound;
					});

					if (songShit[3] != "")
					{
						Sound.loadFromFile(songShit[3]).onComplete(function(sound)
						{
							notificationGroup.add(new Notification("Voices loaded"));
							PlayState.voicesSource = sound;
							goToPlayState();
						});
					}
					else
					{
						PlayState.voicesSource = null;
						goToPlayState();
					}
				});

				eventsReq.addEventListener("load", function()
				{
					notificationGroup.add(new Notification("Events loaded"));
					PlayState.songEvents = Song.loadFromRaw(eventsReq.responseText).events;
				});

				request.open("GET", songShit[0]);
				request.send();
				#else
				var http = new haxe.Http(songShit[0]);
				var reqEvents = new haxe.Http(songShit[1]);
				http.onData = function(data:String)
				{
					blockInputs = true; // WHY IT ISNT WORKINGGGGGGG

					PlayState.SONG = Song.loadFromRaw(data);

					if (songShit[1] != "")
						reqEvents.request();

					PlayState.instSource = new Sound(new URLRequest(songShit[2]));
					if (PlayState.SONG.needsVoices && songShit[3] != "")
					{
						PlayState.voicesSource = new Sound(new URLRequest(songShit[3]));
						goToPlayState();
					}
					else
						goToPlayState();
				}

				reqEvents.onData = function(data:String)
				{
					PlayState.songEvents = Song.loadFromRaw(data).events;
				}

				http.request();
				#end
				blockInputs = true; // AAAAAAAAAAA
			}
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var tf:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = tf - curSelected;
			tf++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	function goToPlayState()
	{
		persistentUpdate = false;

		PlayState.storyDifficulty = 2;
		PlayState.storyWeek = 0;

		notificationGroup.add(new Notification("All done!", "Switching to PlayState"));

		LoadingState.loadAndSwitchState(new PlayState(), false);

		System.gc();
	}

	function regenMenu()
	{
		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}
		}
		changeSelection(0, false);
	}
}
