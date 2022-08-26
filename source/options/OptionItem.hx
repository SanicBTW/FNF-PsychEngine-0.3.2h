package options;

import Type.ValueType;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;

class OptionItem extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var optionText:FlxText;
    public var variable:String;
    public var type:String;

    public function new(text, y, id, variable)
    {
        super();

        this.ID = id;
        this.variable = variable;

        getValue(); //setup the type shit

        bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
        bg.screenCenter();
        bg.x -= 80;
        bg.y -= y;
        bg.alpha = 0.8;

        optionText = new FlxText(bg.x + 5, bg.y + 15, 0, text, 20);
        optionText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, LEFT);

        add(bg);
        add(optionText);
    }

    public function getValue():Dynamic
    {
        var value = Reflect.getProperty(ClientPrefs, variable);
        
        var stringifiedVal = Std.string(value);
        type = "string";

        //dumb?
        if(stringifiedVal.contains("true")){ type = "bool"; }
        if(stringifiedVal.contains("false")){ type = "bool"; }
        if(Std.parseInt(stringifiedVal) >= 0){ type = "int";  }
        if(Std.parseFloat(stringifiedVal) >= 0){ type = "float"; }

        return value;
    }

    public function setValue(value:Dynamic)
    {
        Reflect.setProperty(ClientPrefs, variable, value);
    }
}