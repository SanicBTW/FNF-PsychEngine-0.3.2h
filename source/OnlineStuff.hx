import flixel.util.FlxColor;
import haxe.Json;

class OnlineStuff
{
    //stuff should end with a /
    public static var serverURL:String;
    public static var recordsURL:String = serverURL + "api/collections/fnf_charts/records/";
    public static var filesURL:String = serverURL + "api/files/fnf_charts/";

    public static function setupURL()
    {
        #if !html5
        var server = new haxe.Http('https://raw.githubusercontent.com/SanicBTW/stuff/master/serverURL');
		server.onData = function(data:String)
		{
			serverURL = data;
		}
		server.request();
        #end
    }

    public static function setSongs()
    {
        #if !html5
        var http = new haxe.Http(OnlineStuff.recordsURL);
        http.onData = function(data:String)
        {
            var songItems:Dynamic = cast Json.parse(data).items;
            for(i in 0...songItems)
            {
                var name = songItems[i].chart_name;
                var chart = OnlineStuff.filesURL + songItems[i].id + "/" + songItems[i].chart_file;
                var inst = OnlineStuff.filesURL + songItems[i].id + "/" + songItems[i].chart_inst;
                var voices = OnlineStuff.filesURL + songItems[i].id + "/" + songItems[i].chart_voice;

                FreeplayState.addSong(name, i, "face", FlxColor.fromRGB(0, 0, 0), true);
                FreeplayState.onlineSongs.set(name, [chart, inst, voices, songItems[i].chart_difficulty]);
            }
        }
        http.request();
        #end
    }
}