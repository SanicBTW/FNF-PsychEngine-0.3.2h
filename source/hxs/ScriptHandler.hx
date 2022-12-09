package hxs;

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

        exp.set("Conductor", Conductor);

        parser.allowTypes = true;
    }

    public static function loadModule(path:String, ?currentDir:String, ?extraParams:StringMap<Dynamic>)
    {
        trace('Loading Module $path');
        var shit = getModule(path);
        return new ForeverModule(parser.parseString(shit[0], shit[1]), currentDir, extraParams, shit[2]);
    }

    private static function getModule(path:String):Array<Dynamic>
    {
        var modulePath:String = "";
        var content:String = "";
        var isStorage:Bool = false;
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var stpath = features.StorageAccess.makePath(MAIN, '$path.hxs');
            if (!features.StorageAccess.exists(stpath))
            {
                var ass = getAssetModule(path);
                content = ass[0]; modulePath = ass[1];
            }
            else
            {
                content = sys.io.File.getContent(stpath);
                modulePath = stpath;
                isStorage = true;
            }
        }
        else
        {
            var ass = getAssetModule(path);
            content = ass[0]; modulePath = ass[1];
        }
        #else
        var ass = getAssetModule(path);
        content = ass[0]; modulePath = ass[1];
        #end

        return [content, modulePath, isStorage];
    }

    private static function getAssetModule(path:String)
    {
        var modulePath:String = "";
        var content:String = "";

        modulePath = Paths.module(path);
        content = Assets.getText(modulePath);

        return [content, modulePath];
    }
}

class ForeverModule
{
    public var interp:Interp;
    public var paths:BasicPaths;
    public var isStorage:Bool = false;

    public function new(?contents:Expr, ?currentDir:String, ?extraParams:StringMap<Dynamic>, isStorage:Bool)
    {
        interp = new Interp();
        for (i in ScriptHandler.exp.keys())
            interp.variables.set(i, ScriptHandler.exp.get(i));

        if (extraParams != null)
        {
            for (i in extraParams.keys())
                interp.variables.set(i, extraParams.get(i));
        }

        this.isStorage = isStorage;
        interp.variables.set('getAsset', getAsset);
        this.paths = new BasicPaths(currentDir);
        interp.variables.set("Paths", this.paths);
        interp.execute(contents);
    }

    public function get(field:String):Dynamic
        return interp.variables.get(field);

    public function set(field:String, value:Dynamic)
        interp.variables.set(field, value);

    public function exists(field:String):Bool
        return interp.variables.exists(field);

    public function getAsset(file:String, type:String):Dynamic
    {
        var path = paths.getPath(file, isStorage);
        trace('Module trying to get asset at $path');
        return paths.getAsset(path, type, isStorage);
    }
}