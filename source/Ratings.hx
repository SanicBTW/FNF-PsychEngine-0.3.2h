package;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.FlxSprite;

using StringTools;

//yeah dunno where to put these
class Ratings
{
    public static function generateCombo(number:String, allSicks:Bool, isPixel:Bool, negative:Bool, createdColor:FlxColor, scoreInt:Int, cam:FlxCamera):FlxSprite
    {
        var width = 100;
        var height = 140;
        var path = Paths.getLibraryPath("Forever/" + ClientPrefs.ratingsStyle + "/combo" + (isPixel ? "-pixel" : "") + ".png", "UILib");

        if (isPixel)
        {
            width = 10;
            height = 12;
        }

        var newSprite:FlxSprite = new FlxSprite().loadGraphic(path, true, width, height);
        newSprite.alpha = 1;
        newSprite.cameras = [cam];
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

    //gotta add timings fuck
    /*private static var timings:Map<String, Array<Dynamic>> = 
    [
        "sick" => [0],
        "good" => [1],
        "bad" => [2],
        "shit" => [3],
        "miss" => [4],
    ];*/
    private static var timings = ["sick", "good", "bad", "shit", "miss"]; //shitty pplaceholder sorry
    public static function generateRating(ratingName:String, perfectSick:Bool, isPixel:Bool, cam:FlxCamera):FlxSprite
    {
        var width = 500;
        var height = 163;
        var path = Paths.getLibraryPath("Forever/" + ClientPrefs.ratingsStyle + "/judgements" + (isPixel ? "-pixel" : "") + ".png", "UILib");

        if (isPixel)
        {
            width = 72;
            height = 32;
        }

        var rating:FlxSprite = new FlxSprite().loadGraphic(path, true, width, height);
        rating.alpha = 1;
        rating.cameras = [cam];
        rating.screenCenter();
        rating.x = (FlxG.width * 0.55) - 40;
        rating.y -= 60;

        rating.visible = (!ClientPrefs.hideHud);
        rating.x += ClientPrefs.comboOffset[0];
        rating.y -= ClientPrefs.comboOffset[1];

        rating.animation.add('base',
        [
            Std.int((timings.indexOf(ratingName) * 2) + (perfectSick ? 0 : 2) + 0)
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
}