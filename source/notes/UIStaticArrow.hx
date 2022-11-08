package notes;

import flixel.FlxSprite;

// from forever engine legacy, modified with some strumnote code
class UIStaticArrow extends FlxSprite
{
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var arrowType:Int = 0;
    public var canFinishAnimation:Bool = true;

    public var initialX:Int;
    public var initialY:Int;

    public var xTo:Float;
    public var yTo:Float;
    public var angleTo:Float;

    public var setAlpha:Float = 0.8;

    // from strum note
    private var colorSwap:ColorSwap;
    //dunno if i should do it like this but eh alright ig
    public var direction:Float = 90;
    public var downScroll:Bool = false;
    public var sustainReduce:Bool = true;

    public function new(x:Float, y:Float, babyArrowType:Int = 0)
    {
        super(x, y);

        colorSwap = new ColorSwap();
        shader = colorSwap.shader;

        animOffsets = new Map<String, Array<Dynamic>>();

        downScroll = ClientPrefs.downScroll;

        this.arrowType = babyArrowType;
        updateHitbox();
        scrollFactor.set();
    }

    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
    {
        animation.play(AnimName, Force, Reversed, Frame);

        if (AnimName == "confirm")
            alpha = 1;
        else
            alpha = setAlpha;

        updateHitbox();

        var daOffset = animOffsets.get(AnimName);
        if (animOffsets.exists(AnimName))
            offset.set(daOffset[0], daOffset[1]);
        else
            offset.set(0, 0);

        if (animation.curAnim == null || animation.curAnim.name == "static")
        {
            colorSwap.hue = 0;
            colorSwap.saturation = 0;
            colorSwap.brightness = 0;
        }
        else
        {
            colorSwap.hue = ClientPrefs.arrowHSV[arrowType % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[arrowType % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[arrowType % 4][2] / 100;
        }
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
        animOffsets[name] = [x, y];

    public static function getArrowFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0: stringSex = "left";
            case 1: stringSex = "down";
            case 2: stringSex = "up";
            case 3: stringSex = "right";
        }
        return stringSex;
    }

    public static function getColorFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0: stringSex = "purple";
            case 1: stringSex = "blue";
            case 2: stringSex = "green";
            case 3: stringSex = "red";
        }
        return stringSex;
    }
}