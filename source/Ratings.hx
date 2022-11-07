package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using StringTools;

//yeah dunno where to put these
class Ratings
{
    //gotta add timings fuck
    // follows the timings.hx judgementsMap structure on Forever Engine Legacy
    public static var judgementsMap:Map<String, Array<Dynamic>> = 
    [
        "sick" => [0, ClientPrefs.sickWindow, 350, 1],
        "good" => [1, ClientPrefs.goodWindow, 150, 0.75],
        "bad" => [2, ClientPrefs.badWindow, 0, 0.5],
        "shit" => [3, ClientPrefs.shitWindow, -50, 0.25], //-300 or 
        "miss" => [4, 180, -100, -1], //no missWindow or smth so 180, idk if i should -1 on totalNotesHit uhh
    ];

    public static function generateCombo(number:String, allSicks:Bool, isPixel:Bool, negative:Bool, createdColor:FlxColor, scoreInt:Int):FlxSprite
    {
        var width = 100;
        var height = 140;
        var path = Paths.getLibraryPath("Forever/" + ClientPrefs.ratingsStyle + "/combo" + (isPixel ? "-pixel" : "") + ".png", "UILib");
        var graphic = Paths.getGraphic(path);

        if (isPixel)
        {
            width = 10;
            height = 12;
        }

        var newSprite:FlxSprite = new FlxSprite().loadGraphic(graphic, true, width, height);
        newSprite.alpha = 1;
        newSprite.screenCenter();
        newSprite.x += (43 * scoreInt) + 20;
        newSprite.y += 60;

        newSprite.visible = (!ClientPrefs.hideHud);
        newSprite.x += ClientPrefs.comboOffset[2];
        newSprite.y -= ClientPrefs.comboOffset[3];

        newSprite.color = FlxColor.WHITE;
        if (negative)
            newSprite.color = createdColor;

        newSprite.animation.add('base',
        [
            (Std.parseInt(number) != null ? Std.parseInt(number) + 1 : 0) + (!allSicks ? 0 : 11)
        ], 0, false);
        newSprite.animation.play('base');

        if (isPixel)
            newSprite.setGraphicSize(Std.int(newSprite.width * PlayState.daPixelZoom));
        else
        {
            newSprite.antialiasing = ClientPrefs.globalAntialiasing;
            newSprite.setGraphicSize(Std.int(newSprite.width * 0.5));
        }

        newSprite.updateHitbox();
        newSprite.acceleration.y = FlxG.random.int(200, 300);
        newSprite.velocity.y -= FlxG.random.int(140, 160);
        newSprite.velocity.x = FlxG.random.float(-5, 5);

        return newSprite;
    }
    public static function generateRating(ratingName:String, perfectSick:Bool, timing:String, isPixel:Bool):FlxSprite
    {
        var width = 500;
        var height = 163;
        var path = Paths.getLibraryPath("Forever/" + ClientPrefs.ratingsStyle + "/judgements" + (isPixel ? "-pixel" : "") + ".png", "UILib");
        var graphic = Paths.getGraphic(path);

        if (isPixel)
        {
            width = 72;
            height = 32;
        }

        var rating:FlxSprite = new FlxSprite().loadGraphic(graphic, true, width, height);
        rating.alpha = 1;
        rating.screenCenter();
        rating.x = (FlxG.width * 0.55) - 40;
        rating.y -= 60;

        rating.visible = (!ClientPrefs.hideHud);
        rating.x += ClientPrefs.comboOffset[0];
        rating.y -= ClientPrefs.comboOffset[1];

        rating.animation.add('base',
        [
            Std.int((judgementsMap.get(ratingName)[0] * 2) + (perfectSick ? 0 : 2) + (timing == "late" ? 1 : 0))
        ], 24, false);
        rating.animation.play('base');

        if (isPixel)
            rating.setGraphicSize(Std.int(rating.width * PlayState.daPixelZoom * 0.7));
        else
        {
            rating.antialiasing = ClientPrefs.globalAntialiasing;
            rating.setGraphicSize(Std.int(rating.width * 0.7)); //legacy uses 0.5
        }

        rating.updateHitbox();
        rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

        return rating;
    }

    public static function judgeNote(ms:Float)
    {
        var ts:Float = Conductor.timeScale;
        //dumb ass
        var timingWindows = 
        [
            judgementsMap.get("sick")[1],
            judgementsMap.get("good")[1],
            judgementsMap.get("bad")[1],
            judgementsMap.get("shit")[1],
            judgementsMap.get("miss")[1],
        ];
        var ratings = ["sick", "good", "bad", "shit"];

        for (i in 0...timingWindows.length)
        {
            if (ms <= timingWindows[Math.round(Math.min(i, timingWindows.length - 1))] * ts)
            {
                return ratings[i];
            }
        }

        return 'miss';
    }
}