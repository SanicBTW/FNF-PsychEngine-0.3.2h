package;

import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

//made to access internal storage for platforms that support sys
class StorageAccess
{
    public static var checkDirs:Map<String, String> = new Map();

    public static function checkStorage()
    {
        //hm? dunno if i should do it like this
        checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

        //checkDirs.set("weeks", Path.join([checkDirs.get("main"), 'weeks'])); dont know how i will get this to work tbh
        checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
        checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

        for (dirName => dirPath in checkDirs) 
        {
            if(!FileSystem.exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        openfl.system.System.gc();
    }

    public static function getInst(song:String, ext = ".ogg")
    {
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']);
        trace(filePath);
        if(FileSystem.exists(filePath))
        {
            trace("Inst exists");
            return Sound.fromFile(filePath);
        }
        else { trace("Couldnt find inst"); }
        return null;
    }

    public static function getVoices(song:String, ext = ".ogg")
    {
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']);
        trace(filePath);
        if(FileSystem.exists(filePath))
        {
            trace("Voices exists");
            return Sound.fromFile(filePath);
        }
        else { trace("Couldnt find voices"); }
        return null;
    }

    public static function getChart(song:String, diff:String = "")
    {
        var chartFile:String = song.toLowerCase() + diff + ".json";
        var mainSongPath:String = Path.join([checkDirs.get("data"), song.toLowerCase()]);

        if(FileSystem.exists(mainSongPath))
        {
            var possibleCharts = FileSystem.readDirectory(mainSongPath);
            trace("Possible charts: " + possibleCharts);
    
            for(i in 0...possibleCharts.length)
            {
                trace(possibleCharts[i]);
                if(possibleCharts[i] == chartFile)
                {
                    trace("Required chart found, returning");
                    return Path.join([mainSongPath, chartFile]);
                }
                else
                {
                    trace("Found a chart but not the required one");
                }
            }
        }
        else { trace("Song doesnt exists on the data folder"); }
        return null;
    }
}