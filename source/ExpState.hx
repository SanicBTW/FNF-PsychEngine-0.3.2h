package;

import flixel.ui.FlxBar;
import flixel.FlxG;
import audio.*;

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
            inst.play();
            voices.play();
        }

        if (inst.playing)
            instBar.percent = (inst.getTime() / inst.length) * 100;

        if (voices.playing)
            voicesBar.percent = (voices.getTime() / voices.length) * 100;

        super.update(elapsed);
    }
}