package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;

//I will add more comments regarding the functionality and shit
class Prompt extends FlxSpriteGroup
{
    //UI Shit
    var buttons:FlxSprite;

    //Button functions, it didn't have custom frames and that stuff so I made these
    public var okButtonReg:FlxSprite;
    public var cancelButtonReg:FlxSprite;

    //Button callbacks - ex when pressing
    public var okCallback:Void->Void = function(){ FlxG.log.add("Pressed ok"); };
    public var cancelCallback:Void->Void = function(){ FlxG.log.add("Pressed cancel"); };
    //I made this to set the proper callback when pressing or hovering
    var executeCb:Void->Void = null;

    //Properties
    public var titleSize:Int = 25;
    public var infoSize:Int = 20;

    public function new(title:String = "Placeholder", info:Array<String>, showButtons:Bool = true)
    {
        super();

        var bg = new FlxSprite().loadGraphic(Paths.image("ui/promptbg"));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        var title = new FlxText(bg.x + 105, bg.y + 30, 0, title, this.titleSize);
        title.setFormat(Paths.font("vcr.ttf"), this.titleSize, FlxColor.BLACK, LEFT);
        title.antialiasing = ClientPrefs.globalAntialiasing;
        add(title);

        var prevText:FlxText = null;
        for(i in 0...info.length)
        {
            var text = new FlxText(bg.x + 12, (prevText == null ? title.y + 50 : prevText.y + 20), 0, info[i], this.infoSize);
            text.setFormat(Paths.font("vcr.ttf"), this.infoSize, FlxColor.BLACK, LEFT);
            text.antialiasing = ClientPrefs.globalAntialiasing;
            add(text);
            prevText = text;
        }

        if(showButtons)
        {
            buttons = new FlxSprite(bg.x + 15, bg.y + 260);
            buttons.frames = Paths.getSparrowAtlas('ui/prompt_buttons');
            buttons.animation.addByIndices('but0', 'buttons', [0], '', 0);
            buttons.animation.addByIndices('but1', 'buttons', [1], '', 0);
            buttons.animation.play('but0', true);
            add(buttons);
    
            okButtonReg = new FlxSprite(buttons.x, buttons.y).makeGraphic(Std.int(buttons.width / 2), Std.int(buttons.height), FlxColor.TRANSPARENT);
            add(okButtonReg);
    
            cancelButtonReg = new FlxSprite(buttons.x + (buttons.width / 2), buttons.y).makeGraphic(Std.int(buttons.width / 2), Std.int(buttons.height), FlxColor.TRANSPARENT);
            add(cancelButtonReg);
        }
    }

    //I believe I can make this simpler
    override function update(elapsed:Float)
    {
        if(okButtonReg != null && cancelButtonReg != null && buttons != null)
        {
            #if !android
            if(FlxG.mouse.overlaps(okButtonReg) && buttons.animation.curAnim.name == "but1")
                changeAnim("but0");

            if(FlxG.mouse.overlaps(cancelButtonReg) && buttons.animation.curAnim.name == "but0")
                changeAnim("but1");

            if(FlxG.mouse.justPressed && (FlxG.mouse.overlaps(okButtonReg) || FlxG.mouse.overlaps(cancelButtonReg)))
            {
                executeCb();
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
            #else
            for(touch in FlxG.touches.list)
            {
                if(touch.overlaps(okButtonReg) && buttons.animation.curAnim.name == "but1")
                    changeAnim("but0");

                if(touch.overlaps(cancelButtonReg) && buttons.animation.curAnim.name == "but0")
                    changeAnim("but1");

                if(touch.justReleased && (touch.overlaps(okButtonReg) || touch.overlaps(cancelButtonReg)))
                {
                    executeCb();
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                }
            }
            #end
        }

        super.update(elapsed);
    }

    function changeAnim(newAnim:String)
    {
        buttons.animation.play(newAnim, true);
        if(newAnim == "but0"){ executeCb = okCallback; }
        if(newAnim == "but1"){ executeCb = cancelCallback; }
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}