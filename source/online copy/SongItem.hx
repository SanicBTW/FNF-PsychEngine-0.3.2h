package onlinecopy;

import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class SongItem extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var songTxt:FlxText;
    public var progBar:FlxBar;
    public var downloadProgress:Float;
    public var clickedCB:Array<Dynamic>->Void = function(args:Array<Dynamic>){}
    public var parentItem:SongItem;

    public function new(songText, x, y, onClick:Array<Dynamic>->Void = null)
    {
        super();

        bg = new FlxSprite().makeGraphic(310, 50, FlxColor.WHITE);
        bg.scrollFactor.set();
        bg.screenCenter();
        bg.x -= x;
        bg.y -= y;
        bg.alpha = 0.6;

        songTxt = new FlxText(bg.x + 5, bg.y + 14, 0, songText, 20);
        songTxt.scrollFactor.set();
        songTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, LEFT);

        // bg.y seems really cool imo
        progBar = new FlxBar(songTxt.x - 5, bg.y, LEFT_TO_RIGHT, Std.int(bg.width), 5, this, "downloadProgress");
        progBar.scrollFactor.set();

        if (onClick != null)
            clickedCB = onClick;

        add(bg);
        add(songTxt);
        add(progBar);
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed)
        {
            this.clickedCB(
            [this, this.parentItem]
            );
        }
        if (FlxG.mouse.overlaps(this))
        {
            this.bg.color = FlxColor.GRAY;
        }
        else
        {
            this.bg.color = FlxColor.WHITE;
        }

        super.update(elapsed);
    }
}