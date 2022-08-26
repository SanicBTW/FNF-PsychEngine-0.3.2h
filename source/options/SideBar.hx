package options;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class SideBar extends FlxSpriteGroup
{
    public function new(height)
    {
        super();

        var bg = new FlxSprite().makeGraphic(310, height - 16, FlxColor.WHITE);
        bg.screenCenter();
        bg.x -= 460;
        bg.alpha = 0.7;

        var header = new FlxText(0, 0, 0, "Settings", 32);
        header.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, RIGHT);
        header.screenCenter();
        header.x -= 465;
        header.y -= 290;

        add(bg);
        add(header);
    }
}

class SideBarItem extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var itemText:FlxText;

    public function new(text, y, id)
    {
        super();

        this.ID = id;

        bg = new FlxSprite().makeGraphic(310, 50, FlxColor.WHITE);
        bg.screenCenter();
        bg.x -= 460;
        bg.y -= y;
        bg.alpha = 0.8;

        itemText = new FlxText(bg.x + 5, bg.y + 15, 0, text, 20);
        itemText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, LEFT);

        add(bg);
        add(itemText);
    }
}