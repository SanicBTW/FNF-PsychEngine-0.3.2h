package features;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
#if android
import com.player03.android6.Permissions;
#end

using StringTools;

//totally not based off reset score substate

//DID I JUST SPEND 1 HOUR TRYING TO FIX RANDOM CRASHES ON ANDROID JUST BECAUSE ANDROID CONTROLS WERENT INITIALIZED
class PermissionsPrompt extends MusicBeatState
{
    var bg:FlxSprite;
    var onYes:Bool = false;
    var yesText:Alphabet;
    var noText:Alphabet;

    //uses flxg save data cuz clientprefs arent loaded
    override function create()
    {
		PlayerSettings.init();

        if(!FlxG.save.data.answeredFSRequest) //basically first start
        {
            bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"), false, FlxG.width, FlxG.height);
            bg.alpha = 0.5;
            bg.scrollFactor.set();
            bg.screenCenter();
            bg.antialiasing = ClientPrefs.globalAntialiasing;
            add(bg);
    
            var shit:Alphabet = new Alphabet(0, 180, "Do you want to", true, false, 0.05, 0.9);
            shit.screenCenter(X);
            add(shit);
    
            var shit:Alphabet = new Alphabet(0, shit.y + 90, "allow FileSystem access?", true, false, 0.05, 0.9);
            shit.screenCenter(X);
            add(shit);
    
            var shit:Alphabet = new Alphabet(0, shit.y + 90, "We won't ask again", true, false, 0.05, 0.7);
            shit.screenCenter(X);
            add(shit);
    
    
            yesText = new Alphabet(0, shit.y + 150, 'Yes', true);
            yesText.screenCenter(X);
            yesText.x -= 200;
            add(yesText);
    
            noText = new Alphabet(0, shit.y + 150, "No", true);
            noText.screenCenter(X);
            noText.x += 200;
            add(noText);
    
            updateOptions();
    
            #if android
            Permissions.onPermissionsGranted.add(_onPermsGrantedEvent);
            Permissions.onPermissionsDenied.add(_onPermsDeniedEvent);
            #end
        }
        else
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new TitleState());
        }

        super.create();
    }

    override function update(elapsed:Float)
    {
        #if windows
        if(FlxG.mouse.overlaps(yesText)){ onYes = true; }
        if(FlxG.mouse.overlaps(noText)){ onYes = false; }

        if(FlxG.mouse.overlaps(yesText) && FlxG.mouse.justPressed && !lime.app.Application.current.window.minimized)
        {
            FlxG.save.data.answeredFSRequest = true;
            FlxG.save.data.allowFileSystemAccess = true;
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('cancelMenu'), 1);
            MusicBeatState.switchState(new TitleState());
        }
        else if(FlxG.mouse.overlaps(noText) && FlxG.mouse.justPressed && !lime.app.Application.current.window.minimized)
        {
            FlxG.save.data.answeredFSRequest = true;
            FlxG.save.data.allowFileSystemAccess = false;
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('cancelMenu'), 1);
            MusicBeatState.switchState(new TitleState());
        }
        #elseif android
        for(touch in FlxG.touches.list)
        {
            if(touch.overlaps(yesText)){ onYes = true; }
            if(touch.overlaps(noText)){ onYes = false; }

            if(touch.overlaps(yesText) && touch.justReleased)
            {
                Permissions.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
            }
            else if(touch.overlaps(noText) && touch.justReleased)
            {
                FlxG.save.data.answeredFSRequest = true;
                FlxG.save.data.allowFileSystemAccess = false;
                FlxG.save.flush();
                FlxG.sound.play(Paths.sound('cancelMenu'), 1);
                MusicBeatState.switchState(new TitleState());
            }
        }
        #end

        updateOptions();

        super.update(elapsed);
    }

    function updateOptions() 
    {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}

    static function _onPermsGrantedEvent(args:Array<String>):Void
    {
        trace("perms granted");
        FlxG.save.data.answeredFSRequest = true;
        FlxG.save.data.allowFileSystemAccess = true;
        FlxG.save.flush();
        FlxG.sound.play(Paths.sound('cancelMenu'), 1);
        MusicBeatState.switchState(new TitleState());
    }

    static function _onPermsDeniedEvent(args:Array<String>):Void
    {
        trace("perms denied");
        FlxG.save.data.answeredFSRequest = true;
        FlxG.save.data.allowFileSystemAccess = false;
        FlxG.save.flush();
        FlxG.sound.play(Paths.sound('cancelMenu'), 1);
        MusicBeatState.switchState(new TitleState());
    }
}