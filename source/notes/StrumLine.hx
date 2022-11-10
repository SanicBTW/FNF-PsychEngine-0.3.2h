package notes;

import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class StrumLine extends FlxTypedGroup<FlxBasic>
{
    //add compatibility for external usage
    public var receptors:FlxTypedGroup<StrumNote>;
    public var splashNotes:FlxTypedGroup<NoteSplash>;
    public var notesGroup:FlxTypedGroup<Note>;
    public var holdsGroup:FlxTypedGroup<Note>;
    public var allNotes:FlxTypedGroup<Note>;

    public function new(x:Float = 0, player:Int, noteSplashes:Bool = false, keyAmount:Int = 4 /*, ?parent:StrumLine what is this for */)
    {
        super();

        receptors = new FlxTypedGroup<StrumNote>();
        splashNotes = new FlxTypedGroup<NoteSplash>();
        notesGroup = new FlxTypedGroup<Note>();
        holdsGroup = new FlxTypedGroup<Note>();

        allNotes = new FlxTypedGroup<Note>();

        for (i in 0...keyAmount)
        {
            var staticArrow:StrumNote = new StrumNote(x, 25 + (ClientPrefs.downScroll ? FlxG.height - 150 : 0), i, player);
            staticArrow.downScroll = ClientPrefs.downScroll;
            staticArrow.ID = i;

            staticArrow.x -= ((keyAmount / 2) * Note.swagWidth);
            staticArrow.x += (Note.swagWidth * i);
            //staticArrow.x += 50;
            receptors.add(staticArrow);

            staticArrow.y -= 10;
            staticArrow.alpha = 0;
            staticArrow.playAnim('static');

            FlxTween.tween(staticArrow, {y: staticArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

            /*
            var staticArrow:UIStaticArrow = generateUIArrows(-25 + x, 25 + (ClientPrefs.downScroll ? FlxG.height - 150 : 0), i, PlayState.isPixelStage);
            staticArrow.ID = i;

            staticArrow.x -= ((keyAmount / 2) * Note.swagWidth);
            staticArrow.x += (Note.swagWidth * i);
            receptors.add(staticArrow);

            staticArrow.initialX = Math.floor(staticArrow.x);
            staticArrow.initialY = Math.floor(staticArrow.y);
            staticArrow.y -= 10;
            staticArrow.playAnim('static');

            staticArrow.alpha = 0;
            FlxTween.tween(staticArrow, {y: staticArrow.initialY, alpha: staticArrow.setAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

            /* add forever engine note splashes
            if (noteSplashes)
            {
                var noteSplash:NoteSplash = 
            }*/
        }

        add(holdsGroup);
        add(receptors);
        add(notesGroup);
    }

    public function push(newNote:Note)
    {
        var group = (newNote.isSustainNote ? holdsGroup : notesGroup);
        group.add(newNote);
        allNotes.add(newNote);
        group.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
    }

    private function generateUIArrows(x:Float, y:Float, staticArrowType:Int = 0, isPixel:Bool):UIStaticArrow
    {
        var newStaticArrow:UIStaticArrow = new UIStaticArrow(x, y, staticArrowType);

        if (isPixel)
        {
            newStaticArrow.loadGraphic(Paths.image('pixelUI/NOTE_assets'), true, 17, 17);

            newStaticArrow.animation.add('static', [staticArrowType]);
            newStaticArrow.animation.add('pressed', [4 + staticArrowType, 8 + staticArrowType], 12, false);
            newStaticArrow.animation.add('confirm', [12 + staticArrowType, 16 + staticArrowType], 24, false);

            newStaticArrow.setGraphicSize(Std.int(newStaticArrow.width * PlayState.daPixelZoom));
            newStaticArrow.antialiasing = false;

            newStaticArrow.addOffset('static', -67, -50);
            newStaticArrow.addOffset('pressed', -67, -50);
            newStaticArrow.addOffset('confirm', -67, -50);
        }
        else
        {
            var stringSect:String = '';
            stringSect = UIStaticArrow.getArrowFromNum(staticArrowType);

            newStaticArrow.frames = Paths.getSparrowAtlas("NOTE_assets");
            newStaticArrow.animation.addByPrefix('static', 'arrow' + stringSect.toUpperCase());
            newStaticArrow.animation.addByPrefix('pressed', stringSect + ' press', 24, false);
            newStaticArrow.animation.addByPrefix('confirm', stringSect + ' confirm', 24, false);

            newStaticArrow.antialiasing = ClientPrefs.globalAntialiasing;
            newStaticArrow.setGraphicSize(Std.int(newStaticArrow.width * 0.7));

            var offsetMiddleX = 0;
            var offsetMiddleY = 0;
            if (staticArrowType > 0 && staticArrowType < 3)
            {
                offsetMiddleX = 2;
                offsetMiddleY = 2;
                if (staticArrowType == 1)
                {
                    offsetMiddleX -= 1;
                    offsetMiddleY += 2;
                }
            }

            newStaticArrow.addOffset('static');
            newStaticArrow.addOffset('pressed', -2, -2);
            newStaticArrow.addOffset('confirm', 36 + offsetMiddleX, 36 + offsetMiddleY);
        }

        newStaticArrow.updateHitbox();

        return newStaticArrow;
    }
}