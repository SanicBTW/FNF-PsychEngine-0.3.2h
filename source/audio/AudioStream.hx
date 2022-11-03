package audio;

import openfl.events.Event;
import openfl.net.URLRequest;
import flixel.FlxG;
import openfl.media.SoundTransform;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.utils.Assets;

// from fps plus
class AudioStream
{
    // TODO: Make an option to change the audio source and reset variables to avoid errors
    var sound:Sound;
    var channel:SoundChannel;
    public var playing:Bool = false;
    @:isVar public var time(get, /*set*/ never):Float = 0;
    public var volume(default, set):Float = 1;
    public var length:Float = 0;
    public var lastTime:Float = 0;
    public var initialized:Bool = false;
    public var onComplete:Event->Void;
    public var source(default, set):Dynamic = null;

    public function new()
    {
        sound = new Sound();
    }

    public function play()
    {
        if (channel == null && source != null)
        {
            channel = sound.play(lastTime);
            channel.soundTransform = new SoundTransform(volume);
            if (onComplete != null)
                channel.addEventListener(Event.SOUND_COMPLETE, onComplete);
            playing = true;
        }
    }

    public function stop()
    {
        if (channel != null)
        {
            lastTime = channel.position;
            if (onComplete != null)
                channel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
            channel.stop();
            channel = null;
            playing = false;
        }
    }

    function set_volume(value:Float):Float
    {
        if (channel != null)
        {
            if (channel.soundTransform.volume == value)
                return value;
            channel.soundTransform = new SoundTransform(value);
            return value;
        }
        return 0;
    }

	function get_time():Float 
    {
        if (channel != null)
            return channel.position;
        else
            return lastTime;
	}

    function set_source(value:Dynamic):Dynamic
    {
        if (sound == null)
            return null;

        if (Std.isOfType(value, Sound))
            sound = value;

        if (Std.isOfType(value, String))
        {
            if (value.contains("assets/"))
                sound = Assets.getMusic(value);
            if (value.contains("sanicbtw_pe_files"))
                sound = Sound.fromFile(value);
            if (value.contains("http://"))
                sound = new Sound(new URLRequest(value));
        }

        lastTime = 0;
        length = sound.length;
        playing = false;
        initialized = true;

        return value;
    }

    /*
	function set_time(value:Float):Float 
    {
        if (channel != null)
        {
            stop();
            lastTime += value;
            if (lastTime > length)
                lastTime = 0;
            play();
            return lastTime;
        }
        return value;
	}*/
}