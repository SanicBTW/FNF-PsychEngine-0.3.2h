package features;

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

        var request = js.Browser.createXMLHttpRequest();
        //when getting data i guess
        request.addEventListener('load', function()
        {
            var onlineSongItems:Dynamic = cast haxe.Json.parse(request.responseText).items;
			for(i in 0...onlineSongItems.length)
			{
				var onlineSongItemName = onlineSongItems[i].song_name;

				var chartPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].chart_file;
				var instPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].inst;
				var voicesPath = 'http://sancopublic.ddns.net:5430/api/files/fnf_charts/' + onlineSongItems[i].id + "/" + onlineSongItems[i].voices;

				songsMap.set(onlineSongItemName, [chartPath, instPath, voicesPath, onlineSongItems[i].difficulty]);
                songs.push(onlineSongItemName);
            }
        });
        //when it finishes
        request.addEventListener('loadend', function()
        {
            //to avoid having errors, we generate the shit when it finishes loading
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
        });
        request.open("GET", 'http://sancopublic.ddns.net:5430/api/collections/fnf_charts/records');
        request.send();
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
    
                var request = js.Browser.createXMLHttpRequest();
    
                //gonna make it download the sounds automatically
                request.addEventListener("load", function()
                {
                    blockInputs = true; //WHY IT ISNT WORKINGGGGGGG

                    //to check if it needs voices
                    PlayState.SONG = Song.loadFromJson(request.responseText, "", true);
    
                    Sound.loadFromFile(songShit[1]).onComplete(function(sound)
                    {
                        PlayState.inst = sound;
                    });
    
                    if(PlayState.SONG.needsVoices)
                    {
                        Sound.loadFromFile(songShit[2]).onComplete(function(sound)
                        {
                            PlayState.voices = sound;
                            goToPlayState();
                        });
                    }
                    else
                        goToPlayState();
                });
    
                request.open("GET", songShit[0]);
                request.send();
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
}