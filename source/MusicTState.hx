package;

import flixel.FlxSprite;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.system.FlxSound;
import openfl.net.URLRequest;
import openfl.media.Sound;
import flixel.FlxG;

class MusicTState extends MusicBeatState
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
            if(vocals != null && vocals.playing){
                vocals.stop();
            }

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

        //add a difficulty thing
        //var songsDifficultyDropDown = new 

        super.create();

        FlxG.sound.music.stop();
    }
    
    override function update(elapsed:Float)
    {
        if(FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justReleased.BACK #end){
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            MusicBeatState.switchState(new OptionsState());
        }

        super.update(elapsed);
    }
}