package hxs;

import openfl.display.BitmapData;
import openfl.system.System;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.Assets;
import flixel.graphics.FlxGraphic;

// based on paths but removes all the useless stuff for modules
// might need a couple of extra work
class BasicPaths
{
    public static var localTrackedAssets:Array<String> = [];
    public var currentDir:String;

    public function new(currentDir:String)
    {
        this.currentDir = currentDir;
    }

	inline public function getPath(file:String = '', isStorage:Bool = false)
	{
		return (isStorage == false ? 'assets/$currentDir/$file' : features.StorageAccess.makePath(MAIN, '$currentDir/$file'));
	}

    public function getGraphic(file:String, isStorage:Bool = false)
	{
		if (Paths.currentTrackedAssets.exists(file) == false)
		{
            trace(isStorage);
            trace(!isStorage);
            var newBitmap:BitmapData = null;
            var newGraphic:FlxGraphic = null;
            if (isStorage)
            {
                newBitmap = BitmapData.fromFile(file);
            }
            else
            {
                newBitmap = Assets.getBitmapData(file, false);
            }
            newGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
			Paths.currentTrackedAssets.set(file, newGraphic);
		}
		Paths.localTrackedAssets.push(file);
		return Paths.currentTrackedAssets.get(file);
	}

    public function getAsset(file:String, type:String, isStorage:Bool = false):Dynamic
    {
        switch(type)
        {
            case "image":
                return getGraphic(file, isStorage);
            default:
                return file;
        }
    }
}