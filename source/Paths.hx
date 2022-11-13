package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	public static var clearLibs:Array<String> = ["shared", "UILib", "songs", "images"];
	public static var loadLibs:Array<String> = ["shared", "UILib"];
	inline public static var SOUND_EXT = "ogg";
	inline public static var VIDEO_EXT = "mp4";
	public static var currentTrackedAssets:Map<String, FlxGraphic> = new Map();
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

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${formatToSongPath(song)}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${formatToSongPath(song)}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		return getPath('fonts/$key', FONT);
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if (OpenFlAssets.exists(Paths.getPath(key, type)))
		{
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	public static function getGraphic(file:String)
	{
		if (!currentTrackedAssets.exists(file))
		{
			var newGraphic = FlxG.bitmap.add(file, false, file);
			newGraphic.persist = true;
			currentTrackedAssets.set(file, newGraphic);
		}
		return currentTrackedAssets.get(file);
	}

	public static function clearCache(clearLibraries:Bool = true, setNulls:Bool = true)
	{
		#if STORAGE_ACCESS
		@:privateAccess
		for (key in features.StorageAccess.currentTrackedAssets.keys())
		{
			var obj = features.StorageAccess.currentTrackedAssets.get(key);
			if (obj != null)
			{
				trace("cleared " + key + " from memory (graphic)");
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				features.StorageAccess.currentTrackedAssets.remove(key);
				obj.destroy();
			}
		}
		#end

		@:privateAccess
		for (key in currentTrackedAssets.keys())
		{
			var obj = currentTrackedAssets.get(key);
			if (obj != null)
			{
				trace("cleared " + key + " from memory (graphic)");
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				currentTrackedAssets.remove(key);
				obj.destroy();
			}
		}

		if (clearLibraries)
		{
			for (i in 0...clearLibs.length)
			{
				Assets.cache.clear(clearLibs[i]);
			}

			clearLibs = ["shared", "UILib", "songs", "images"];
		}

		if (setNulls)
		{
			PlayState.instSource = null;
			PlayState.voicesSource = null;
			PlayState.SONG = null;
			PlayState.songEvents = null;
		}

		System.gc();
	}
}
