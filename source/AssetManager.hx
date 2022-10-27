package;

import openfl.system.System;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.Assets;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

enum abstract AssetType(String) to String
{
    var IMAGE = 'image';
	var SPARROW = 'sparrow';
	var SOUND = 'sound';
	var FONT = 'font';
	var DIRECTORY = 'directory';
	var JSON = 'json';
    var PACKER = "packer";
    var TEXT = "text";
    var XML = "xml";
}

class AssetManager
{
    public static var localTrackedAssets:Array<String> = [];
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static var clearLibs:Array<String> = ["shared", "UILib", "songs", "images"];
	public static var loadLibs:Array<String> = ["shared", "UILib"];

    public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.ogg',
		'assets/shared/music/breakfast.ogg',
		'assets/shared/music/tea-time.ogg',
	];

    public static function getAsset(directory:String, type:AssetType = DIRECTORY, group:Null<String> = null, library:Null<String> = null):Dynamic
    {
        var gottenPath = getPath(directory, group, type, library);
        switch(type)
        {
            case JSON:
                return Assets.getText(gottenPath);
            case IMAGE:
                return returnGraphic(gottenPath);
            case SOUND:
                return returnSound(gottenPath);
            case SPARROW:
                var graphicPath = getPath(directory, IMAGE, group);
                trace('sparrow graphic path $graphicPath');
                var graphic:FlxGraphic = returnGraphic(graphicPath);
                trace('sparrow xml path $gottenPath');
                return FlxAtlasFrames.fromSparrow(graphic, Assets.getText(gottenPath));
            case PACKER: //move this to graphic
                var imagePath = getPath(directory, group, IMAGE, library);
                trace('packer image path $imagePath');
                trace('packer txt path $gottenPath');
                return FlxAtlasFrames.fromSpriteSheetPacker(imagePath, Assets.getText(gottenPath));
            default:
                trace('returning directory $gottenPath');
                return gottenPath;
        }
        trace('returning null for $gottenPath');
        return null;
    }

    public static function returnGraphic(key:String)
    {
        if (Assets.exists(key))
        {
            if (!currentTrackedAssets.exists(key))
            {
                var newGraphic:FlxGraphic = FlxG.bitmap.add(key, false, key);
                localTrackedAssets.push(key);
                currentTrackedAssets.set(key, newGraphic);
            }
			trace('graphic returning $key');
			return currentTrackedAssets.get(key);
        }
        trace('graphic returning null at $key');
		return null;
    }

    public static function returnSound(key:String)
    {
        if (Assets.exists(key))
        {
            if (!currentTrackedSounds.exists(key))
            {
                #if html5
                currentTrackedSounds.set(key, openfl.utils.Assets.getSound(key));
                #else
                currentTrackedSounds.set(key, Sound.fromFile('./' + key));
                #end
                trace('new sound $key');
            }
            trace('sound returning $key');
            localTrackedAssets.push(key);
			return currentTrackedSounds.get(key);
        }
        trace('sound returning null at $key');
		return null;
    }

    public static function getPath(directory:String, group:Null<String> = null, type:AssetType = DIRECTORY, library:Null<String> = null):String
    {
        var pathBase:String = "";

        if (library != null || library != "preload" || library != "default" || library != "")
            pathBase = '$library:assets/$library/';
        else
            pathBase = "assets/";

        var directoryExtension = "";
        if (group != null && group.length > 0)
            directoryExtension += group + "/";
        directoryExtension += directory;
        
        return filterExtensions('$pathBase$directoryExtension', type);
    }

    public static function filterExtensions(directory:String, type:String)
    {
        if(!Assets.exists(directory))
        {
            var extensions:Array<String> = [];
            switch(type)
            {
                case IMAGE:
                    extensions = ['.png'];
                case JSON:
                    extensions = ['.json'];
                case PACKER | TEXT:
                    extensions = [".txt"];
                case SPARROW | XML:
                    extensions = ['.xml'];
                case SOUND:
                    extensions = ['.ogg', '.mp3'];
                case FONT:
                    extensions = ['.ttf', '.otf'];
            }
            trace(extensions);

            for(i in extensions)
            {
                var returnDirectory:String = '$directory$i';
                trace('attempting directory $returnDirectory');
                if(Assets.exists(returnDirectory))
                {
                    trace('successful extension $i');
                    return returnDirectory;
                }
            }
        }
        trace('no extension needed, returning $directory');
        return directory;
    }


    public static function clearUnusedMemory()
    {
        for (key in currentTrackedAssets.keys())
        {
            if (!localTrackedAssets.contains(key)
                && !dumpExclusions.contains(key))
            {
                var obj = currentTrackedAssets.get(key);
                @:privateAccess
                if (obj != null)
                {
                    Assets.cache.removeBitmapData(key);
                    FlxG.bitmap._cache.remove(key);
                    currentTrackedAssets.remove(key);
                    obj.destroy();
                }
            }
        }
        System.gc();
    }

    public static function clearStoredMemory(setNulls:Bool = true)
    {
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            var obj = FlxG.bitmap._cache.get(key);
            if (obj != null && currentTrackedAssets.exists(key))
            {
                Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
            }
        }

        for (key in currentTrackedSounds.keys())
        {
            if (!localTrackedAssets.contains(key)
                && !dumpExclusions.contains(key) && key != null)
            {
                Assets.cache.clear(key);
                currentTrackedAssets.remove(key);
            }
        }

        for(i in 0...clearLibs.length)
		{
			Assets.cache.clear(clearLibs[i]);
		}

        localTrackedAssets = [];
		clearLibs = ["shared", "UILib", "songs", "images"];
        
		if(setNulls)
		{
			PlayState.inst = null;
			PlayState.voices = null;
			PlayState.SONG = null;
			PlayState.songEvents = null;
		}

		System.gc();
    }
}