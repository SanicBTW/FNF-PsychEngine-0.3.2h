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
    public var currentDir:String;
    public var internalStorage:Bool = false;

    public function new(currentDir:String, internalStorage:Bool = false)
    {
        this.currentDir = currentDir;
        this.internalStorage = internalStorage;
    }

	inline public function getPath(file:String = '')
	{
		return (internalStorage == false ? 'assets/$currentDir/$file' : features.StorageAccess.makePath(MAIN, '$currentDir/$file'));
	}

    public function image(key:String)
    {
        var path = getPath('$key.png');
        trace('Module trying to get asset $path');
        return getGraphic(path);
    }

    private function getGraphic(file:String)
	{
		if (!Paths.currentTrackedAssets.exists(file))
		{
            var newBitmap:BitmapData = (internalStorage == false ? Assets.getBitmapData(file, false) : BitmapData.fromFile(file));
            var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, file);
			Paths.currentTrackedAssets.set(file, newGraphic);
		}
		Paths.localTrackedAssets.push(file);
		return Paths.currentTrackedAssets.get(file);
	}
}