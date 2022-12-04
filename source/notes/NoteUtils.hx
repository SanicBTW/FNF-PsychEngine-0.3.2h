package notes;

import haxe.exceptions.NotImplementedException;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxSprite;

using StringTools;

// istg these goofy names
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

    public static function assetCheck(textureCheck:String, isSplash:Bool = false)
    {
        var fullPath = Paths.image(textureCheck);
        if (Assets.exists(fullPath)) //gonna check for the png file
            return textureCheck;
        return (isSplash == true ? "noteSplashes" : "NOTE_assets");
    }

    //maybe check if shit is pixel??
    public static function nullCheck(textureCheck:String, isPixel:Bool = false, isSustain:Bool = false):Dynamic
    {
        var skin:String = "NOTE_assets";
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var extArrows = features.StorageAccess.getArrowTexture(textureCheck, isPixel, isSustain);
            if (extArrows != null)
                return ["ext", extArrows];
            else
                skin = assetCheck(textureCheck);
        }
        else
            skin = assetCheck(textureCheck);
        #else
        skin = assetCheck(textureCheck);
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

    public static function setSplashAnims(sprite:NoteSplash)
    {
        for (i in 1...3)
        {
			sprite.animation.addByPrefix("note0-" + i, "note impact " + i + " purple", 24, false);
            sprite.animation.addByPrefix("note1-" + i, "note impact " + i + " blue", 24, false);
			sprite.animation.addByPrefix("note2-" + i, "note impact " + i + " green", 24, false);
			sprite.animation.addByPrefix("note3-" + i, "note impact " + i + " red", 24, false);
        }
    }

    public static function setPSplashAnims(sprite:NoteSplash)
    {
        for (i in 1...3) 
        {
			sprite.animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			sprite.animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			sprite.animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			sprite.animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
    }

    public static function noteSplashNullCheck(textureCheck:String):Dynamic
    {
        var skin:String = "noteSplashes";
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var extSplashes = features.StorageAccess.getNoteSplashes(textureCheck);
            if (extSplashes != null)
                return ["ext", extSplashes];
            else
                skin = assetCheck(textureCheck, true);
        }
        else
            skin = assetCheck(textureCheck, true);
        #else
        skin = assetCheck(textureCheck, true);
        #end

        return skin;
    }

	public static function getNoteSplashOffset(texture:String):Array<Dynamic>
    {
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var offsetPath = features.StorageAccess.makePath(IMAGES, '${texture}_offset.txt');

            if (!features.StorageAccess.exists(offsetPath))
                return assetNSPOffset(texture);
            else
            {
                var content = sys.io.File.getContent(offsetPath);
                var split = content.split('|');
                return [Std.parseFloat(split[0]), Std.parseFloat(split[1])];
            }
        }
        else
            return assetNSPOffset(texture);
        #else
        return assetNSPOffset(texture);
        #end
    }
    public static function assetNSPOffset(texture:String)
    {
        var defOffset:String = "-26.2|-17"; // default offset if not found
		var offsetPath:String = Paths.image('${texture}_offset');
		offsetPath.replace("png", "txt");

		if (!Assets.exists(offsetPath))
		{
			var split = defOffset.split('|');
			return [Std.parseFloat(split[0]), Std.parseFloat(split[1])];
		}
		else
		{
			var content = Assets.getText(offsetPath);
			var split = content.split('|');
			return [Std.parseFloat(split[0]), Std.parseFloat(split[1])];
		}
    }
}