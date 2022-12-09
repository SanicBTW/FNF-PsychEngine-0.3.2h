package hxs;

import openfl.system.System;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.Assets;
import flixel.graphics.FlxGraphic;

// based on paths but removes all the useless stuff for modules
// might need a couple of extra work
class BasicPaths
{
    public static var currentTrackedAssets:Map<String, FlxGraphic> = new Map();
    public static var localTrackedAssets:Array<String> = [];
    public var currentDir:String;

    public function new(currentDir:String)
    {
        this.currentDir = currentDir;
    }

	inline public function getPath(file:String = '')
	{
		return 'assets/$currentDir/$file';
	}

    public function image(key:String)
    {
        var path = getPath('$key.png');
        return getGraphic(path);
    }

    public function getGraphic(file:String)
    {
        if (!currentTrackedAssets.exists(file))
        {
            var newBitmap = Assets.getBitmapData(file, false);
            var newGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
            newGraphic.persist = true;
            currentTrackedAssets.set(file, newGraphic);
        }
        return currentTrackedAssets.get(file);
    }

    // make these functions on normal paths
    public static function clearUnusedMemory()
    {
        for (key in currentTrackedAssets.keys())
        {
            if (!localTrackedAssets.contains(key))
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

    public static function clearStoredMemory()
    {
        @:privateAccess
        for (key in FlxG.bitmap._cache.keys())
        {
            var obj = FlxG.bitmap._cache.get(key);
            if (obj != null && !currentTrackedAssets.exists(key))
            {
                Assets.cache.removeBitmapData(key);
                FlxG.bitmap._cache.remove(key);
                obj.destroy();
            }
        }

        localTrackedAssets = [];
    }

    public function getAsset(file:String, type:AssetType):Dynamic
    {
        switch(type)
        {
            case IMAGE:
                return getGraphic(file);
            case TEXT:
                return Assets.getText(file);
            default:
                return file;
        }
    }
}