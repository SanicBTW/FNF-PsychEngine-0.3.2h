package;

import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.system.FlxSound;
import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.FlxG;

//might end up improving this one with custom dropdown shit and that
class TestState extends MusicBeatState
{
    var inst:Dynamic;
    var vocals:FlxSound;
    var voices:Dynamic;
    var dabut1:FlxButton;
    var dabut2:FlxButton;
    override function create() 
    {
        FlxG.mouse.visible = true;

        dabut1 = new FlxButton(FlxG.width - 200, 100, "Funky patrol", function(){
            inst = StorageAccess.getInst("funky-patrol");
            voices = StorageAccess.getVoices("funky-patrol");

            vocals = new FlxSound().loadEmbedded(voices);

            FlxG.sound.list.add(vocals);
            FlxG.sound.list.add(new FlxSound().loadEmbedded(inst));
    
            FlxG.sound.playMusic(inst, 1, false);
            vocals.play();
        });
        dabut1.setGraphicSize(Std.int(dabut1.width) * 2);
        dabut1.label.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
        dabut1.visible = true;
        dabut1.scrollFactor.set();
        add(dabut1);

        dabut2 = new FlxButton(FlxG.width - 200, 200, "Betrayal blackout", function(){
            inst = StorageAccess.getInst("betrayal-blackout");
            voices = StorageAccess.getVoices("betrayal-blackout");

            vocals = new FlxSound().loadEmbedded(voices);

            FlxG.sound.list.add(vocals);
            FlxG.sound.list.add(new FlxSound().loadEmbedded(inst));
    
            FlxG.sound.playMusic(inst, 1, false);
            vocals.play();
        });
        dabut2.setGraphicSize(Std.int(dabut2.width) * 2);
        dabut2.label.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
        dabut2.visible = true;
        dabut2.scrollFactor.set();
        add(dabut2);

        super.create();

        FlxG.sound.music.stop();
    }
    
    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ESCAPE){
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}