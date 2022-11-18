package osu;

using StringTools;

// comments might get removed in following commits
class BeatmapConverter
{
    private static var beatmap:Beatmap = new Beatmap();
    private static var fnfChart:Song.SwagSong = 
    {
        song: 'unknown',
        notes: [],
        events: [],
        bpm: 200,
        needsVoices: false,
        speed: 3,
        player1: "bf",
        player2: "bf",
        player3: null,
        gfVersion: "gf",
        stage: "stage",
        arrowSkin: "NOTE_assets",
        splashSkin: "noteSplashes",
        validScore: false
    };

    public static function convertBeatmap()
    {
        var testMapPath = Paths.getLibraryPath('beatmap1.osu', "osu!beatmaps");
		var map = CoolUtil.coolTextFile(testMapPath);

        beatmap.AUDIO_FILENAME = beatmap.getBeatmapOption(map, 'AudioFilename');
        setTitle(map);
        setArtist(map);
        beatmap.CREATOR = beatmap.getBeatmapOption(map, 'Creator');
        beatmap.DIFFICULTY = beatmap.getBeatmapOption(map, 'Version');

        var bgLine:Int = beatmap.findLine(map, '[Events]') + 1; // +1 is to skip [Events] line
        if (map[bgLine].startsWith("//"))
            bgLine++;

        // i dont actually know how the numbers here work but im just going to assume the first ones are coordinates and the other numbers are just scales
        beatmap.BACKGROUND = beatmap.makeArray(map[bgLine], ",");

        var breaksLine:Int = bgLine + 1; // + 1 bc we want to skip the bg stuff
        if (map[breaksLine].startsWith("//")) // again bruh
            breaksLine++;

        // dumb af sorry, will look into a different way 
        var breaksStr = beatmap.makeArray(map[breaksLine], ",");
        var breaksPars:Array<Int> = [];
        for (i in 0...breaksStr.length)
            breaksPars.push(Std.parseInt(breaksStr[i]));

        beatmap.BREAKS = breaksPars; // maybe its a float, but hopefully these numbers are in strum time or stmh

        // this would literally break the whole script for some reason lol
        if (Std.parseInt(beatmap.getBeatmapOption(map, "Mode")) != 3)
            return;

        if (Std.parseInt(beatmap.getBeatmapOption(map, "CircleSize")) != 4)
            return;

        // i dont understand how notes are converted lol
        MainWorker.execute("Parse", [beatmap.findLine(map, '[HitObjects]') + 1, map.length - 1, map]);
    }

    // lol
    private static function setTitle(map:Array<String>)
    {
        beatmap.TITLE = beatmap.getBeatmapOption(map, "Title");
        if (beatmap.TITLE == null)
            beatmap.TITLE = beatmap.getBeatmapOption(map, "TitleUnicode");
        if (beatmap.TITLE == null)
            beatmap.TITLE = "ConvertedBeatmap";
    }

    private static function setArtist(map:Array<String>)
    {
        beatmap.ARTIST = beatmap.getBeatmapOption(map, 'Artist');
        if (beatmap.ARTIST == null)
            beatmap.ARTIST = beatmap.getBeatmapOption(map, 'ArtistUnicode');
        if (beatmap.ARTIST == null)
            beatmap.ARTIST = "BeatmapConverter";
    }
}