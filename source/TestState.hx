package;

import flixel.FlxSprite;
import sys.FileSystem;
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
    var daDirSongs:Array<String>;
    override function create() 
    {
        FlxG.mouse.visible = true;

        trace(FileSystem.readDirectory(StorageAccess.checkDirs.get('songs')));
        daDirSongs = FileSystem.readDirectory(StorageAccess.checkDirs.get('songs'));

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

        var songsDropDown = new FlxUIDropDownMenuCustom(10, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(daDirSongs, true), function(song:String){
            FlxG.sound.music.stop();

            inst = StorageAccess.getInst(daDirSongs[Std.parseInt(song)]);
            voices = StorageAccess.getVoices(daDirSongs[Std.parseInt(song)]);

            vocals = new FlxSound().loadEmbedded(voices);

            FlxG.sound.list.add(vocals);
            FlxG.sound.list.add(new FlxSound().loadEmbedded(inst));
            
            FlxG.sound.playMusic(inst, 1, false);
            vocals.play();
        });
        songsDropDown.screenCenter();
        add(songsDropDown);

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

        if(FlxG.keys.justPressed.R){
            MusicBeatState.resetState();
        }

        super.update(elapsed);
    }
}

/*
inst = StorageAccess.getInst("betrayal-blackout");
voices = StorageAccess.getVoices("betrayal-blackout");

vocals = new FlxSound().loadEmbedded(voices);

FlxG.sound.list.add(vocals);
FlxG.sound.list.add(new FlxSound().loadEmbedded(inst));

FlxG.sound.playMusic(inst, 1, false);
vocals.play();
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
*/