package osu;

using StringTools;

class Beatmap
{
    public var AUDIO_FILENAME:String = "";
    public var TITLE:String = "";
    public var ARTIST:String = "";
    public var CREATOR:String = "";
    public var DIFFICULTY:String = ""; // its just the "version"
    // xpos, ypos, path, xscale, yscale maybe?
    public var BACKGROUND:Array<Dynamic> = [0, 0, "", 0, 0]; // from events bg and vid events line or stmh
    public var BREAKS:Array<Int> = [0]; // from events break periods

    // had to
    public function new()
    {

    }

    public function getBeatmapOption(map:Array<String>, option:String)
    {
        for (i in 0...map.length)
        {
            if (map[i].toLowerCase().startsWith(option.toLowerCase() + ":"))
                return map[i].substring(map[i].lastIndexOf(":") + 1).trim();
        }

        return null;
        /* had to use the old method but find line works fine wtf
        option += ":";
        trace(option);
        var index = map[map.indexOf(option)];
        trace(index);
        trace(index.substring(index.lastIndexOf(":") + 1).trim());
        return (index != null ? index.substring(index.lastIndexOf(":") + 1).trim() : null);*/
    }

    public function findLine(map:Array<String>, find:String)
        return (map[map.indexOf(find)] != null ? map.indexOf(find) : -1 );

    public function line(string:String, index:Int, split:String)
    {
        if (string == null)
            return "";

        var array:Array<String> = string.split(split);
        return array[index];
    }

    // dumbest function here lol
    public function makeArray(string:String, split:String)
        return string.split(split);
}