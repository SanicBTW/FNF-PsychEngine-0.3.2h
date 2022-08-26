package options;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class OptionItem extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var optionText:FlxText;
    public var variable:String;

    public function new(text, y, id, variable)
    {
        super();

        this.ID = id;
        this.variable = variable;

        var color = FlxColor.WHITE;

        var value = getValue();
        if(value == true){ color = FlxColor.GREEN; }
        if(value == false){ color = FlxColor.RED; }

        bg = new FlxSprite().makeGraphic(400, 50, color);
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
        return Reflect.getProperty(ClientPrefs, variable);
    }

    public function setValue(value:Dynamic)
    {
        Reflect.setProperty(ClientPrefs, variable, value);
    }
}