package notes;

import haxe.exceptions.NotImplementedException;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import flixel.FlxSprite;

using StringTools;

// if getting images through library paths and shit doesnt work i will revert it to the default method :/
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
    public static function returnDefaultNote(args:{?texture:String, ?library:String, ?isPixel:Bool}, note:{strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool, ?inEditor:Bool}):Dynamic
    {
        var newNote:Note = new Note(note.strumTime, note.noteData, note.prevNote, note.sustainNote, note.inEditor);
        if (args.texture == null)
            if (newNote.texture.length > 0)
                args.texture = newNote.texture;
            else
                args.texture = '';
        if (args.library == null)
            args.library = 'default';

        var skin:String = args.texture;
        if (args.texture.length < 1)
        {
            skin = PlayState.SONG.arrowSkin;
            if (skin == null || skin.length < 1)
                skin = "NOTE_assets";
        }

        var lastScaleY:Float = newNote.scale.y;

        var check:Dynamic = nullCheck(skin, args.library);
        if (check[0] != "ext")
        {
            skin = check;

            if (args.isPixel)
            {
                if (note.sustainNote)
                {
                    newNote.loadGraphic(Paths.getGraphic(Paths.image('pixelUI/${skin}ENDS', args.library)));
                    setupPixelWidth(newNote, true);
                    newNote.loadGraphic(Paths.getGraphic(Paths.image('pixelUI/${skin}ENDS', args.library)), true, Math.floor(newNote.width), Math.floor(newNote.height));
                }
                else
                {
                    newNote.loadGraphic(Paths.getGraphic(Paths.image('pixelUI/${skin}', args.library)));
                    setupPixelWidth(newNote, false);
                    newNote.loadGraphic(Paths.getGraphic(Paths.image('pixelUI/${skin}', args.library)), true, Math.floor(newNote.width), Math.floor(newNote.height));
                }
                newNote.setGraphicSize(Std.int(newNote.width * daPixelZoom));
                loadPixelNoteAnims(newNote, note.noteData, note.sustainNote);
                newNote.antialiasing = false;

                if (note.sustainNote)
                    setupSusOffsets(newNote);
            }
            else
            {
                var graphic = Paths.getGraphic(Paths.image(skin, args.library));
                // wtf
                var text = Assets.getText(Paths.getLibraryPath('images/$skin.xml', args.library));
                newNote.frames = FlxAtlasFrames.fromSparrow(graphic, text);
                loadNoteAnims(newNote, note.noteData, note.sustainNote);
                newNote.antialiasing = SaveData.get(ANTIALIASING);
            }
        }
        else
        {
            if (args.isPixel)
                return new NotImplementedException();
            else
            {
                newNote.frames = check[2];
                loadNoteAnims(newNote, note.noteData, note.sustainNote);
                newNote.antialiasing = SaveData.get(ANTIALIASING);
            }
        }

        if (note.sustainNote)
            newNote.scale.y = lastScaleY;
        newNote.updateHitbox();

        if (note.inEditor)
        {
            newNote.setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
            newNote.updateHitbox();
        }

        return newNote;
    }

    private static function loadNoteAnims(sprite:Note, noteData:Int, isSustainNote:Bool)
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

    private static function loadPixelNoteAnims(sprite:Note, noteData:Int, isSustainNote:Bool)
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
        var fullPath = Paths.image(textureCheck, library);
        if (Assets.exists(fullPath)) //gonna check for the png file
            return fullPath;
        return "NOTE_assets";
    }

    public static function nullCheck(textureCheck:String, library:String = "default"):Dynamic
    {
        var skin:String = "NOTE_assets";
        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var extArrows = features.StorageAccess.getArrowTexture(textureCheck);
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

    private static function setupPixelWidth(sprite:Note, isSustain:Bool)
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

    private static function setupSusOffsets(sprite:Note)
    {
        sprite.offsetX += sprite.lastNoteOffsetXForPixelAutoAdjusting;
        sprite.lastNoteOffsetXForPixelAutoAdjusting = (sprite.width - 7) * (daPixelZoom / 2);
        sprite.offsetX -= sprite.lastNoteOffsetXForPixelAutoAdjusting;
    }
}