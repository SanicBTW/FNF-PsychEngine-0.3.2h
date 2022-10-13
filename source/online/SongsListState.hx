package online;

import flixel.ui.FlxBar;
import lime.app.Future;
import openfl.media.Sound;
import js.html.ProgressEvent;
import haxe.Json;
import openfl.system.System;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class SongsListState extends MusicBeatState
{
    var onlineSongs:Map<String, Array<String>> = new Map<String, Array<String>>();
    var grpSongs:FlxTypedGroup<Alphabet>;
    var items:Array<String> = [];
    var curSelected:Int = 0;

    var progressBar:FlxBar;

    var chartDownloaded:Bool = false;
    var songSelected:String = "";

    var instDownloaded:Bool = false;
    var voicesDownloaded:Bool = false;

    override function create()
    {
        items = [];
		openfl.Assets.cache.clear("assets");
		openfl.Assets.cache.clear("songs");
		openfl.Assets.cache.clear("images");

		PlayState.inst = null;
		PlayState.voices = null;
		PlayState.SONG = null;

        progressBar = new FlxBar();
        progressBar.screenCenter();
        progressBar.y = FlxG.height * 0.97;
        progressBar.screenCenter(X);
        progressBar.scale.set(10, 1);
        add(progressBar);

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        var request = js.Browser.createXMLHttpRequest();
		request.addEventListener('load', function()
		{
			var onlineSongItems:Dynamic = cast Json.parse(request.responseText).items;
			for(i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song_name;

				var chartPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].chart_file;
				var instPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].inst;
				var voicesPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].voices;

				onlineSongs.set(onlineSongItemName, [chartPath, instPath, voicesPath, onlineSongItems[i].difficulty]);

                items.push(onlineSongItemName);

				System.gc();
			}
		});
        request.addEventListener("loadend", function()
        {
            regenMenu();
        });
		request.open("GET", 'http://sancopublic.ddns.net:5430/api/collections/fnf_charts/records');
		request.send();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.BACK)
        {
            MusicBeatState.switchState(new FreeplayState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT)
        {
            if(chartDownloaded == false)
            {
                songSelected = items[curSelected];

                var request = js.Browser.createXMLHttpRequest();
                request.addEventListener("load", function()
                {
                    PlayState.SONG = Song.loadFromJson(request.responseText, true);

                    items = ["Download inst"];
                    if(PlayState.SONG.needsVoices)
                        items.push("Download voices");
                });
                request.addEventListener("loadend", function()
                {
                    regenMenu();

                    chartDownloaded = true;
                });
                request.addEventListener("progress", function(prog:ProgressEvent)
                {
                    //FlxG.log.add((prog.loaded / prog.total) * 100);
                    progressBar.percent = (prog.loaded / prog.total) * 100;
                });
                request.open("GET", onlineSongs.get(items[curSelected])[0]);
                request.send();
            }
            if(chartDownloaded == true)
            {
                if(instDownloaded == false && items[curSelected] == "Download inst")
                {
                    Sound.loadFromFile(onlineSongs.get(songSelected)[1]).onProgress(function(i1, i2)
                    {
                        FlxG.log.add(i1 + "/" + i2);
                    }).onComplete(function(sound)
                    {
                        instDownloaded = true;
                        items[curSelected] = "Inst downloaded";
                        PlayState.inst = sound;
                        regenMenu();
                    });
                }

                if(voicesDownloaded == false && items[curSelected] == "Download voices")
                {
                    Sound.loadFromFile(onlineSongs.get(songSelected)[2]).onProgress(function(i1, i2)
                    {
                        FlxG.log.add(i1 + "&" + i2);
                    }).onComplete(function(sound)
                    {
                        voicesDownloaded = true;
                        items[curSelected] = "Voices downloaded";
                        PlayState.voices = sound;
                        regenMenu();
                    });
                }

                if(items.contains("Play"))
                {
                    persistentUpdate = false;

                    PlayState.isStoryMode = false;
                    PlayState.storyDifficulty = 1;
                    PlayState.storyWeek = 0;

                    LoadingState.loadAndSwitchState(new PlayState(), false, true);

                    if(FlxG.sound.music != null)
                    {
						FlxG.sound.music.volume = 0;
					}
                }
            }
        }

        if(instDownloaded == true && voicesDownloaded == true && items.contains("Play") == false)
        {
            items = ["Play"];
            regenMenu();
        }

        super.update(elapsed);
    }

    function regenMenu()
    {
        grpSongs.clear();

        for (i in 0...items.length)
        {
            var text:Alphabet = new Alphabet(0, (70 * i) + 30, items[i].toString(), true, false);
            text.isMenuItem = true;
            text.targetY = i;
            grpSongs.add(text);
        }

        curSelected = 0;
        changeSelection();
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if(curSelected < 0)
            curSelected = grpSongs.length - 1;
        if(curSelected >= grpSongs.length)
            curSelected = 0;

        var what:Int = 0;

        grpSongs.forEach(function(item:Alphabet)
        {
            item.targetY = what - curSelected;
            what++;

            item.alpha = 0.5;

            if(item.targetY == 0){ item.alpha = 1; }
        });
    }
}