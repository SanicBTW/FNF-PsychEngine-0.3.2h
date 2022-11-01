package audio;

import openfl.events.EventType;
import flixel.FlxG;
import openfl.media.SoundTransform;
import flixel.tweens.FlxTween;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.Assets;

// from fps plus
class AudioStream
{
    // TODO: Make an option to change the audio source and reset variables to avoid errors
    // bruh only volume worked properly as a get set var
    var sound:Sound;
    var channel:SoundChannel;
    public var playing:Bool = false;
    public var volume(default, set):Float = FlxG.sound.volume;
    public var length:Float = 0;
    public var loop:Bool = false;
    var lastTime:Float = 0;

    public function new()
    {
        sound = new Sound();
    }

    public function loadSound(key:String)
    {
        if (sound != null)
        {
            sound = Assets.getMusic(key);
            length = sound.length;
        }
        else
            trace("sound is null");
    }

    public function play()
    {
        if (channel == null)
        {
            channel = sound.play(lastTime);
            channel.soundTransform = new SoundTransform(volume);
            playing = true;
    }
    }

    // because get shit wont update the value at all lol
    public function getTime():Float
    {
        if (channel != null)
            return channel.position;
        else
            return 0;
    }

    public function setTime(newTime:Float)
    {
        if (channel != null)
            channel.position = newTime;
    }


    public function stop()
    {
        if (channel != null)
        {
            lastTime = channel.position;
            channel.stop();
            channel = null;
            playing = false;
        }
    }

    function set_volume(value:Float):Float
    {
        if (channel != null)
        {
            channel.soundTransform = new SoundTransform(value);
            return value;
        }
        return 0;
    }
}