package features;

import StageData.StageFile;
import flixel.graphics.frames.FlxAtlasFrames;
import Character.CharacterFile;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
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
	public static var currentTrackedAssets:Map<String, FlxGraphic> = new Map();

	public static function checkStorage()
	{
		#if STORAGE_ACCESS
		checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

		// for songs shit
		checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
		checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));
		checkDirs.set("images", Path.join([checkDirs.get("main"), "images"]));
		checkDirs.set("characters", Path.join([checkDirs.get("main"), "characters"]));
		checkDirs.set("charactersGraphic", Path.join([checkDirs.get("images"), "characters"]));
		checkDirs.set("icons", Path.join([checkDirs.get("images"), "icons"]));
		checkDirs.set("stages", Path.join([checkDirs.get("main"), "stages"]));

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

	public static function getInst(song:String, returnPath:Bool = false):Dynamic
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([getFolderPath(SONGS), song.toLowerCase(), 'Inst.ogg']);
		if (exists(filePath) && returnPath == false)
			return Sound.fromFile(filePath);
		else if (exists(filePath) && returnPath == true)
			return filePath;
		return null;
		#end
	}

	public static function getVoices(song:String, returnPath:Bool = false):Dynamic
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([getFolderPath(SONGS), song.toLowerCase(), 'Voices.ogg']);
		if (exists(filePath) && returnPath == false)
			return Sound.fromFile(filePath);
		else if (exists(filePath) && returnPath == true)
			return filePath;
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

	public static function getCharacter(char:String):Array<Dynamic>
	{
		#if STORAGE_ACCESS
		// paths
		var charJSONP:String = Path.join([getFolderPath(CHARACTERS), char + ".json"]);
		// we settin these paths if json exists
		var charGRAPHP:String = "";
		var charXMLP:String = "";
		var charPACKERP:String = "";

		// shit checks
		var jsonExists:Bool = false;

		// checkin fr
		if (exists(charJSONP))
			jsonExists = true;

		// we do shit now
		if (jsonExists)
		{
			var rawJSON = File.getContent(charJSONP);
			var json:CharacterFile = cast Json.parse(rawJSON);

			charGRAPHP = Path.join([getFolderPath(CHARACTERS_GRAPHICS), json.image.replace('characters/', "") + ".png"]);
			charXMLP = Path.join([getFolderPath(CHARACTERS_GRAPHICS), json.image.replace('characters/', "") + ".xml"]);
			charPACKERP = Path.join([getFolderPath(CHARACTERS_GRAPHICS), json.image.replace('characters/', "") + ".txt"]);

			if (exists(charGRAPHP))
			{
				var graphic = getGraphic(charGRAPHP);

				if (exists(charXMLP))
				{
					var xmlContent = File.getContent(charXMLP);
					var frames = FlxAtlasFrames.fromSparrow(graphic, xmlContent);
					return [json, frames];
				}

				if (!exists(charXMLP) && exists(charPACKERP))
				{
					var txtContent = File.getContent(charPACKERP);
					var frames = FlxAtlasFrames.fromSpriteSheetPacker(graphic, txtContent);
					return [json, frames];
				}

				if (!exists(charXMLP) && !exists(charPACKERP))
					return null;
			}
			else
				return null;
		}
		return null;
		#end
	}

	public static function getGraphic(file:String)
	{
		#if STORAGE_ACCESS
		if (!currentTrackedAssets.exists(file))
		{
			var newBitmap:BitmapData = BitmapData.fromFile(file);
			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
			currentTrackedAssets.set(file, newGraphic);
		}
		return currentTrackedAssets.get(file);
		#end
	}

	public static function getStage(stage:String):Null<StageFile>
	{
		#if STORAGE_ACCESS
		var stageJSON:String = Path.join([getFolderPath(STAGES), stage + ".json"]);

		if (exists(stageJSON))
			return cast Json.parse(File.getContent(stageJSON));
		else
			return null;

		return null;
		#end
	}

	public static function getIcon(character:String)
	{
		#if STORAGE_ACCESS
		var iconName:String = character;
		var iconPath:String = Path.join([getFolderPath(ICONS), iconName + ".png"]);

		if (exists(iconPath))
			return getGraphic(iconPath);
		else
		{
			var second = "icon-" + iconName;
			iconPath = Path.join([getFolderPath(ICONS), second + ".png"]);
			if (exists(iconPath))
				return getGraphic(iconPath)
			else
				return null;
		}

		return null;
		#end
	}
}

enum abstract StorageFolders(String) to String
{
	var MAIN = "main";
	var DATA = "data";
	var SONGS = "songs";
	var IMAGES = "images";
	var CHARACTERS = "characters";
	var STAGES = "stages";
	var CHARACTERS_GRAPHICS = "charactersGraphic";
	var ICONS = "icons";
}