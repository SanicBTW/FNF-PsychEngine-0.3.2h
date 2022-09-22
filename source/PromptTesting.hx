package;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.filters.BlurFilter;

class PromptTesting extends MusicBeatState
{
    var funkyPrompt:Prompt;
    var b:FlxSprite;
    var blur:BlurFilter;
    override function create()
    {
        b = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
        add(b);

        funkyPrompt = new Prompt("Testing", ["testing"], true);
        add(funkyPrompt);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.T)
        {
            funkyPrompt.changeTitle("hola");
        }

        super.update(elapsed);
    }
}