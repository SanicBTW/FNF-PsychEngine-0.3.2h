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

// made to access internal storage for target platform sys
class StorageAccess
{
	public static var checkDirs:Map<String, String> = new Map();

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

		openfl.system.System.gc();
		#end
	}

	public static function getInst(song:String, ext = ".ogg")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']);
		if (exists(filePath))
			return Sound.fromFile(filePath);
		return null;
		#end
	}

	public static function getVoices(song:String, ext = ".ogg")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Voices$ext']);
		if (exists(filePath))
			return Sound.fromFile(filePath);
		return null;
		#end
	}

	public static function getSongs()
	{
		#if STORAGE_ACCESS
		return FileSystem.readDirectory(checkDirs.get('songs'));
		#end
	}

	public static function getCharts()
	{
		#if STORAGE_ACCESS
		return FileSystem.readDirectory(checkDirs.get("data"));
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
