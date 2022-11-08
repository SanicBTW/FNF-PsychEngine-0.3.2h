package notes;

import flixel.FlxSprite;

// from forever engine legacy, modified with some strumnote code
// isnt this just fucking strum note :skull:
class UIStaticArrow extends FlxSprite
{
    public var animOffsets:Map<String, Array<Dynamic>>;
    public var arrowType:Int = 0;

    public var initialX:Int;
    public var initialY:Int;

    public var setAlpha:Float = 0.8;

    // from strum note
    private var colorSwap:ColorSwap;
    public var direction:Float = 90;
    public var downScroll:Bool = false;
    public var sustainReduce:Bool = true;
    public var resetAnim:Float = 0;

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
        centerOffsets();
        centerOrigin();

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

            if (animation.curAnim.name == "confirm" && !PlayState.isPixelStage)
                centerOrigin();
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

    override function update(elapsed:Float)
    {
        if (resetAnim > 0)
        {
            resetAnim -= elapsed;
            if (resetAnim <= 0)
            {
                playAnim('static');
                resetAnim = 0;
            }
        }

        if (animation.curAnim.name == "confirm" && !PlayState.isPixelStage)
            centerOrigin();

        super.update(elapsed);
    }
}