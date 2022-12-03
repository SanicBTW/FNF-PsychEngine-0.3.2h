package features;

import Character.CharacterFile;
import StageData.StageFile;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import haxe.io.Path;
import lime.system.System;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets;

using StringTools;

#if STORAGE_ACCESS
import sys.FileSystem;
import sys.io.File;
#end

// made to access internal storage for target platform sys
class StorageAccess
{
	public static var checkDirs:Map<String, String> = new Map();
	public static var currentTrackedAssets:Map<String, FlxGraphic> = new Map();
	//public static var currentTrackedSounds:Map<String, Sound> = new Map();

	public static function checkStorage()
	{
		#if STORAGE_ACCESS
		checkDirs.set("main", Path.join([System.userDirectory, 'sanicbtw_pe_files']));

		setFolder("data");
		setFolder("songs");
		setFolder("images");
		setFolder("characters");
		setFolder("charactersGraphic", IMAGES, "characters");
		setFolder("icons", IMAGES);
		setFolder("stages");
		setFolder("weeks");
		//setFolder("music");
		//setFolder("sounds");

		for (varName => dirPath in checkDirs)
		{
			trace("Checking: " + varName + " - " + dirPath);
			if (!exists(dirPath))
				FileSystem.createDirectory(dirPath);
		}

		openfl.system.System.gc();
		#end
	}

	private static function setFolder(folderName:String, baseDir:StorageFolders = MAIN, ?folderName2:Null<String> = null)
		checkDirs.set(folderName, Path.join([checkDirs.get(baseDir), (folderName2 != null ? folderName2 : folderName)]));

	// dumb shit
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

	/*
	public static function getSound(folder:SoundFolders, file:String)
	{
		#if STORAGE_ACCESS
		var filePath:String = Path.join([checkDirs.get(folder), file]);
		trace(filePath);
		if (!currentTrackedSounds.exists(filePath))
		{
			var files = FileSystem.readDirectory(checkDirs.get(folder));
			trace(files);
			for (i in 0...files.length)
			{
				trace(files[i]);
				if (files[i].contains(file))
				{
					currentTrackedSounds.set(filePath, Sound.fromFile(Path.join([filePath, file + files[i].replace(file, "")])));
					break;
				}
			}
		}
		return currentTrackedSounds.get(filePath);
		#else
		return null;
		#end
	}*/

	public static function getSong(song:String, file:String = "Inst")
	{
		#if STORAGE_ACCESS
		var filePath = Path.join([getFolderPath(SONGS), Paths.formatToSongPath(song), '$file.ogg']);
		return Sound.fromFile(filePath);
		#else
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

		// we do shit now
		if (exists(charJSONP))
		{
			var rawJSON = File.getContent(charJSONP);
			var json:CharacterFile = cast Json.parse(rawJSON);

			charGRAPHP = Path.join([
				getFolderPath(CHARACTERS_GRAPHICS),
				json.image.replace('characters/', "") + ".png"
			]);
			charXMLP = Path.join([
				getFolderPath(CHARACTERS_GRAPHICS),
				json.image.replace('characters/', "") + ".xml"
			]);
			charPACKERP = Path.join([
				getFolderPath(CHARACTERS_GRAPHICS),
				json.image.replace('characters/', "") + ".txt"
			]);

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
		#else
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
		#else
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
		#else
		return null;
		#end
	}

	public static function getArrowTexture(texture:String, isPixel:Bool = false, isSustain:Bool = false):Dynamic
	{
		#if STORAGE_ACCESS
		var arrowPath = makePath(IMAGES, '$texture.png');
		var xmlArrowPath = makePath(IMAGES, '$texture.xml');

		if (exists(arrowPath))
		{
			if (exists(xmlArrowPath) && isPixel == false)
			{
				var graphic = getGraphic(arrowPath);
				var frames = FlxAtlasFrames.fromSparrow(graphic, File.getContent(xmlArrowPath));
				return frames;
			}
			else if ((!exists(xmlArrowPath) || exists(xmlArrowPath)) && isPixel == true)
			{
				if (isSustain)
				{
					var arrowPixNote = makePath(IMAGES, '${texture}ENDS-pixel.png');
					if (exists(arrowPixNote))
						return getGraphic(arrowPixNote);
					else
						return null;
				}
				else
				{
					var arrowPixNote = makePath(IMAGES, '$texture-pixel.png');
					if (exists(arrowPixNote))
						return getGraphic(arrowPixNote);
					else
						return null;
				}
			}
			else
				return null;
		}
		else
			return null;

		return null;
		#else
		return null;
		#end
	}

	public static function getWeekFiles():Null<Array<WeekData.WeekFile>>
	{
		#if STORAGE_ACCESS
		var weeks:Array<WeekData.WeekFile> = [];
		var files = getFolderFiles(WEEKS);
		for (file in files)
		{
			if (file.endsWith(".json"))
				weeks.push(cast Json.parse(File.getContent(makePath(WEEKS, file))));
		}
		return (weeks.length > 0 ? weeks : null);
		#else
		return null;
		#end
	}

	public static function getWeekNames():Null<Array<String>>
	{
		#if STORAGE_ACCESS
		var names:Array<String> = [];
		var files = getFolderFiles(WEEKS);
		// to avoid getting some other stupid file
		for (file in files)
		{
			if (file.endsWith(".json"))
				names.push(file.replace(".json", ""));
		}
		return (names.length > 0 ? names : null);
		#else
		return null;
		#end
	}

	// shitass function
	public static function makePath(folder:StorageFolders = MAIN, path:String):String
	{
		#if STORAGE_ACCESS
		return Path.join([checkDirs.get(folder), path]);
		#else
		return null;
		#end
	}

	public static function getNoteSplashes(texture:String)
	{
		#if STORAGE_ACCESS
		var graphicPath = makePath(IMAGES, '$texture.png');
		var xmlPath = makePath(IMAGES, '$texture.xml');

		if (!exists(graphicPath))
			return null;
		else
		{
			if (!exists(xmlPath))
				return null;
			else
			{
				var graphic = getGraphic(graphicPath);
				var frames = FlxAtlasFrames.fromSparrow(graphic, File.getContent(xmlPath));
				return frames;
			}
		}
		return null;
		#else
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
	var WEEKS = "weeks";
	var MUSIC = "music";
	var SOUNDS = "sounds";
}

enum abstract SoundFolders(String) to String
{
	var MUSIC = "music";
	var SOUNDS = "sounds";
}
