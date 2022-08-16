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
        trace(Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']));
        return Sound.fromFile(Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']));
    }

    public static function getVoices(song:String, ext = ".ogg")
    {
        trace(Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']));
        return Sound.fromFile(Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']));
    }
}