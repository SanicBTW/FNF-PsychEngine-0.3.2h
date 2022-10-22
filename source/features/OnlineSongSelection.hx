package features;

import openfl.net.URLRequest;
import openfl.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class OnlineSongSelection extends MusicBeatState
{
    var songsMap:Map<String, Array<String>> = new Map();
    var songs:Array<String> = [];
    var grpSongs:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var blockInputs:Bool = false;

    //will add scores for the next commit/update
    //maybe i will add a difficulty display too?
    //no progress bar because it doesnt properly set the progress for some reason

    override function create()
    {
        super.create();

        Main.clearCache(); //why not, though we cleared it in freeplay already

        var bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();

        grpSongs = new FlxTypedGroup<Alphabet>();
        add(grpSongs);

        #if html5
        var request = js.Browser.createXMLHttpRequest();
        //when getting data i guess
        request.addEventListener('load', function()
        {
            var onlineSongItems:Dynamic = cast haxe.Json.parse(request.responseText).items;
			for(i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song;

				var chartPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].chart;
                var eventPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].events;
				var instPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].inst;
				var voicesPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].voices;

				songsMap.set(onlineSongItemName, [chartPath, eventPath, instPath, voicesPath]);
                songs.push(onlineSongItemName);
            }
        });
        //when it finishes
        request.addEventListener('loadend', function()
        {
            //to avoid having errors, we generate the shit when it finishes loading
            regenMenu();
        });
        request.open("GET", 'http://sancopublic.ddns.net:5430/api/collections/funkin/records');
        request.send();
        #else
        var http = new haxe.Http("http://sancopublic.ddns.net:5430/api/collections/funkin/records");
        http.onData = function(data:String)
        {
            var onlineSongItems:Dynamic = cast haxe.Json.parse(data).items;
			for(i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song;

				var chartPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].chart;
                var eventPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].events;
				var instPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].inst;
				var voicesPath = 'http://sancopublic.ddns.net:5430/api/files/funkin/' + onlineSongItems[i].id + "/" + onlineSongItems[i].voices;

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

    var holdTime:Float = 0; //funky keep pressin shit

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(blockInputs == false)
        {
            if(controls.BACK)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new FreeplayState());
            }
        
            var shiftMult:Int = 1;
            if(FlxG.keys.pressed.SHIFT)
                shiftMult = 3;
        
            //just in case
            if(songs.length > 1)
            {
                if(controls.UI_UP_P)
                {
                    changeSelection(-shiftMult);
                    holdTime = 0;
                }
                if(controls.UI_DOWN_P)
                {
                    changeSelection(shiftMult);
                    holdTime = 0;
                }
    
                if(controls.UI_DOWN || controls.UI_UP)
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
        
            if(controls.ACCEPT)
            {
                var songShit = songsMap.get(songs[curSelected]);
    
                #if html5
                var request = js.Browser.createXMLHttpRequest();
                var eventsReq = js.Browser.createXMLHttpRequest();

                eventsReq.open("GET", songShit[1]);
    
                //gonna make it download the sounds automatically
                request.addEventListener("load", function()
                {
                    blockInputs = true; //WHY IT ISNT WORKINGGGGGGG

                    //to check if it needs voices
                    PlayState.SONG = Song.loadFromRaw(request.responseText);

                    eventsReq.send();
    
                    Sound.loadFromFile(songShit[2]).onComplete(function(sound)
                    {
                        PlayState.inst = sound;
                    });
    
                    if(PlayState.SONG.needsVoices)
                    {
                        Sound.loadFromFile(songShit[3]).onComplete(function(sound)
                        {
                            PlayState.voices = sound;
                            goToPlayState();
                        });
                    }
                    else
                        goToPlayState();
                });

                eventsReq.addEventListener("load", function()
                {
                    PlayState.songEvents = Song.loadFromRaw(eventsReq.responseText).events;
                });
    
                request.open("GET", songShit[0]);
                request.send();
                #else
                var http = new haxe.Http(songShit[0]);
                var reqEvents = new haxe.Http(songShit[1]);
                http.onData = function(data:String)
                {
                    blockInputs = true; //WHY IT ISNT WORKINGGGGGGG

                    PlayState.SONG = Song.loadFromRaw(data);

                    reqEvents.request();

                    PlayState.inst = new Sound(new URLRequest(songShit[2]));
                    if(PlayState.SONG.needsVoices)
                    {
                        PlayState.voices = new Sound(new URLRequest(songShit[3]));
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
                blockInputs = true; //AAAAAAAAAAA
            }
        }
    }

    function changeSelection(change:Int = 0, playSound:Bool = true)
    {
        if(playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if(curSelected < 0)
            curSelected = songs.length - 1;
        if(curSelected >= songs.length)
            curSelected = 0;

        var tf:Int = 0;

        for(item in grpSongs.members)
        {
            item.targetY = tf - curSelected;
            tf++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }
    }

    function goToPlayState()
    {
        persistentUpdate = false;

        PlayState.storyDifficulty = 2;
        PlayState.storyWeek = 0;

        OnlineLoadingState.loadAndSwitchState(new PlayState());

        System.gc();
    }

    function regenMenu()
    {
        for(i in 0...songs.length)
        {
            var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpSongs.add(songText);
            if(songText.width > 980)
            {
                var textScale:Float = 980 / songText.width;
                songText.scale.x = textScale;
                for(letter in songText.lettersArray)
                {
                    letter.x *= textScale;
                    letter.offset.x *= textScale;
                }
            }
        }
        changeSelection(0, false);
    }
}
