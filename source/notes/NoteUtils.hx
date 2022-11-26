package notes;

import lime.utils.Assets;
import flixel.FlxSprite;

using StringTools;

// if getting images through library/hardcoded paths and shit doesnt work i will revert it to the default method :/
class NoteUtils
{
    public static var swagWidth:Float = 160 * 0.7;
	public static var pixelInt:Array<Int> = [0, 1, 2, 3];
    public static var daPixelZoom:Float = 6;

    public static function getArrowFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0:
                stringSex = "left";
            case 1:
                stringSex = "down";
            case 2:
                stringSex = "up";
            case 3:
                stringSex = "right";
        }
        return stringSex;
    }
    
    public static function getColorFromNum(num:Int)
    {
        var stringSex:String = "";
        switch (num)
        {
            case 0:
                stringSex = "purple";
            case 1:
                stringSex = "blue";
            case 2:
                stringSex = "green";
            case 3:
                stringSex = "red";
        }
        return stringSex;
    }

    // br
    public static function returnDefaultNote(args:{?texture:String, ?library:String}, note:{strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool, ?inEditor:Bool})
    {
        var newNote:Note = new Note(note.strumTime, note.noteData, note.prevNote, note.sustainNote, note.inEditor);
        if (args.texture == null)
            args.texture = '';
        if (args.library == null)
            args.library = 'default';

        var skin:String = args.texture;
        if (args.texture.length < 1)
        {
            skin = 'assets/images/${PlayState.SONG.arrowSkin}';
            if (skin == null || skin.length < 1)
                skin = "assets/images/NOTE_assets";
        }

        var lastScaleY:Float = newNote.scale.y;

        var check:Dynamic = nullCheck(skin, args.library);
        if (check[0] != "ext")
        {
            
        }
    }

    public static function loadNoteAnims(sprite:FlxSprite, noteData:Int, isSustainNote:Bool)
    {
        sprite.animation.addByPrefix('${getColorFromNum(noteData)}Scroll', '${getColorFromNum(noteData)}0');

        if (isSustainNote)
        {
            sprite.animation.addByPrefix('purpleholdend', 'pruple end hold'); //lmao
            sprite.animation.addByPrefix('${getColorFromNum(noteData)}holdend', '${getColorFromNum(noteData)} hold end');
            sprite.animation.addByPrefix('${getColorFromNum(noteData)}hold', '${getColorFromNum(noteData)} hold piece');
        }

        sprite.setGraphicSize(Std.int(sprite.width * 0.7));
        sprite.updateHitbox();
    }

    public static function loadPixelNoteAnims(sprite:FlxSprite, noteData:Int, isSustainNote:Bool)
    {
        if (isSustainNote)
        {
            sprite.animation.add('${getColorFromNum(noteData)}holdend', [pixelInt[noteData] + 4]);
            sprite.animation.add('${getColorFromNum(noteData)}hold', [pixelInt[noteData]]);
        }
        else
            sprite.animation.add('${getColorFromNum(noteData)}Scroll', [pixelInt[noteData] + 4]);
    }

    public static function assetNullCheck(textureCheck:String, library:String = "default")
    {
        var fullPath = Paths.getLibraryPath(textureCheck, library);
        if (Assets.exists(fullPath))
            return fullPath;
        return "assets/images/NOTE_assets";
    }

    public static function nullCheck(textureCheck:String, library:String = "default")
    {
        var skin = "assets/images/NOTE_assets";
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var extArrows = features.StorageAccess.getArrowTexture(textureCheck.replace("assets/images/", ""));
            if (extArrows != null)
                return ["ext", extArrows[0], extArrows[1]];
            else
                skin = assetNullCheck(textureCheck, library);
        }
        else
            skin = assetNullCheck(textureCheck, library);
        #else
        skin = assetNullCheck(textureCheck, library);
        #end

        return skin;
    }
}