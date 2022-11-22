package features;

import features.OnlineItem.Funkin_Chars;
import haxe.Json;
import features.OnlineItem.Funkin;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.media.Sound;
import openfl.net.URLRequest;
import openfl.system.System;

using StringTools;

class OnlineSongSelection extends MusicBeatState
{
	var items:Map<String, OnlineItem> = new Map();
	var songs:Array<String> = [];
	var grpSongs:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var baseURL:String = "http://sancopublic.ddns.net:5430/api/";
	var recordsExtension:String = "collections/funkin/records";
	//var recordsCharExtension:String = "collections/funkin_chars/records";
	var filesExtension:String = "files/funkin/:id/:file";
	var charExtension:String = "files/funkin_chars/:id/:file";
	var progressIndicators:FlxTypedGroup<ProgressIndicator>;

	override public function new()
	{
		super();

		#if html5
		if (js.Browser.location.protocol == "https:")
		{
			var shit = js.Browser.createXMLHttpRequest();

			shit.addEventListener('load', function()
			{
				var more = shit.responseText.split('\n');

				for (line in more)
				{
					var det = line.split('|');

					if (det[0] == "secure")
					{
						baseURL = det[1];
						break;
					}
				}
			});

			shit.open("GET", "https://raw.githubusercontent.com/SanicBTW/FNF-PsychEngine-0.3.2h/master/server.sanco");
			shit.send();
		}
		#end
	}

	override function create()
	{
		super.create();

		Paths.clearCache();
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = SaveData.get(ANTIALIASING);
		bg.screenCenter();
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		progressIndicators = new FlxTypedGroup<ProgressIndicator>();
		add(grpSongs);
		add(progressIndicators);

		#if html5
		//var charReq = js.Browser.createXMLHttpRequest();
		//charReq.open("GET", baseURL + recordsCharExtension);
		//charReq.send();

		var req = js.Browser.createXMLHttpRequest();
		req.addEventListener('load', function()
		{
			var songShit:Array<Funkin> = cast Json.parse(req.responseText).items;
			//var charShit:Array<Funkin_Chars> = cast Json.parse(charReq.responseText).items;
			trace(songShit);
			//trace(charShit);
			for (i in 0...songShit.length)
			{
				var funkin:Funkin = songShit[i];
				trace(funkin);
				var id = filesExtension.replace(":id", funkin.id);
				var chartPath = baseURL + id.replace(":file", funkin.chart);
				var eventPath = "";
				if (funkin.events != "")
					eventPath = baseURL + id.replace(":file", funkin.events);

				var instPath = baseURL + id.replace(":file", funkin.inst);

				var voicesPath = "";
				if (funkin.voices != "")
					voicesPath = baseURL + id.replace(":file", funkin.voices);

				items.set(funkin.song, new OnlineItem(funkin.song, chartPath, eventPath, instPath, voicesPath, [], []));
				songs.push(funkin.song);
			}
		});
		req.addEventListener('loadend', function()
		{
			regenMenu();
		});
		req.open("GET", baseURL + recordsExtension);
		req.send();
		#else
		#end
	}

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new FreeplayState());
		}

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

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
				changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
		}

		if (controls.ACCEPT)
		{
			var shit = items.get(songs[curSelected]);

			#if html5
			var request = js.Browser.createXMLHttpRequest();
			var eventsReq = js.Browser.createXMLHttpRequest();

			eventsReq.open("GET", shit.eventPath);

			request.addEventListener('load', function()
			{
				persistentUpdate = false;

				PlayState.SONG = Song.loadFromRaw(request.responseText);

				if (shit.eventPath != "")
					eventsReq.send();

				Sound.loadFromFile(shit.instPath).onComplete(function(sound)
				{
					PlayState.instSource = sound;
				});

				if (shit.voicesPath != "")
				{
					Sound.loadFromFile(shit.voicesPath).onComplete(function(sound)
					{
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

			eventsReq.addEventListener('load', function()
			{
				PlayState.songEvents = Song.loadFromRaw(eventsReq.responseText).events;
			});
			request.open("GET", shit.chartPath);
			request.send();
			#else
			#end
		}

		super.update(elapsed);
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
