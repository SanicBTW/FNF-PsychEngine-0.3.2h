package;

import openfl.system.System;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	public static var localTrackedAssets:Array<String> = [];
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static var clearLibs:Array<String> = ["shared", "UILib", "songs", "images"];
	public static var loadLibs:Array<String> = ["shared", "UILib"];
    static var currentLevel:String;
	inline public static var SOUND_EXT = "ogg";
	inline public static var VIDEO_EXT = "mp4";

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.ogg',
		'assets/shared/music/breakfast.ogg',
		'assets/shared/music/tea-time.ogg',
	];

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

	inline static public function video(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
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

	inline static public function voices(song:String)
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		#if html5
		return 'songs:assets/songs/$songKey.$SOUND_EXT';
		#else
		var voices = returnSound('songs', songKey);
		return voices;
		#end
	}

	inline static public function inst(song:String)
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		#if html5
		return 'songs:assets/songs/$songKey.$SOUND_EXT';
		#else
		var inst = returnSound('songs', songKey);
		return inst;
		#end
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if STORAGE_ACCESS
		if (ClientPrefs.allowFileSys)
		{
			if (features.StorageAccess.exists(haxe.io.Path.join([features.StorageAccess.getFolderPath(MAIN), key])))
				return true;
		}
		else
		{
			if (OpenFlAssets.exists(Paths.getPath(key, type)))
				return true;
		}
		#else
		if (OpenFlAssets.exists(Paths.getPath(key, type)))
			return true;
		#end
		return false;
	}

	static public function getSparrowAtlas(key:String, ?library:String)
	{
		#if STORAGE_ACCESS
		if (ClientPrefs.allowFileSys)
		{
			var graphicLoaded = returnGraphic(key, library);
			var xmlExists:Bool = false;
			var xmlPath = haxe.io.Path.join([features.StorageAccess.getFolderPath(IMAGES), key + ".xml"]);
			if (features.StorageAccess.exists(xmlPath))
				xmlExists = true;

			return FlxAtlasFrames.fromSparrow((graphicLoaded != null ? graphicLoaded : image(key, library)), (xmlExists ? sys.io.File.getContent(xmlPath) : file('images/$key.xml', library)));
		}
		else
			return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	static public function getPackerAtlas(key:String, ?library:String)
	{
		#if STORAGE_ACCESS
		if (ClientPrefs.allowFileSys)
		{
			var graphicLoaded = returnGraphic(key, library);
			var txtExists:Bool = false;
			var txtPath = haxe.io.Path.join([features.StorageAccess.getFolderPath(IMAGES), key + ".txt"]);
			if (features.StorageAccess.exists(txtPath))
				txtExists = true;

			return FlxAtlasFrames.fromSpriteSheetPacker((graphicLoaded != null ? graphicLoaded : image(key, library)), (txtExists ? sys.io.File.getContent(txtPath) : file('images/$key.txt', library)));
		}
		else
			return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	static public function returnGraphic(key:String, ?library:String)
	{
		#if STORAGE_ACCESS
		if (ClientPrefs.allowFileSys)
		{
			var extKey = haxe.io.Path.join([features.StorageAccess.getFolderPath(IMAGES), key + ".png"]);
			trace(extKey);
			if (features.StorageAccess.exists(extKey))
			{
				if (!currentTrackedAssets.exists(extKey))
				{
					var newBitmap:BitmapData = BitmapData.fromFile(extKey);
					var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, extKey);
					currentTrackedAssets.set(extKey, newGraphic);
				}
				localTrackedAssets.push(extKey);
				return currentTrackedAssets.get(extKey);
			}
			else if (features.StorageAccess.exists(extKey) == false)
				return getGraphicFromAssets(key, library);
		}
		else
			return getGraphicFromAssets(key, library);
		#else
		return getGraphicFromAssets(key, library);
		#end
		trace("returning null graphic at " + key);
		return null;
	}

	static public function returnSound(path:String, key:String, ?library:String)
	{
		#if STORAGE_ACCESS
		if (ClientPrefs.allowFileSys)
		{
			var soundKey = haxe.io.Path.join([features.StorageAccess.getFolderPath(MAIN), path, key + '.$SOUND_EXT']);
			trace(soundKey);
			if (features.StorageAccess.exists(soundKey))
			{
				if (!currentTrackedSounds.exists(soundKey))
					currentTrackedSounds.set(soundKey, Sound.fromFile(soundKey));

				localTrackedAssets.push(key);
				return currentTrackedSounds.get(soundKey);
			}
			else
				return getSoundFromAssets(path, key, library);
		}
		else
			return getSoundFromAssets(path, key, library);
		#else
		return getSoundFromAssets(path, key, library);
		#end
	}

	static private function getGraphicFromAssets(key:String, ?library:String)
	{
		var path = getPath('images/$key.png', IMAGE, library);
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		trace("couldnt find " + key + " in assets, returning null");
		return null;
	}

	static private function getSoundFromAssets(path:String, key:String, ?library:String)
	{
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(":") + 1, gottenPath.length);

		if (Assets.exists(gottenPath))
		{
			if (!currentTrackedSounds.exists(gottenPath))
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));

			localTrackedAssets.push(gottenPath);
			return currentTrackedSounds.get(gottenPath);
		}
		trace("couldnt find " + key + " in assets, returnin null");
		return null;
	}

	public static function clearUnusedMemory()
    {
        for (key in currentTrackedAssets.keys())
        {
            if (localTrackedAssets.contains(key) == false
                && dumpExclusions.contains(key) == false)
            {
                var obj = currentTrackedAssets.get(key);
                @:privateAccess
                if (obj != null)
                {
                    trace("removed " + key + " from unused memory (graphic)");
                    openfl.Assets.cache.removeBitmapData(key);
                    FlxG.bitmap._cache.remove(key);
                    currentTrackedAssets.remove(key);
                    obj.destroy();
                }
            }
        }
        System.gc();
    }

    public static function clearStoredMemory(clearLibraries:Bool = true, setNulls:Bool = true)
    {
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            var obj = FlxG.bitmap._cache.get(key);
            if (obj != null && currentTrackedAssets.exists(key))
            {
                trace("cleared " + key + " from memory (graphic)");
                openfl.Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
            }
        }

        for (key in currentTrackedSounds.keys())
        {
            if (localTrackedAssets.contains(key) == true
                && dumpExclusions.contains(key) == false && key != null)
            {
                trace("cleared " + key + " from memory (sound)");
                Assets.cache.clear(key);
                currentTrackedSounds.remove(key);
            }
        }

        if (clearLibraries)
        {
            for(i in 0...clearLibs.length)
            {
                Assets.cache.clear(clearLibs[i]);
            }

            clearLibs = ["shared", "UILib", "songs", "images"];
        }

        if(setNulls)
        {
            PlayState.inst = null;
            PlayState.voices = null;
            PlayState.SONG = null;
            PlayState.songEvents = null;
        }

        localTrackedAssets = [];

		System.gc();
    }
}
