package hxs;

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

        parser.allowTypes = true;
    }

    public static function loadModule(path:String, ?currentDir:String, ?extraParams:StringMap<Dynamic>)
    {
        trace('Loading Module $path');
        var modulePath:String = Paths.module(path);
        trace(modulePath);
        return new ForeverModule(parser.parseString(Assets.getText(modulePath), modulePath), currentDir, extraParams);
    }
}

class ForeverModule
{
    public var interp:Interp;
    public var paths:BasicPaths;

    public function new(?contents:Expr, ?currentDir:String, ?extraParams:StringMap<Dynamic>)
    {
        interp = new Interp();
        for (i in ScriptHandler.exp.keys())
            interp.variables.set(i, ScriptHandler.exp.get(i));

        if (extraParams != null)
        {
            for (i in extraParams.keys())
                interp.variables.set(i, extraParams.get(i));
        }

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

    public function getAsset(file:String, type:AssetType):Dynamic
    {
        var path = paths.getPath(file);
        trace('Module trying to get asset at $path');
        if (Assets.exists(path))
            return paths.getAsset(path, type);
        else
        {
            trace('Module path failed');
            return null;
        }
    }
}