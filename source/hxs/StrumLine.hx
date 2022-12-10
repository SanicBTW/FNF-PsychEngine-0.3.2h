package hxs;

import hxs.ScriptHandler.ForeverModule;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

typedef ReceptorData =
{
	var keyAmount:Int;
	var actions:Array<String>;
	var colors:Array<String>;
	var separation:Float;
	var size:Float;
	var antialiasing:Bool;
}

class StrumLine extends FlxSpriteGroup
{
    
}

class Receptor extends FlxSprite
{
    public var swagWidth:Float;

    public var noteData:Int;
    public var noteType:Int;
    public var action:String;

    public var receptorData:ReceptorData;
    public var noteModule:ForeverModule;
}