package onlinecopy;

import lime.app.Future;
import openfl.media.Sound;
import js.html.ProgressEvent;
import haxe.Json;
import openfl.system.System;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class SongsListState extends MusicBeatState
{
    var songItems:FlxTypedGroup<SongItem>;
    var options:FlxTypedGroup<SongItem>;
    var onlineSongs:Map<String, Array<String>> = new Map<String, Array<String>>();

    override function create()
    {
        FlxG.mouse.visible = true;

        songItems = new FlxTypedGroup<SongItem>();
        add(songItems);

        options = new FlxTypedGroup<SongItem>();
        add(options);

        var curItemPos = 340;
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

                songItems.add(new SongItem(onlineSongItemName, 460, curItemPos - 55, _clicked));
                curItemPos -= 55;

				System.gc();
			}

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

        super.update(elapsed);
    }

    function _clicked(args:Array<Dynamic>)
    {
        var item:SongItem = args[0];
        var theShit = onlineSongs.get(item.songTxt.text);

        songItems.forEach(function(songItem:SongItem)
        {
            if(songItem != item)
                songItem.downloadProgress = 0;
        });

        var request = js.Browser.createXMLHttpRequest();
        request.addEventListener("load", function()
        {
            PlayState.SONG = Song.parseJSONshit(request.responseText);

            if (options.length > 0)
            {
                options.clear();
            }

            var curItemPos = 340;
            var instItem:SongItem = new SongItem("Inst", 60, curItemPos - 55, _clickedInst);
            instItem.parentItem = item;
            curItemPos -= 55;
            var voicesItem:SongItem = new SongItem("Voices", 60, curItemPos - 55, _clickedVoices);
            voicesItem.parentItem = item;

            options.add(instItem);
            if(PlayState.SONG.needsVoices)
                options.add(voicesItem);
        });
        request.addEventListener("progress", function(prog:ProgressEvent)
        {
            item.downloadProgress = (prog.loaded / prog.total) * 100;
        });
        request.open("GET", theShit[0]);
        request.send();
    }

    function _clickedInst(args:Array<Dynamic>)
    {
        var parentitem:SongItem = args[1];
        var item:SongItem = args[0];
        var tehThing = onlineSongs.get(parentitem.songTxt.text);

        Sound.loadFromFile(tehThing[1]).then(function(inst)
        {
            PlayState.inst = inst;
            return Future.withValue(inst);
        }).onProgress(function(i1, i2)
        {
            FlxG.log.add(i1 + "/" + i2);
            item.downloadProgress = (i1 / i2) * 100;
        });
    }

    function _clickedVoices(args:Array<Dynamic>)
    {

    }
}