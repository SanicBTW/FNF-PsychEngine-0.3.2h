package features;

import flixel.FlxG;
import haxe.Json;
import haxe.io.Path;
import lime.system.System;
import openfl.media.Sound;
import openfl.utils.Assets;
#if STORAGE_ACCESS
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

// made to access internal storage for target platform sys
class StorageAccess
{
	public static var checkDirs:Map<String, String> = new Map();
	// filename, filepath, filecontent
	public static var checkFiles:Map<String, Array<String>> = new Map();

	static var settingsTemplate:FunkySettings =
	{
		downScroll: false,
		middleScroll: false,
		showFPS: true,
		flashing: true,
		globalAntialiasing: true,
		noteSplashes: true,
		lowQuality: false,
		framerate: 60,
		camZooms: true,
		hideHud: false,
		noteOffset: 0,
		arrowHSV: [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
		ghostTapping: true,
		hideTime: false,

		showMemory: true,
		optScoreZoom: true,
		cameraMovement: true,
		iconBoping: false,
		pauseMusic: "Tea Time",
		missVolume: 0.2,
		hitsoundVolume: 0,
		scoreTextDesign: "Engine",
		comboOffset: [0, 0, 0, 0],
		inputType: "Kade 1.5.3",
		smoothCamZoom: true,
		opponentNoteSplash: true,
		ratingOffset: 0,
		sickWindow: 45,
		goodWindow: 90,
		badWindow: 135,
		safeFrames: 10,
		allowFileSys: false,
		answeredReq: false,
		ghostTappingBFSing: true,
		comboStacking: true,
		cameraMovementDisplacement: 15,
		pauseOnFocusLost: true,
		snapCameraOnGameover: true,
		counterFont: "Funkin",
		osuManiaSimulation: true,
		ratingsStyle: "Classic",
		allowOnlineFetching: false
	}

	public static function checkStorage()
	{
		#if STORAGE_ACCESS
		checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

		// for songs shit
		checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
		checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

		for (varName => dirPath in checkDirs)
		{
			trace("Checking: " + varName + " - " + dirPath);
			if (!exists(dirPath))
				FileSystem.createDirectory(dirPath);
		}

		checkFiles.set("settings.json", [checkDirs.get("main"), Json.stringify(settingsTemplate, null, "\t")]);

		for (fileName => fileArgs in checkFiles)
		{
			var fullPath = Path.join([fileArgs[0], fileName]);
			trace("Checking file: " + fileName + " at " + fileArgs[0]);
			if(!exists(fullPath))
				File.saveContent(fullPath, fileArgs[1]);
		}

		openfl.system.System.gc();
		#end
	}

	//dumb shit
	public static function getFolderPath(folder:StorageFolders = MAIN)
	{
		#if STORAGE_ACCESS
		return checkDirs.get(folder);
		#end
	}

	public static function getFolderFiles(folder:StorageFolders = MAIN)
	{
		#if STORAGE_ACCESS
		return FileSystem.readDirectory(checkDirs.get(folder));
		#end
	}

	public static function getInst(song:String, ext = ".ogg")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([getFolderPath(SONGS), song.toLowerCase(), 'Inst$ext']);
		if (exists(filePath))
			return Sound.fromFile(filePath);
		return null;
		#end
	}

	public static function getVoices(song:String, ext = ".ogg")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([getFolderPath(SONGS), song.toLowerCase(), 'Voices$ext']);
		if (exists(filePath))
			return Sound.fromFile(filePath);
		return null;
		#end
	}

	// dawg?????? tf
	public static function exists(file:String)
	{
		#if STORAGE_ACCESS
		if (FileSystem.exists(file))
			return true;
		else
			return false;
		#end
	}
}

enum abstract StorageFolders(String) to String
{
	var MAIN = "main";
	var DATA = "data";
	var SONGS = "songs";
}

typedef FunkySettings = 
{
	//Classic Psych Settings
	var downScroll:Bool;
	var middleScroll:Bool;
	var showFPS:Bool;
	var flashing:Bool;
	var globalAntialiasing:Bool;
	var noteSplashes:Bool;
	var lowQuality:Bool;
	var framerate:Int;
	var camZooms:Bool;
	var hideHud:Bool;
	var noteOffset:Int;
	var arrowHSV:Array<Array<Int>>;
	var ghostTapping:Bool;
	var hideTime:Bool;

	//Engine Settings
	var showMemory:Bool;
	var optScoreZoom:Bool;
	var cameraMovement:Bool;
	var iconBoping:Bool;
	var pauseMusic:String;
	var missVolume:Float;
	var hitsoundVolume:Float;
	var scoreTextDesign:String;
	var comboOffset:Array<Int>;
	var inputType:String;
	var smoothCamZoom:Bool;
	var opponentNoteSplash:Bool;
	var ratingOffset:Int;
	var sickWindow:Int;
	var goodWindow:Int;
	var badWindow:Int;
	var safeFrames:Float;
	var allowFileSys:Bool;
	var answeredReq:Bool;
	var ghostTappingBFSing:Bool;
	var comboStacking:Bool;
	var cameraMovementDisplacement:Float;
	var pauseOnFocusLost:Bool;
	var snapCameraOnGameover:Bool;
	var counterFont:String;
	var osuManiaSimulation:Bool;
	var ratingsStyle:String;
	var allowOnlineFetching:Bool;
}