package virtualFS;

// yes its a really dumb parser lol
// shit to parse should come properly formatted
class DumbParser
{
    // possible matches for true bool
    private static var positives:Array<String> = ["true", "on", "active", "enabled"];
    // possible matches for false bool
    private static var negatives:Array<String> = ["false", "off", "inactive", "disabled"];

    public static function parseBool(s:String):Bool
    {
        for (i in 0...positives.length)
        {
            if (s == positives[i])
            {
                return true;
                break;
            }
        }

        for (i in 0...negatives.length)
        {
            if (s == negatives[i])
            {
                return false;
                break;
            }
        }

        return false;
    }

    public static function parseInt(s:String)
    {
        return Std.parseInt(s);
    }

    public static function parseFloat(s:String)
    {
        return Std.parseFloat(s);
    }
}