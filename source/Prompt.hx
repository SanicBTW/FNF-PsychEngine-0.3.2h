package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.FlxSprite;

class Prompt extends FlxSpriteGroup
{
    var bg:FlxSprite;
    var buttons:FlxSprite;
    public var okButtonReg:FlxSprite;
    public var cancelButtonReg:FlxSprite;
    public var props:PromptProperties;
    var okCallback:Void->Void = null;
    var cancelCallback:Void->Void = null;

    public function new(properties:PromptProperties = null, okCb:Void->Void = null, cancelCb:Void->Void = null)
    {
        super();

        if(properties == null)
            properties = 
            {
                header: "Placeholder",
                info: ["This is a prompt placeholder", "modify this in the code"],
                hfontSize: 25,
                ifontSize: 20
            }

        props = properties;

        if(okCb == null)
            okCb = function()
            {
                trace("Pressed OK");
            }
            okCallback = okCb;

        if(cancelCb == null)
            cancelCb = function()
            {
                trace("Pressed CANCEL");
            }
            cancelCallback = cancelCb;

        bg = new FlxSprite().loadGraphic(Paths.image("ui/promptbg"));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        var text = new FlxText(bg.x + 105, bg.y + 30, 0, properties.header, properties.hfontSize);
        text.setFormat(Paths.font("vcr.ttf"), properties.hfontSize, FlxColor.BLACK, LEFT);
        text.antialiasing = ClientPrefs.globalAntialiasing;
        add(text);

        //shit couldnt afford an \n
        var prevText:FlxText = null;
        for(i in 0...properties.info.length)
        {
            var text = new FlxText(bg.x + 12, (prevText == null ? text.y + 50 : prevText.y + 20), 0, properties.info[i], properties.ifontSize);
            text.setFormat(Paths.font("vcr.ttf"), properties.ifontSize, FlxColor.BLACK, LEFT);
            text.antialiasing = ClientPrefs.globalAntialiasing;
            add(text);
            prevText = text;
        }

        //im so fucking smart
        buttons = new FlxSprite(bg.x + 15, bg.y + 260);
        buttons.frames = Paths.getSparrowAtlas('ui/prompt_buttons');
        buttons.animation.addByIndices('but0', 'buttons', [0], '', 0);
        buttons.animation.addByIndices('but1', 'buttons', [1], '', 0);
        buttons.animation.play('but0', true);
        add(buttons);

        //used for mouse operations
        okButtonReg = new FlxSprite(buttons.x, buttons.y).makeGraphic(Std.int(buttons.width / 2), Std.int(buttons.height), FlxColor.TRANSPARENT);
        add(okButtonReg);

        cancelButtonReg = new FlxSprite(buttons.x + (buttons.width / 2), buttons.y).makeGraphic(Std.int(buttons.width / 2), Std.int(buttons.height), FlxColor.TRANSPARENT);
        add(cancelButtonReg);
    }

    //handle button sfx, anims and shit
    override function update(elapsed:Float)
    {
        //IM FUCKING BECOMING SMARTER EVERY FUCKING DAYYYYYYY
        #if (windows || web)
        if(FlxG.mouse.overlaps(okButtonReg) && buttons.animation.curAnim.name == "but1")
            changeAnim("but0");

        if(FlxG.mouse.overlaps(cancelButtonReg) && buttons.animation.curAnim.name == "but0")
            changeAnim("but1");

        if(FlxG.mouse.justPressed && (FlxG.mouse.overlaps(okButtonReg) || FlxG.mouse.overlaps(cancelButtonReg)))
        {
            if(FlxG.mouse.overlaps(okButtonReg)) okCallback();
            if(FlxG.mouse.overlaps(cancelButtonReg)) cancelCallback();
            FlxG.sound.play(Paths.sound('cancelMenu'));
        }
        #end

        //same logic as above
        #if (android)
        for(touch in FlxG.touches.list)
        {
            if(touch.overlaps(okButtonReg) && buttons.animation.curAnim.name == "but1")
                changeAnim("but0");

            if(touch.overlaps(cancelButtonReg) && buttons.animation.curAnim.name == "but0")
                changeAnim("but1");

            if(touch.justReleased && (touch.overlaps(okButtonReg) || touch.overlaps(cancelButtonReg)))
            {
                if(FlxG.mouse.overlaps(okButtonReg)) okCallback();
                if(FlxG.mouse.overlaps(cancelButtonReg)) cancelCallback();
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
        }
        #end

        super.update(elapsed);
    }

    function changeAnim(newAnim:String)
    {
        buttons.animation.play(newAnim, true);
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}

typedef PromptProperties =
{
    //the header of the prompt
    var header:String;
    //the info shit of the prompt
    var info:Array<String>;
    //the header font size
    var hfontSize:Int;
    //the info font size
    var ifontSize:Int;
}