package features;

import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class ProgressIndicator extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var infoText:FlxText;
    public var progBar:FlxBar;
    public var track:Float;

    public function new(info:String, x:Float, y:Float)
    {
        super();

        scrollFactor.set();

        bg = new FlxSprite().makeGraphic(310, 50, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.screenCenter();
        bg.x -= x;
        bg.y -= y;
        bg.alpha = 0.6;

        infoText = new FlxText(bg.x + 5, bg.y + 14, 0, info, 20);
        infoText.scrollFactor.set();
        infoText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT);

        progBar = new FlxBar(infoText.x - 5, bg.y, LEFT_TO_RIGHT, Std.int(bg.width), 5, this, '', 0, 100);
        progBar.visible = false;
        progBar.scrollFactor.set();

        add(bg);
        add(infoText);
        add(progBar);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (track > 0)
        {
            progBar.visible = true;
            progBar.value = track;
        }
    }
}