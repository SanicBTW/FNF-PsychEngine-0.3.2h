package osu;

import flixel.system.FlxSound;
import flixel.FlxG;
import Song.SwagSong;

using StringTools;

//this shit needs to get better maybe in another commit
class BeatMapParser
{
    static var fnfChart:Song.SwagSong = 
    {
        song: 'placeholder',
        notes: [],
        events: [],
        bpm: 200,
        needsVoices: false,
        speed: 3,

        player1: 'bf',
        player2: "bf",
        player3: "gf",
        gfVersion: "gf",
        stage: "stage",

        arrowSkin: "NOTE_assets",
        splashSkin: "noteSplashes",
        validScore: false
    };

    public static function parseBeatMap()
    {
        var testMapPath = AssetManager.getAsset('beatmap1.osu', DIRECTORY, null, "osu!beatmaps");
        var testMap = CoolUtil.coolTextFile(testMapPath);

        trace('Found ' + (testMap.length - findLine(testMap, '[HitObjects]') + 1) + " notes");

        fnfChart.song = getBeatMapOptions(testMap, 'Title');
        if (fnfChart.song == null)
            fnfChart.song = getBeatMapOptions(testMap, 'TitleUnicode');
        if (fnfChart.song == null)
            fnfChart.song = "convertedBeatmap";

        var curMode = Std.parseInt(getBeatMapOptions(testMap, 'Mode'));
        if (curMode != 3)
        {
            trace("Not supported");
            return;
        }

        var keyCount = Std.parseInt(getBeatMapOptions(testMap, 'CircleSize'));
        if (keyCount > 4)
        {
            trace("Engine only supports 4k atm");
            return;
        }

        trace('Now parsing');

        var i1 = findLine(testMap, '[HitObjects]') + 1;
        var toData:Dynamic = [];
        var what:Int = 0;

        while(i1 < testMap.length)
        {
            if (i1 == testMap.length - 1)
                break;

            i1++;

            toData[what] = 
            [
                Std.parseInt(osuLine(testMap[i1], 2, ',')),
                convertNote(osuLine(testMap[i1], 0, ',')),
                Std.parseFloat(osuLine(testMap[i1], 5, ',')) - Std.parseFloat(osuLine(testMap[i1], 2, ','))
            ];

            if (toData[what][2] < 0)
                toData[what][2] = 0;

            what++;
        }
        what = 0;

        if (#if html5 (findLine(testMap, '[TimingPoints]') + 1) != null #else Std.isOfType((findLine(testMap, '[TimingPoints]') + 1), null) #end)
        {
            trace("Calculating BPM");
            var bpm:Float = 0;
            var bpmCount:Float = 0;
            
            var i:Int = findLine(testMap, '[TimingPoints]');
            while (i < findLine(testMap, '[HitObjects]') - 2)
            {
                if(testMap[i].split(',')[6] == "1")
                {
                    bpm = bpm + Std.parseFloat(testMap[i].split(',')[1]);
                    bpmCount++;
                }

                fnfChart.bpm = Std.parseFloat(Std.string(bpm / bpmCount));

                i++;
            }
        }
        else
        {
            trace("Failed to calculate BPM");
        }

        trace(fnfChart.bpm);

        trace("Trying to place notes in chart");

        var i2 = 0;
        var sectionNote:Int = 0;
        var curSection:Int = 0;
        while (i2 < toData.length)
        {
            fnfChart.notes[curSection] = 
            {
                typeOfSection: 0,
                sectionBeats: 4,
                sectionNotes: [],
                mustHitSection: true,
                gfSection: false,
                altAnim: false,
                changeBPM: false,
                bpm: fnfChart.bpm
            };

            for (note in 0...toData.length)
            {
                if
                (
                    toData[note][0] <= ((curSection + 1) * (4 * (1000 * 60 / fnfChart.bpm))) &&
                    toData[note][0] > ((curSection) * (4 * (1000 * 60 / fnfChart.bpm)))
                )
                {
                    fnfChart.notes[curSection].sectionNotes[sectionNote] = toData[note];
                    sectionNote++;
                }
            }
            sectionNote = 0;

            if (toData[Std.int(toData.length - 1)] == 
                fnfChart.notes[curSection].sectionNotes[fnfChart.notes[curSection].sectionNotes.length - 1])
                break;

            curSection++;
            i2++;
        }

        var beatMapShit = 
        (getBeatMapOptions(testMap, 'Artist') != null ? getBeatMapOptions(testMap, 'Artist') : getBeatMapOptions(testMap, 'ArtistUnicode'))
        + " - " + 
        (getBeatMapOptions(testMap, 'Title') != null ? getBeatMapOptions(testMap, 'Title') : getBeatMapOptions(testMap, 'TitleUnicode'))
        + ' (' + getBeatMapOptions(testMap, 'Creator') + ") [" + getBeatMapOptions(testMap, 'Version') + "]";
        trace("Successfully converted " + beatMapShit + " from osu!Mania to FNF");

        trace("Setting PlayState");

        PlayState.SONG = fnfChart;
        PlayState.storyDifficulty = 2;
        CoolUtil.difficulties = CoolUtil.defaultDifficulties;
        PlayState.inst = AssetManager.getAsset("audio", SOUND, null, "osu!beatmaps");
        //PlayState.inst = Paths.getLibraryPath(getBeatMapOptions(testMap, 'AudioFilename'), "osu!beatmaps");

        trace("Going to loading state");

        LoadingState.loadAndSwitchState(new PlayState(), false);
    }

    static function findLine(array:Array<String>, toFind:String, fromLine:Int = 0, toLine:Dynamic = null):Int
    {
        if (toLine == null)
            toLine = array.length;

        var i = fromLine;

        while (i < toLine)
        {
            if (array[i].contains(toFind))
            {
                trace("Found " + toFind + " at " + i);
                return i;
                break;
            }

            i++;
        }

        trace("Couldn't find " + toFind);
        return -1;
    }

    static function getBeatMapOptions(beatMap:Array<String>, btOpt:String)
    {
        var i = 0;

        while (i < beatMap.length)
        {
            if (beatMap[i].toLowerCase().startsWith(btOpt.toLowerCase() + ":"))
            {
                trace("Found BeatMap Option (" + btOpt + ") at " + i + " returning as " + beatMap[i].substring(beatMap[i].lastIndexOf(":") + 1).trim());
                return beatMap[i].substring(beatMap[i].lastIndexOf(":") + 1).trim();
                break;
            }

            i++;
        }

        trace("Couldn't find " + btOpt + " on BeatMap");
        return null;
    }

    // copied from coolutil but actually done it right? (arguments)
    static function numberArray(?min = 0, max:Int):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

    //i thought on naming it a different way but uhhhhh
    static function osuLine(string:String, index:Int, split:String)
    {
        if(string != null)
        {
            var array:Array<String> = string.split(split);
            return array[index];
        }

        trace("Oops string is null cannot split shit my man");
        return "";
    }

    static function convertNote(from_note:Dynamic)
    {
        from_note = Std.parseInt(from_note);
        var noteArray =
        [
			numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511),
			numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511)
        ];

        for (i in 0...noteArray.length)
        {
            for (i2 in 0...noteArray[i].length)
            {
                if (noteArray[i][i2] == from_note)
                {
                    trace('Found note');
                    return i;
                }
            }
        }

        trace("Couldn't find note " + from_note + ' in note array');
        return 0;
    }
}