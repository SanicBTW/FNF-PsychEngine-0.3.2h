package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

#if (STORAGE_ACCESS)
import haxe.io.Path;
import lime.system.System;
import sys.FileSystem;
import sys.io.File;
#end

class Paths
{
	inline public static var SOUND_EXT = "ogg";
	inline public static var VIDEO_EXT = "mp4";
	public static var localTrackedAssets:Array<String> = [];
	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Dynamic
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Voices.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
		#end
	}

	inline static public function inst(song:String):Dynamic
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Inst.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#end
	}

	// soon
	inline static public function image(key:String, ?library:String):Dynamic
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		#if STORAGE_ACCESS
		var file:String = extFonts(key);
		if (FileSystem.exists(file))
			return file;
		#end
		return getPath('fonts/$key', FONT);
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if STORAGE_ACCESS
		if (FileSystem.exists(extStorage(key)))
			return true;
		#end

		if (OpenFlAssets.exists(Paths.getPath(key, type)))
		{
			return true;
		}
		return false;
	}

	// soon
	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	// soon
	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	// uh yeah
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String)
	{
		#if STORAGE_ACCESS
		var file:String = extSounds(path, key);
		if (FileSystem.exists(file))
		{
			if (!currentTrackedSounds.exists(file))
				currentTrackedSounds.set(file, Sound.fromFile(file));

			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end

		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(":") + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
		{
			#if STORAGE_ACCESS
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
			#else
			currentTrackedSounds.set(gottenPath, OpenFLAssets.getSound(gottenPath));
			#end
		}

		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	// totally not based off 0.5.2h
	#if STORAGE_ACCESS
	// to manage folder creation, after that we manually set the path on return
	private static var checkDirs:Map<String, String> = new Map();

	static public function checkStorage()
	{
		checkDirs.set("main", Path.join([System.userDirectory, "sanicbtw_pe_files"]));

		checkDirs.set("data", Path.join([checkDirs.get("main"), "data"]));
		checkDirs.set("songs", Path.join([checkDirs.get("main"), "songs"]));
		checkDirs.set("sounds", Path.join([checkDirs.get("main"), "sounds"]));
		checkDirs.set("fonts", Path.join([checkDirs.get("main"), "fonts"]));

		for (name => dirPath in checkDirs)
		{
			trace("Checking: " + name + " - " + dirPath);
			if (!FileSystem.exists(dirPath))
				FileSystem.createDirectory(dirPath);
		}
	}

	inline static public function extStorage(key:String)
	{
		// trace(Path.join([System.userDirectory, 'sanicbtw_pe_files', key]));
		return Path.join([System.userDirectory, 'sanicbtw_pe_files', key]);
	}

	inline static public function extFonts(key:String)
	{
		return extStorage(Path.join(["fonts", key]));
	}

	inline static public function extSounds(path:String, key:String)
	{
		return extStorage(Path.join([path, key]) + "." + SOUND_EXT);
	}

	inline static public function extFolders(pathScan:String)
	{
		return FileSystem.readDirectory(extStorage(Path.join([pathScan])));
	}

	inline static public function extJson(key:String)
	{
		return extStorage(Path.join(["data", key]) + ".json");
	}
	#end
}
