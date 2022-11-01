package;

import flixel.ui.FlxBar;
import flixel.FlxG;
import audio.*;

// testing state for the new audio stream
class ExpState extends MusicBeatState
{
    var inst:AudioStream = new AudioStream();
    var voices:AudioStream = new AudioStream();
    var instBar:FlxBar;
    var voicesBar:FlxBar;

    override function create()
    {
        FlxG.sound.music.stop();

        inst.loadSound(Paths.music("Inst"));
        voices.loadSound(Paths.music("Voices"));

        instBar = new FlxBar();
        instBar.screenCenter();
        instBar.y = FlxG.height * 0.97;
        instBar.screenCenter(X);
        instBar.scale.set(10, 1);
        add(instBar);

        voicesBar = new FlxBar();
        voicesBar.screenCenter();
        voicesBar.y = FlxG.height * 0.67;
        voicesBar.screenCenter(X);
        voicesBar.scale.set(10, 1);
        add(voicesBar);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.SPACE)
        {
            if (!inst.playing)
                inst.play();
            else
                inst.stop();

            if (!voices.playing)
                voices.play();
            else
                voices.stop();
        }

        /*
        if (FlxG.keys.justPressed.TWO)
        {
            if (inst.playing)
                inst.time += 1;
            if (voices.playing)
                voices.time += 1;
        }*/

        if (inst.playing)
            instBar.percent = (inst.time / inst.length) * 100;

        if (voices.playing)
            voicesBar.percent = (voices.time / voices.length) * 100;

        super.update(elapsed);
    }
}