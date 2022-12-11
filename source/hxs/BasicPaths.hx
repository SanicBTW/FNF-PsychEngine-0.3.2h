package hxs;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.system.System;
import flixel.FlxG;
import openfl.utils.AssetType;
import openfl.Assets;
import flixel.graphics.FlxGraphic;

using StringTools;

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

	private function getPath(file:String = '', ?library:Null<String> = null)
	{
        if (library != null)
            return '$library:assets/$library/$file';

		return #if sys (internalStorage == false ? 'assets/$currentDir/$file' : features.StorageAccess.makePath(MAIN, '$currentDir/$file')); #else 'assets/$currentDir/$file'; #end
	}

    public function image(key:String, ?library:String)
    {
        var path = getPath(checkExtension(key, 'png'), library);
        trace('Module trying to get asset $path as image');
        return getGraphic(path);
    }

    public function getSparrowAtlas(key:String, ?library:String)
    {
        return FlxAtlasFrames.fromSparrow(image(key, library), getText(checkExtension(key, 'xml'), library));
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

    private function getText(file:String, ?library:String)
    {
        var path = getPath(file, library);
        trace('Module trying to get asset $path as text');
        return #if sys (internalStorage == false ? Assets.getText(path) : sys.io.File.getContent(path) ); #else Assets.getText(path); #end
    }

    // nah bro wtf
    private function checkExtension(string:String, extension:String)
    {
        if (string.endsWith(extension))
            return string;
        else
            return '$string.$extension';
    }
}