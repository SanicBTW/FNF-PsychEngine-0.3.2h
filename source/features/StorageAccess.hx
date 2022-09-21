package features;

import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
#if STORAGE_ACCESS
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
        #if STORAGE_ACCESS
        checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

        checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
        checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));
        checkDirs.set("hitsounds", Path.join([checkDirs.get("main"), "hitsounds"]));

        for (varName => dirPath in checkDirs) 
        {
            trace("Checking: " + varName + " - " + dirPath);
            if(!exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        openfl.system.System.gc();
        #end
    }

    public static function getInst(song:String, ext = ".ogg")
    {
        #if STORAGE_ACCESS
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']);
        if(exists(filePath))
        {
            return Sound.fromFile(filePath);
        }
        return null;
        #end
    }

    public static function getVoices(song:String, ext = ".ogg")
    {
        #if STORAGE_ACCESS
        var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']);
        if(exists(filePath))
        {
            return Sound.fromFile(filePath);
        }
        return null;
        #end
    }

    public static function getChart(song:String, diff:Int = 1):String
    {
        #if STORAGE_ACCESS
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

        if(exists(chartPath))
        {
            return chartPath;
        }
        return null;
        #else
        return null;
        #end
    }

    public static function getSongs()
    {
        #if STORAGE_ACCESS
        return FileSystem.readDirectory(checkDirs.get('songs'));
        #end
    }

    public static function getCharts(song:String)
    {
        #if STORAGE_ACCESS
        var mainSongPath:String = Path.join([checkDirs.get("data"), song.toLowerCase()]);

        if(exists(mainSongPath))
        {
            var possibleCharts = FileSystem.readDirectory(mainSongPath);
            return "exists";
        }
        return null;
        #end
    }

    //dawg?????? tf
    public static function exists(file:String)
    {
        #if STORAGE_ACCESS
        if(FileSystem.exists(file))
        {
            return true;
        }
        else
        {
            return false;
        }
        #end
    }
}