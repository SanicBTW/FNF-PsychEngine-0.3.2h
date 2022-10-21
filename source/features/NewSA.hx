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
class NEWStorageAccess
{
	public static var checkDirs:Map<String, String> = new Map();

	public static function checkStorage()
	{
		#if STORAGE_ACCESS
		checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

		// for songs shit
		checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
		checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

		//yooo what
		checkDirs.set("images", Path.join([checkDirs.get("main"), "images"]));
		checkDirs.set("img_characters", Path.join([checkDirs.get("images"), "characters"]));
		//json here ig
		checkDirs.set("characters", Path.join([checkDirs.get("main"), "characters"]));

		for (varName => dirPath in checkDirs)
		{
			trace("Checking: " + varName + " - " + dirPath);
			if (!exists(dirPath))
				FileSystem.createDirectory(dirPath);
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
	var IMAGES = "images";
	var CHARACTERS_GRAPHICS = "img_characters";
	var CHARACTERS_DATA = "characters";
}