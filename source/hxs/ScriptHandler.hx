package hxs;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.Assets;
import openfl.utils.AssetType;
import hscript.Expr;
import hscript.Interp;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.FlxG;
import hscript.Parser;
import haxe.ds.StringMap;

using StringTools;

// this coming too from them lol
class ColorShit
{
    public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
        return FlxColor.fromRGB(Red, Green, Blue, Alpha);
}

// im using the same class functions to give them credit for their work
class ScriptHandler
{
    public static var exp:StringMap<Dynamic>;
    public static var parser:Parser = new Parser();

    public static function initialize()
    {
        exp = new StringMap<Dynamic>();

        #if sys exp.set("Sys", Sys); #end
        exp.set("Std", Std);
        exp.set("Math", Math);
        exp.set("StringTools", StringTools);

        exp.set("FlxG", FlxG);
        exp.set("FlxSprite", FlxSprite);
        exp.set("FlxMath", FlxMath);
        exp.set("FlxPoint", FlxPoint);
        exp.set("FlxRect", FlxRect);
		exp.set("FlxTween", FlxTween);
		exp.set("FlxTimer", FlxTimer);
		exp.set("FlxEase", FlxEase);
        exp.set("FlxColor", ColorShit);

        exp.set("Conductor", Conductor);
        exp.set("Events", Events);
        exp.set("Character", Character);
        exp.set("Boyfriend", Boyfriend);
        exp.set("HealthIcon", HealthIcon);
        exp.set("PlayState", PlayState);
        
        parser.allowTypes = true;
    }

    public static function loadModule(path:String, ?library:String, ?currentDir:String, ?extraParams:StringMap<Dynamic>)
    {
        trace('Loading Module $path');
        var modulePath:String = "";
        var moduleContent:String = "";
        var internalStorage:Bool = false;
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var intPath = features.StorageAccess.makePath(MAIN, '$path.hxs');
            if (features.StorageAccess.exists(intPath))
            {
                modulePath = intPath;
                moduleContent = sys.io.File.getContent(modulePath);
                internalStorage = true;
            }
            else
            {
                modulePath = Paths.module(path, library);
                moduleContent = moduleAssetCheck(modulePath);
            }
        }
        else
        {
            modulePath = Paths.module(path, library);
            moduleContent = moduleAssetCheck(modulePath);
        }
        #else
        modulePath = Paths.module(path, library);
        moduleContent = moduleAssetCheck(modulePath);
        #end
        trace(modulePath);
        trace(moduleContent);
        if (moduleContent != null)
            return new ForeverModule(parser.parseString(moduleContent, modulePath), currentDir, extraParams, internalStorage);
        else
            return null;
    }

    private static function moduleAssetCheck(path:String)
    {
        if (Assets.exists(path))
            return Assets.getText(path);
        else
            return null;
    }
}

class ForeverModule
{
    public var interp:Interp;
    public var paths:BasicPaths;

    public var alive:Bool = true;
    public function new(?contents:Expr, ?currentDir:String, ?extraParams:StringMap<Dynamic>, internalStorage:Bool)
    {
        interp = new Interp();
        for (i in ScriptHandler.exp.keys())
            interp.variables.set(i, ScriptHandler.exp.get(i));

        if (extraParams != null)
        {
            for (i in extraParams.keys())
                interp.variables.set(i, extraParams.get(i));
        }

        this.paths = new BasicPaths(currentDir, internalStorage);
        interp.variables.set("Paths", this.paths);
        interp.execute(contents);
    }

    public function dispose():Dynamic
        return this.alive = false;

    public function get(field:String):Dynamic
        return interp.variables.get(field);

    public function set(field:String, value:Dynamic)
        interp.variables.set(field, value);

    public function exists(field:String):Bool
        return interp.variables.exists(field);
}