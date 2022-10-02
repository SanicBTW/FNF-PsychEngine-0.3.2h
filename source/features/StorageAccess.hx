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
	private static var checkDirs:Map<String, String> = new Map();
	// set flags to a dir for ex if its gonna be used or not, if it should be created or not, etc
	private static var dirFlags:Map<String, Array<StorageFlags>> = new Map();
	// filename, filepath, filecontent
	private static var checkFiles:Map<String, Array<String>> = new Map();

	private static var shouldCreate:Bool = true;

	public static function checkStorage()
	{
		#if STORAGE_ACCESS
		checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

		// for songs shit
		checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
		checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));

		// never finished sorry, i will work on it one day
		checkDirs.set("hitsounds", Path.join([checkDirs.get("main"), "hitsounds"]));
		dirFlags.set("hitsounds", [DONT_CREATE, DONT_USE]);

		// finally implemented images???? no way
		checkDirs.set("images", Path.join([checkDirs.get("main"), "images"]));
		checkDirs.set("icons", Path.join([checkDirs.get("images"), "icons"]));

		for (varName => dirPath in checkDirs)
		{
			trace("Checking: " + varName + " - " + dirPath);
			for (dirFlag in dirFlags)
			{
				trace("Checking flags for: " + varName);
				if (dirFlags.get(varName) == null)
				{
					trace("Couldn't find flags for: " + varName);
					return;
				}

				trace("Found flags for: " + varName);
				for (flag in dirFlag)
				{
					switch (flag)
					{
						case DONT_CREATE:
							shouldCreate = false;
						case DONT_USE:
					}
				}
			}
			/*
				if (!exists(dirPath))
				{
					FileSystem.createDirectory(dirPath);
			}*/
		}

		openfl.system.System.gc();
		#end
	}

	public static function getInst(song:String, ext = ".ogg")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([checkDirs.get("songs"), song.toLowerCase(), 'Inst$ext']);
		if (exists(filePath))
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
		if (exists(filePath))
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

		if (exists(chartPath))
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

		if (exists(mainSongPath))
		{
			var possibleCharts = FileSystem.readDirectory(mainSongPath);
			return "exists";
		}
		return null;
		#end
	}

	// dawg?????? tf
	public static function exists(file:String)
	{
		#if STORAGE_ACCESS
		if (FileSystem.exists(file))
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

@:enum abstract StorageFlags(String) to String
{
	var DONT_CREATE;
	var DONT_USE;
}
