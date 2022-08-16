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
        checkDirs.set("settings", Path.join([checkDirs.get("data"), "settings"]));

        checkFileDirs.set(Path.join([checkDirs.get("settings"), "showFPS"]), "true");
        checkFileDirs.set(Path.join([checkDirs.get("settings"), "showMemory"]), "true");

        var notsent = true;

        for (dirName => dirPath in checkDirs) 
        {
            if(!FileSystem.exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        for(filePath => fileContent in checkFileDirs)
        {
            if(!FileSystem.exists(filePath))
            {
                File.saveContent(filePath, fileContent);
                setupSettings(filePath);
            }
            else
            {
                if(notsent){
                    setupSettings(filePath);
                }
                notsent = false;
            }
        }

        FlxG.save.flush();

        openfl.system.System.gc();
    }

    //4th time creating the function :grin:
    private static function setupSettings(path:String)
    {
        //LETS FUCKING GOOO I DONT HAVE TO HARD CODE EACH FUNCTION YESSSSSSSSSSSSSSS
        var waytw = [Path.join([checkDirs.get("settings"), "showFPS"]), Path.join([checkDirs.get("settings"), "showMemory"])];
        var settvartw = ["showFPS", "showMemory"];

        for(i in 0...waytw.length)
        {
            if(path == waytw[i])
            {
                switch(File.getContent(path).toString())
                {
                    case "true":
                        Reflect.setProperty(FlxG.save.data, settvartw[i], true);
                    case "false":
                        Reflect.setProperty(FlxG.save.data, settvartw[i], false);
                }
            }
            FlxG.save.flush();
            trace(Reflect.getProperty(FlxG.save.data, settvartw[i]));
        }
        /*
        var settings:Map<String, String> = new Map();
        settings.set(Path.join([checkDirs.get("settings"), "showFPS"]), "showFPS");
        settings.set(Path.join([checkDirs.get("settings"), "showMemory"]), "showMemory");


        for(filePath => settVar in settings)
        {
            trace(filePath, settVar);
            if(path == filePath)
            {
                switch(File.getContent(path).toString())
                {
                    case "true":
                        Reflect.setProperty(FlxG.save.data, settVar, true);
                    case "false":
                        Reflect.setProperty(FlxG.save.data, settVar, false);
                }
            }
        }*/
    }
}