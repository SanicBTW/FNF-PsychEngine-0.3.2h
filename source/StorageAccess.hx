package;

import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
#if FEATURE_STORAGE_ACCESS
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import lime.system.System;
import haxe.io.Path;

//made to access internal storage for target platform sys
class StorageAccess
{
    public static var checkDirs:Map<String, String> = new Map();
    //filename, filepath, filecontent
    public static var checkFiles:Map<String, Array<String>> = new Map();

    public static function checkStorage()
    {
        #if FEATURE_STORAGE_ACCESS
        checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

        checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
        checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

        for (varName => dirPath in checkDirs) 
        {
            if(!FileSystem.exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        openfl.system.System.gc();
        #end
    }

    public static function getInst(song:String, ext = ".ogg")
    {
        #if FEATURE_STORAGE_ACCESS
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']);
        if(FileSystem.exists(filePath))
        {
            return Sound.fromFile(filePath);
        }
        else { trace("Couldnt find inst"); }
        return null;
        #end
    }

    public static function getVoices(song:String, ext = ".ogg")
    {
        #if FEATURE_STORAGE_ACCESS
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']);
        if(FileSystem.exists(filePath))
        {
            return Sound.fromFile(filePath);
        }
        else { trace("Couldnt find voices"); }
        return null;
        #end
    }

    public static function getChart(song:String, diff:Int = 1):Array<Dynamic>
    {
        #if FEATURE_STORAGE_ACCESS
        var dadiff:Int = 0;
        var diffString:String = "";
        switch (diff)
        {
            case 0:
                diffString = "-easy";
            case 1:
                diffString = "";
            case 2:
                diffString = "-hard";
        }
        var chartFile:String = song.toLowerCase() + diffString + ".json";
        var mainSongPath:String = Path.join([checkDirs.get("data"), song.toLowerCase()]);

        var chartPath:String = Path.join([mainSongPath, chartFile]);

        //kinda buggy, fix it
        if(FileSystem.exists(chartPath))
        {
            return [chartPath, diff];
        }
        else
        {
            var priority = ClientPrefs.chartScanPriority;
            var notfound = true;
            while(notfound)
            {
                if(diff == 0)
                {
                    chartFile = song.toLowerCase() + "-easy.json";
                    chartPath = Path.join([mainSongPath, chartFile]);
                    if(FileSystem.exists(chartPath) && priority == "easy" && priority != "normal" && priority != "hard")
                    {
                        notfound = false;
                        return [chartPath, diff];
                        break;
                    }
                    else if(FileSystem.exists(chartPath) && priority != "easy" && priority == "normal" && priority != "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 1;
                    }
                    else if(FileSystem.exists(chartPath) && priority != "easy" && priority != "normal" && priority == "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 2;
                    }
                    else
                    {
                        diff = 1;
                    }
                }
                if(diff == 1)
                {
                    chartFile = song.toLowerCase() + ".json";
                    chartPath = Path.join([mainSongPath, chartFile]);
                    if(FileSystem.exists(chartPath) && priority != "easy" && priority == "normal" && priority != "hard")
                    {
                        notfound = false;
                        return [chartPath, diff];
                        break;
                    }
                    else if(FileSystem.exists(chartPath) && priority == "easy" && priority != "normal" && priority != "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 0;
                    }
                    else if(FileSystem.exists(chartPath) && priority != "easy" && priority != "normal" && priority == "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 2;
                    }
                    else
                    {
                        diff = 2;
                    }
                }
                if(diff == 2)
                {
                    chartFile = song.toLowerCase() + "-hard.json";
                    chartPath = Path.join([mainSongPath, chartFile]);
                    if(FileSystem.exists(chartPath) && priority != "easy" && priority != "normal" && priority == "hard")
                    {
                        notfound = false;
                        return [chartPath, diff];
                        break;
                    }
                    else if(FileSystem.exists(chartPath) && priority == "easy" && priority != "normal" && priority != "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 0;
                    }
                    else if(FileSystem.exists(chartPath) && priority != "easy" && priority == "normal" && priority != "hard")
                    {
                        trace("Found the chart but isnt the priority chart");
                        diff = 1;
                    }
                    else
                    {
                        diff = 0;
                    }
                }
            }
        }
        return null;
        #else
        return null;
        #end
    }

    public static function getSongs()
    {
        #if FEATURE_STORAGE_ACCESS
        return FileSystem.readDirectory(checkDirs.get('songs'));
        #end
    }

    public static function getCharts(song:String)
    {
        #if FEATURE_STORAGE_ACCESS
        var mainSongPath:String = Path.join([checkDirs.get("data"), song.toLowerCase()]);

        if(FileSystem.exists(mainSongPath))
        {
            var possibleCharts = FileSystem.readDirectory(mainSongPath);
            return "exists";
        }
        else { trace("Song doesnt exists on the data folder"); }
        return null;
        #end
    }
}