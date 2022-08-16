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
    //tbh this method to check files isnt that effective like dirs
    //private static var checkFileDirs:Map<String, String> = new Map();

    private static var templateSettings:SettingsJSON =
    {
        downScroll: false,
        middleScroll: false,
        showFPS: true,
        flashing: true,
        globalAntialiasing: true,
        lowQuality: false,
        framerate: 60,
        camZooms: true,
        noteOffset: 0,
        hideHud: false,
        arrowHSV: [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
        ghostTapping: true,
        hideTime: false,
    
        showMemory: true,
        optDisableScoreTween: false,
        optHideHealthBar: false,
        cameraMovOnNoteP: true
    }

    public static function checkStorage()
    {
        //hm? dunno if i should do it like this
        checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

        checkDirs.set("weeks", Path.join([checkDirs.get("main"), 'weeks']));
        checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
        checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

        var peSettingsJSON:String = Path.join([checkDirs.get("data"), "peSettings.json"]);

        for (dirName => dirPath in checkDirs) 
        {
            if(!FileSystem.exists(dirPath)){ FileSystem.createDirectory(dirPath); }
        }

        if(!FileSystem.exists(peSettingsJSON)){ File.saveContent(peSettingsJSON, Json.stringify(templateSettings, null, "    ")); loadSettings(File.getContent(peSettingsJSON)); }
        else{ loadSettings(File.getContent(peSettingsJSON)); }

        openfl.system.System.gc();
    }

    private static function loadSettings(rjson)
    {
        var jaja:SettingsJSON = cast Json.parse(rjson);

        FlxG.save.data.downScroll = jaja.downScroll;
		FlxG.save.data.middleScroll = jaja.middleScroll;
		FlxG.save.data.showFPS = jaja.showFPS;
		FlxG.save.data.flashing = jaja.flashing;
		FlxG.save.data.globalAntialiasing = jaja.globalAntialiasing;
		FlxG.save.data.lowQuality = jaja.lowQuality;
		FlxG.save.data.framerate = jaja.framerate;
		FlxG.save.data.camZooms = jaja.camZooms;
		FlxG.save.data.noteOffset = jaja.noteOffset;
		FlxG.save.data.hideHud = jaja.hideHud;
		FlxG.save.data.arrowHSV = jaja.arrowHSV;
		FlxG.save.data.ghostTapping = jaja.ghostTapping;
		FlxG.save.data.hideTime = jaja.hideTime;
		
		FlxG.save.data.showMemory = jaja.showMemory;
		FlxG.save.data.optDisableScoreTween = jaja.optDisableScoreTween;
		FlxG.save.data.optHideHealthBar = jaja.optHideHealthBar;
		FlxG.save.data.cameraMovOnNoteP = jaja.cameraMovOnNoteP;

		FlxG.save.flush();
    }
}

typedef SettingsJSON = 
{
    var downScroll:Bool;
    var middleScroll:Bool;
    var showFPS:Bool;
    var flashing:Bool;
    var globalAntialiasing:Bool;
    var lowQuality:Bool;
    var framerate:Int;
    var camZooms:Bool;
    var noteOffset:Int;
    var hideHud:Bool;
    var arrowHSV:Array<Array<Int>>;
    var ghostTapping:Bool;
    var hideTime:Bool;

    var showMemory:Bool;
    var optDisableScoreTween:Bool;
    var optHideHealthBar:Bool;
    var cameraMovOnNoteP:Bool;
}