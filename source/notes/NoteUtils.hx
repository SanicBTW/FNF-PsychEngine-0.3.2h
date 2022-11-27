package notes;

import haxe.exceptions.NotImplementedException;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxSprite;

using StringTools;

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

    public static function loadNoteAnims(sprite:Note, noteData:Int, isSustainNote:Bool)
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

    public static function loadPixelNoteAnims(sprite:Note, noteData:Int, isSustainNote:Bool)
    {
        if (isSustainNote)
        {
            sprite.animation.add('${getColorFromNum(noteData)}holdend', [pixelInt[noteData] + 4]);
            sprite.animation.add('${getColorFromNum(noteData)}hold', [pixelInt[noteData]]);
        }
        else
            sprite.animation.add('${getColorFromNum(noteData)}Scroll', [pixelInt[noteData] + 4]);
    }

    public static function assetNullCheck(textureCheck:String)
    {
        var fullPath = Paths.image(textureCheck);
        if (Assets.exists(fullPath)) //gonna check for the png file
            return textureCheck;
        return "NOTE_assets";
    }

    //maybe check if shit is pixel??
    public static function nullCheck(textureCheck:String):Dynamic
    {
        var skin:String = "NOTE_assets";
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var extArrows = features.StorageAccess.getArrowTexture(textureCheck);
            if (extArrows != null)
                return ["ext", extArrows[0], extArrows[1]];
            else
                skin = assetNullCheck(textureCheck);
        }
        else
            skin = assetNullCheck(textureCheck);
        #else
        skin = assetNullCheck(textureCheck);
        #end

        return skin;
    }

    public static function setupPixelWidth(sprite:Note, isSustain:Bool)
    {
        if (isSustain)
        {
            sprite.width = sprite.width / 4;
            sprite.height = sprite.height / 2;
            sprite.originalHeightForCalcs = sprite.height;
        }
        else
        {
            sprite.width = sprite.width / 4;
            sprite.height = sprite.height / 5;
        }
    }

    public static function setupSusOffsets(sprite:Note)
    {
        sprite.offsetX += sprite.lastNoteOffsetXForPixelAutoAdjusting;
        sprite.lastNoteOffsetXForPixelAutoAdjusting = (sprite.width - 7) * (daPixelZoom / 2);
        sprite.offsetX -= sprite.lastNoteOffsetXForPixelAutoAdjusting;
    }
}