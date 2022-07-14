package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import FlxVideo;

class HaxeFlixelEXEIntro extends MusicBeatState
{
    public static var leftState:Bool = false;

    override function create()
    {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

        var ifStuck = new FlxText(0, 0, FlxG.width, "If you are stuck here\npress enter to go to title state\nthis isnt the codes fault\nits flxvideo's fault", 32);
        ifStuck.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
        ifStuck.screenCenter(Y);
        add(ifStuck);

        (new FlxVideo(Paths.video("HaxeFlixelIntro"))).finishCallback = function() {
            leftState = true;
            FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new TitleState());
        }
        super.create();
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ENTER)
        {
            leftState = true;
            FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new TitleState());
        }
        super.update(elapsed);
    }
}