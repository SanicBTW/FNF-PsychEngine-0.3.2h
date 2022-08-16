package;

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
    private static var checkDirs:Map<String, String> = new Map();
    private static var checkFileDirs:Map<String, String> = new Map();

    //lol im so dumb, i was using dirName and fileName instead of dirPath (?) and filePath :skull:
    public static function checkStorage()
    {
        //hm? dunno if i should do it like this
        checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

        checkDirs.set("weeks", Path.join([checkDirs.get("main"), 'weeks']));
        checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
        checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

        for (dirName => dirPath in checkDirs) 
        {
            if(!FileSystem.exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        for(filePath => fileContent in checkFileDirs)
        {
            if(!FileSystem.exists(filePath))
            {
                File.saveContent(filePath, fileContent);
            }
            else
            {

            }
        }

        FlxG.save.flush();

        openfl.system.System.gc();
    }
}